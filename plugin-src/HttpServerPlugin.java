package com.shade.seeking.plugin;

import android.content.Intent;
import android.net.Uri;
import android.net.wifi.WifiManager;
import android.os.ParcelFileDescriptor;
import android.provider.DocumentsContract;
import android.util.Log;

import androidx.annotation.NonNull;

import com.getcapacitor.JSObject;
import com.getcapacitor.Plugin;
import com.getcapacitor.PluginCall;
import com.getcapacitor.PluginMethod;
import com.getcapacitor.annotation.CapacitorPlugin;

import org.nanohttpd.protocols.http.IHTTPSession;
import org.nanohttpd.protocols.http.NanoHTTPD;
import org.nanohttpd.protocols.http.response.Response;
import org.nanohttpd.protocols.http.response.Status;

import java.io.File;
import java.io.FileInputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.RandomAccessFile;
import java.net.InetAddress;
import java.net.NetworkInterface;
import java.net.SocketException;
import java.util.Enumeration;
import java.util.HashMap;
import java.util.Map;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;

@CapacitorPlugin(name = "LocalStream")
public class HttpServerPlugin extends Plugin {

    private static final String TAG = "HttpServerPlugin";
    private static final int REQUEST_CODE_PICK_FILE = 1001;

    private ExecutorService serverExecutor;
    private HttpServer server;
    private Uri selectedFileUri;
    private String selectedFileName;
    private String localIpAddress;

    @PluginMethod
    public void pickFile(PluginCall call) {
        Intent intent = new Intent(Intent.ACTION_OPEN_DOCUMENT);
        intent.addCategory(Intent.CATEGORY_OPENABLE);
        intent.setType("video/*");
        intent.putExtra(Intent.EXTRA_MIME_TYPES, new String[]{"video/mp4"});
        startActivityForResult(call, intent, REQUEST_CODE_PICK_FILE);
    }

    @PluginMethod
    public void startServer(PluginCall call) {
        if (server != null) {
            call.reject("Server already running");
            return;
        }
        String fileUriStr = call.getString("fileUri");
        int port = call.getInt("port", 8080);
        if (fileUriStr == null || fileUriStr.isEmpty()) {
            call.reject("Missing fileUri");
            return;
        }

        selectedFileUri = Uri.parse(fileUriStr);
        if (selectedFileUri == null) {
            call.reject("Invalid file URI");
            return;
        }

        selectedFileName = getFileNameFromUri(selectedFileUri);
        localIpAddress = getLocalIpAddress();
        if (localIpAddress == null) {
            call.reject("Could not determine local IP address");
            return;
        }

        serverExecutor = Executors.newSingleThreadExecutor();
        serverExecutor.execute(() -> {
            try {
                server = new HttpServer(port, selectedFileUri, getContext());
                server.start(NanoHTTPD.SOCKET_READ_TIMEOUT, false);
                JSObject result = new JSObject();
                result.put("ip", localIpAddress);
                result.put("port", port);
                call.resolve(result);
            } catch (IOException e) {
                Log.e(TAG, "Server start failed", e);
                call.reject("Server start failed: " + e.getMessage());
                stopServerInternal();
            }
        });
    }

    @PluginMethod
    public void stopServer(PluginCall call) {
        if (server == null) {
            call.reject("Server not running");
            return;
        }
        stopServerInternal();
        call.resolve();
    }

    private void stopServerInternal() {
        if (server != null) {
            server.stop();
            server = null;
        }
        if (serverExecutor != null) {
            serverExecutor.shutdownNow();
            serverExecutor = null;
        }
    }

    @Override
    protected void handleOnActivityResult(int requestCode, int resultCode, Intent data) {
        super.handleOnActivityResult(requestCode, resultCode, data);
        if (requestCode == REQUEST_CODE_PICK_FILE && resultCode == android.app.Activity.RESULT_OK) {
            if (data != null && data.getData() != null) {
                Uri uri = data.getData();
                getContext().getContentResolver().takePersistableUriPermission(
                        uri,
                        Intent.FLAG_GRANT_READ_URI_PERMISSION
                );
                String fileName = getFileNameFromUri(uri);
                JSObject result = new JSObject();
                result.put("uri", uri.toString());
                result.put("name", fileName);
                getSavedCall().resolve(result);
            } else {
                getSavedCall().reject("No file selected");
            }
        }
    }

