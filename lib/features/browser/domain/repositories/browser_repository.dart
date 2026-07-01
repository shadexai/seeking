import 'package:dartz/dartz.dart';
import '../../../../core/errors/exceptions.dart';

/// Abstract repository interface for browser operations.
/// 
/// This defines the contract that all browser repository implementations must follow.
/// The actual implementation will be in the data layer.
abstract class BrowserRepository {
  /// Navigates to the specified URL.
  Future<Either<AppException, Unit>> navigateTo(String url);

  /// Reloads the current page.
  Future<Either<AppException, Unit>> reload();

  /// Goes back in browser history.
  Future<Either<AppException, bool>> goBack();

  /// Goes forward in browser history.
  Future<Either<AppException, bool>> goForward();

  /// Stops loading the current page.
  Future<Either<AppException, Unit>> stopLoading();

  /// Gets the current URL.
  Future<Either<AppException, String>> getCurrentUrl();

  /// Gets the current page title.
  Future<Either<AppException, String>> getPageTitle();

  /// Checks if back navigation is possible.
  Future<Either<AppException, bool>> canGoBack();

  /// Checks if forward navigation is possible.
  Future<Either<AppException, bool>> canGoForward();

  /// Clears browsing data (cache, cookies, etc.).
  Future<Either<AppException, Unit>> clearBrowsingData();

  /// Sets a custom user agent.
  Future<Either<AppException, Unit>> setUserAgent(String userAgent);

  /// Enables or disables JavaScript.
  Future<Either<AppException, Unit>> setJavaScriptEnabled(bool enabled);

  /// Evaluates JavaScript on the current page.
  Future<Either<AppException, String>> evaluateJavaScript(String code);
}
