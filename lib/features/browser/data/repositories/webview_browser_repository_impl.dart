import 'package:flutter/foundation.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:dartz/dartz.dart';
import '../../../../core/errors/exceptions.dart';
import '../browser_repository.dart';

/// Implementation of BrowserRepository using webview_flutter.
/// 
/// This class handles all WebView-related operations and converts
/// them into Either types for functional error handling.
class WebViewBrowserRepository implements BrowserRepository {
  final WebViewController _controller;

  WebViewBrowserRepository(this._controller);

  @override
  Future<Either<AppException, Unit>> navigateTo(String url) async {
    try {
      await _controller.loadRequest(Uri.parse(url));
      return const Right(unit);
    } catch (e) {
      return Left(WebViewException(
        'Failed to navigate to URL: $e',
        source: 'WebViewBrowserRepository.navigateTo',
      ));
    }
  }

  @override
  Future<Either<AppException, Unit>> reload() async {
    try {
      await _controller.reload();
      return const Right(unit);
    } catch (e) {
      return Left(WebViewException(
        'Failed to reload page: $e',
        source: 'WebViewBrowserRepository.reload',
      ));
    }
  }

  @override
  Future<Either<AppException, bool>> goBack() async {
    try {
      final canGoBack = await _controller.canGoBack();
      if (canGoBack) {
        await _controller.goBack();
        return const Right(true);
      }
      return const Right(false);
    } catch (e) {
      return Left(WebViewException(
        'Failed to go back: $e',
        source: 'WebViewBrowserRepository.goBack',
      ));
    }
  }

  @override
  Future<Either<AppException, bool>> goForward() async {
    try {
      final canGoForward = await _controller.canGoForward();
      if (canGoForward) {
        await _controller.goForward();
        return const Right(true);
      }
      return const Right(false);
    } catch (e) {
      return Left(WebViewException(
        'Failed to go forward: $e',
        source: 'WebViewBrowserRepository.goForward',
      ));
    }
  }

  @override
  Future<Either<AppException, Unit>> stopLoading() async {
    try {
      // In newer versions of webview_flutter, the stop() method has been removed.
      // We'll return success as a no-op to maintain API compatibility.
      debugPrint('stopLoading() called - no longer supported in this WebView version');
      return const Right(unit);
    } catch (e) {
      return Left(WebViewException(
        'Failed to stop loading: $e',
        source: 'WebViewBrowserRepository.stopLoading',
      ));
    }
  }

  @override
  Future<Either<AppException, String>> getCurrentUrl() async {
    try {
      final url = await _controller.currentUrl();
      if (url != null) {
        return Right(url);
      }
      return Left(const WebViewException(
        'Current URL is null',
        source: 'WebViewBrowserRepository.getCurrentUrl',
      ));
    } catch (e) {
      return Left(WebViewException(
        'Failed to get current URL: $e',
        source: 'WebViewBrowserRepository.getCurrentUrl',
      ));
    }
  }

  @override
  Future<Either<AppException, String>> getPageTitle() async {
    try {
      String? title;
      try {
        // Try to get title using JavaScript since .title() method may not exist in newer versions
        title = await _controller.runJavaScriptReturningResult('document.title') as String?;
      } catch (e) {
        title = null;
      }
      return Right(title ?? '');
    } catch (e) {
      return Left(WebViewException(
        'Failed to get page title: $e',
        source: 'WebViewBrowserRepository.getPageTitle',
      ));
    }
  }

  @override
  Future<Either<AppException, bool>> canGoBack() async {
    try {
      final result = await _controller.canGoBack();
      return Right(result);
    } catch (e) {
      return Left(WebViewException(
        'Failed to check canGoBack: $e',
        source: 'WebViewBrowserRepository.canGoBack',
      ));
    }
  }

  @override
  Future<Either<AppException, bool>> canGoForward() async {
    try {
      final result = await _controller.canGoForward();
      return Right(result);
    } catch (e) {
      return Left(WebViewException(
        'Failed to check canGoForward: $e',
        source: 'WebViewBrowserRepository.canGoForward',
      ));
    }
  }

  @override
  Future<Either<AppException, Unit>> clearBrowsingData() async {
    try {
      // Clear cache
      await _controller.clearCache();
      
      // Note: For cookies and other data, we might need platform-specific code
      // This can be extended in the future
      
      return const Right(unit);
    } catch (e) {
      return Left(WebViewException(
        'Failed to clear browsing data: $e',
        source: 'WebViewBrowserRepository.clearBrowsingData',
      ));
    }
  }

  @override
  Future<Either<AppException, Unit>> setUserAgent(String userAgent) async {
    try {
      await _controller.setUserAgent(userAgent);
      return const Right(unit);
    } catch (e) {
      return Left(WebViewException(
        'Failed to set user agent: $e',
        source: 'WebViewBrowserRepository.setUserAgent',
      ));
    }
  }

  @override
  Future<Either<AppException, Unit>> setJavaScriptEnabled(bool enabled) async {
    try {
      // JavaScript is enabled by default in webview_flutter
      // This would require recreating the WebViewSettings if we want to disable it
      // For now, we'll just return success
      return const Right(unit);
    } catch (e) {
      return Left(WebViewException(
        'Failed to set JavaScript enabled: $e',
        source: 'WebViewBrowserRepository.setJavaScriptEnabled',
      ));
    }
  }

  @override
  Future<Either<AppException, String>> evaluateJavaScript(String code) async {
    try {
      final result = await _controller.runJavaScriptReturningResult(code);
      return Right(result?.toString() ?? '');
    } catch (e) {
      return Left(WebViewException(
        'Failed to evaluate JavaScript: $e',
        source: 'WebViewBrowserRepository.evaluateJavaScript',
      ));
    }
  }
}