    private String getFileNameFromUri(Uri uri) {
        String name = null;
        if (uri.getScheme().equals("content")) {
            try (android.database.Cursor cursor = getContext().getContentResolver().query(uri, null, null, null, null)) {
                if (cursor != null && cursor.moveToFirst()) {
                    int nameIndex = cursor.getColumnIndex(DocumentsContract.Document.COLUMN_DISPLAY_NAME);
                    if (nameIndex != -1) {
                        name = cursor.getString(nameIndex);
                    }
                }
            } catch (Exception e) {
                Log.e(TAG, "Error getting file name", e);
            }
        }
        if (name == null) {
            name = uri.getLastPathSegment();
        }
        return name != null ? name : "video.mp4";
    }

    private String getLocalIpAddress() {
        try {
            Enumeration<NetworkInterface> interfaces = NetworkInterface.getNetworkInterfaces();
            while (interfaces.hasMoreElements()) {
                NetworkInterface iface = interfaces.nextElement();
                Enumeration<InetAddress> addresses = iface.getInetAddresses();
                while (addresses.hasMoreElements()) {
                    InetAddress addr = addresses.nextElement();
                    if (!addr.isLoopbackAddress() && addr.getHostAddress().indexOf(':') < 0) {
                        return addr.getHostAddress();
                    }
                }
            }
        } catch (SocketException e) {
            Log.e(TAG, "Wi-Fi IP error", e);
        }
        return null;
    }

    private static class HttpServer extends NanoHTTPD {
        private final Uri fileUri;
        private final android.content.Context context;

        public HttpServer(int port, Uri fileUri, android.content.Context context) {
            super(port);
            this.fileUri = fileUri;
            this.context = context;
        }

        @Override
        public Response serve(IHTTPSession session) {
            String uri = session.getUri();
            Map<String, String> headers = session.getHeaders();

            if (!"GET".equalsIgnoreCase(session.getMethod().toString())) {
                return Response.newFixedLengthResponse(Status.METHOD_NOT_ALLOWED, "text/plain", "Method not allowed");
            }

            try {
                ParcelFileDescriptor pfd = context.getContentResolver().openFileDescriptor(fileUri, "r");
                if (pfd == null) {
                    return Response.newFixedLengthResponse(Status.NOT_FOUND, "text/plain", "File not found");
                }
                long fileSize = pfd.getStatSize();

                String rangeHeader = headers.get("range");
                long start = 0;
                long end = fileSize - 1;
                boolean hasRange = false;

                if (rangeHeader != null && rangeHeader.startsWith("bytes=")) {
                    hasRange = true;
                    String range = rangeHeader.substring(6);
                    int dash = range.indexOf('-');
                    try {
                        if (dash > 0) {
                            start = Long.parseLong(range.substring(0, dash));
                            if (dash < range.length() - 1) {
                                end = Long.parseLong(range.substring(dash + 1));
                            } else {
                                end = fileSize - 1;
                            }
                        } else {
                            long suffix = Long.parseLong(range);
                            start = fileSize - suffix;
                            end = fileSize - 1;
                        }
                    } catch (NumberFormatException e) {
                        // ignore
                    }
                }

                if (start < 0) start = 0;
                if (end >= fileSize) end = fileSize - 1;
                if (start > end) {
                    start = 0;
                    end = fileSize - 1;
                }

                long contentLength = end - start + 1;

                final RandomAccessFile raf = new RandomAccessFile(pfd.getFileDescriptor(), "r");
                raf.seek(start);

                InputStream inputStream = new InputStream() {
                    private long remaining = contentLength;
                    @Override
                    public int read() throws IOException {
                        if (remaining <= 0) return -1;
                        int b = raf.read();
                        if (b != -1) remaining--;
                        return b;
                    }
                    @Override
                    public int read(byte[] b, int off, int len) throws IOException {
                        if (remaining <= 0) return -1;
                        int toRead = (int) Math.min(len, remaining);
                        int read = raf.read(b, off, toRead);
                        if (read > 0) remaining -= read;
                        return read;
                    }
                    @Override
                    public void close() throws IOException {
                        raf.close();
                        pfd.close();
                    }
                };

                Response response;
                if (hasRange) {
                    response = Response.newFixedLengthResponse(Status.PARTIAL_CONTENT, "video/mp4", inputStream, contentLength);
                    response.addHeader("Content-Range", "bytes " + start + "-" + end + "/" + fileSize);
                } else {
                    response = Response.newFixedLengthResponse(Status.OK, "video/mp4", inputStream, fileSize);
                }
                response.addHeader("Accept-Ranges", "bytes");
                response.addHeader("Content-Type", "video/mp4");
                response.addHeader("Content-Length", String.valueOf(contentLength));
                response.addHeader("Cache-Control", "no-cache, no-store, must-revalidate");
                return response;

            } catch (Exception e) {
                Log.e(TAG, "Error serving file", e);
                return Response.newFixedLengthResponse(Status.INTERNAL_ERROR, "text/plain", "Server error: " + e.getMessage());
            }
        }
    }
}