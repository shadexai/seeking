/// Custom exception classes for the application.
/// 
/// These exceptions are used to handle various error scenarios
/// in a type-safe manner throughout the app.

/// Base exception class for all app exceptions
abstract class AppException implements Exception {
  final String message;
  final String? source;

  const AppException(this.message, {this.source});

  @override
  String toString() {
    if (source != null) {
      return '$runtimeType: $message (Source: $source)';
    }
    return '$runtimeType: $message';
  }
}

/// Exception thrown when WebView fails to load a page
class WebViewException extends AppException {
  const WebViewException(super.message, {super.source});
}

/// Exception thrown when URL is invalid
class UrlException extends AppException {
  const UrlException(super.message, {super.source});
}

/// Exception thrown when network operations fail
class NetworkException extends AppException {
  const NetworkException(super.message, {super.source});
}

/// Exception thrown when storage operations fail
class StorageException extends AppException {
  const StorageException(super.message, {super.source});
}

/// Exception thrown when permission is denied
class PermissionException extends AppException {
  const PermissionException(super.message, {super.source});
}
