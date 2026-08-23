package com.shade.seeking.plugin;

import android.content.Intent;
import android.net.Uri;
import android.os.ParcelFileDescriptor;
import android.provider.DocumentsContract;
import android.util.Log;

import com.getcapacitor.JSObject;
import com.getcapacitor.Plugin;
import com.getcapacitor.PluginCall;
import com.getcapacitor.PluginMethod;
import com.getcapacitor.annotation.CapacitorPlugin;

import java.io.BufferedReader;
import java.io.FileInputStream;
import java.io.IOException;
import java.io.InputStreamReader;
import java.io.OutputStream;
import java.net.InetAddress;
import java.net.NetworkInterface;
import java.net.ServerSocket;
import java.net.Socket;
import java.net.SocketException;
import java.util.Enumeration;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;

@CapacitorPlugin(name = "LocalStream")
public class HttpServerPlugin extends Plugin {

    private static final String TAG = "HttpServerPlugin";
    private static final int REQUEST_CODE_PICK_FILE = 1001;

    private ServerSocket serverSocket;
    private ExecutorService executor;
    private Uri selectedFileUri;
    private volatile boolean running = false;
    private PluginCall savedPickCall; // manual save instead of getSavedCall()

    @PluginMethod
    public void pickFile(PluginCall call) {
        saveCall(call); // Capacitor 6 way
        savedPickCall = call;
        Intent intent = new Intent(Intent.ACTION_OPEN_DOCUMENT);
        intent.addCategory(Intent.CATEGORY_OPENABLE);
        intent.setType("video/*");
        intent.putExtra(Intent.EXTRA_MIME_TYPES, new String[]{"video/mp4"});
        startActivityForResult(call, intent, REQUEST_CODE_PICK_FILE);
    }

    @PluginMethod
    public void startServer(PluginCall call) {
        if (running) {
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

        String ip = getLocalIpAddress();
        if (ip == null) {
            call.reject("Could not determine local IP address");
            return;
        }

        try {
            serverSocket = new ServerSocket(port);
            running = true;
            executor = Executors.newCachedThreadPool();

            executor.execute(() -> {
                while (running) {
                    try {
                        Socket client = serverSocket.accept();
                        executor.execute(() -> handleClient(client));
                    } catch (IOException e) {
                        if (running) Log.e(TAG, "Accept error", e);
                    }
                }
            });

            JSObject result = new JSObject();
            result.put("ip", ip);
            result.put("port", port);
            call.resolve(result);

        } catch (IOException e) {
            call.reject("Server start failed: " + e.getMessage());
        }
    }

    @PluginMethod
    public void stopServer(PluginCall call) {
        stopServerInternal();
        call.resolve();
    }

    private void stopServerInternal() {
        running = false;
        if (serverSocket != null) {
            try { serverSocket.close(); } catch (IOException ignored) {}
            serverSocket = null;
        }
        if (executor != null) {
            executor.shutdownNow();
            executor = null;
        }
    }

    private void handleClient(Socket client) {
        try {
            BufferedReader reader = new BufferedReader(new InputStreamReader(client.getInputStream()));
            OutputStream out = client.getOutputStream();

            String requestLine = reader.readLine();
            if (requestLine == null) { client.close(); return; }
            Log.d(TAG, "Request: " + requestLine);

            long rangeStart = -1;
            long rangeEnd = -1;
            String line;
            while ((line = reader.readLine()) != null && !line.isEmpty()) {
                if (line.toLowerCase().startsWith("range: bytes=")) {
                    String range = line.substring(13).trim();
                    int dash = range.indexOf('-');
                    try {
                        if (dash > 0) {
                            rangeStart = Long.parseLong(range.substring(0, dash).trim());
                            String endStr = range.substring(dash + 1).trim();
                            if (!endStr.isEmpty()) rangeEnd = Long.parseLong(endStr);
                        }
                    } catch (NumberFormatException ignored) {}
                }
            }

            if (!requestLine.startsWith("GET")) {
                out.write("HTTP/1.1 405 Method Not Allowed\r\n\r\n".getBytes());
                client.close();
                return;
            }

            ParcelFileDescriptor pfd = getContext().getContentResolver()
                    .openFileDescriptor(selectedFileUri, "r");
            if (pfd == null) {
                out.write("HTTP/1.1 404 Not Found\r\n\r\n".getBytes());
                client.close();
                return;
            }

            long fileSize = pfd.getStatSize();
            long start = (rangeStart >= 0) ? rangeStart : 0;
            long end = (rangeEnd >= 0) ? rangeEnd : fileSize - 1;
            if (end >= fileSize) end = fileSize - 1;
            long contentLength = end - start + 1;
            boolean isRange = rangeStart >= 0;

            StringBuilder headers = new StringBuilder();
            if (isRange) {
                headers.append("HTTP/1.1 206 Partial Content\r\n");
                headers.append("Content-Range: bytes ").append(start).append("-")
                        .append(end).append("/").append(fileSize).append("\r\n");
            } else {
                headers.append("HTTP/1.1 200 OK\r\n");
            }
            headers.append("Content-Type: video/mp4\r\n");
            headers.append("Content-Length: ").append(contentLength).append("\r\n");
            headers.append("Accept-Ranges: bytes\r\n");
            headers.append("Cache-Control: no-cache\r\n");
            headers.append("Connection: close\r\n");
            headers.append("\r\n");
            out.write(headers.toString().getBytes());

            FileInputStream fis = new FileInputStream(pfd.getFileDescriptor());
            if (start > 0) fis.skip(start);

            byte[] buf = new byte[65536];
            long remaining = contentLength;
            int read;
            while (remaining > 0 &&
                    (read = fis.read(buf, 0, (int) Math.min(buf.length, remaining))) != -1) {
                out.write(buf, 0, read);
                remaining -= read;
            }
            out.flush();
            fis.close();
            pfd.close();
            client.close();

        } catch (Exception e) {
            Log.e(TAG, "Error handling client", e);
            try { client.close(); } catch (IOException ignored) {}
        }
    }

    @Override
    protected void handleOnActivityResult(int requestCode, int resultCode, Intent data) {
        super.handleOnActivityResult(requestCode, resultCode, data);
        if (requestCode != REQUEST_CODE_PICK_FILE) return;

        PluginCall call = savedPickCall;
        if (call == null) {
            Log.e(TAG, "savedPickCall is null");
            return;
        }

        if (resultCode == android.app.Activity.RESULT_OK && data != null && data.getData() != null) {
            Uri uri = data.getData();
            getContext().getContentResolver().takePersistableUriPermission(
                    uri, Intent.FLAG_GRANT_READ_URI_PERMISSION);
            String fileName = getFileNameFromUri(uri);
            JSObject result = new JSObject();
            result.put("uri", uri.toString());
            result.put("name", fileName);
            call.resolve(result);
        } else {
            call.reject("No file selected");
        }
        savedPickCall = null;
    }

    private String getFileNameFromUri(Uri uri) {
        String name = null;
        if ("content".equals(uri.getScheme())) {
            try (android.database.Cursor cursor = getContext().getContentResolver()
                    .query(uri, null, null, null, null)) {
                if (cursor != null && cursor.moveToFirst()) {
                    int idx = cursor.getColumnIndex(DocumentsContract.Document.COLUMN_DISPLAY_NAME);
                    if (idx != -1) name = cursor.getString(idx);
                }
            } catch (Exception e) {
                Log.e(TAG, "Error getting file name", e);
            }
        }
        if (name == null) name = uri.getLastPathSegment();
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
            Log.e(TAG, "IP error", e);
        }
        return null;
    }
}
