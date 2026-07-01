import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/tv_focusable.dart';
import '../../../../core/utils/url_utils.dart';
import '../../domain/entities/browser_page.dart';

/// Provider for managing browser state and operations.
/// 
/// This provider handles all browser-related state including:
/// - Current page URL and title
/// - Loading progress
/// - Navigation history (back/forward)
/// - Error states
class BrowserProvider extends ChangeNotifier {
  final WebViewController _controller;
  late BrowserPage _currentPage;
  bool _canGoBack = false;
  bool _canGoForward = false;
  bool _isFullscreen = false;
  String _searchEngine = 'google';

  BrowserProvider(this._controller) {
    _currentPage = BrowserPage(
      id: const Uuid().v4(),
      url: 'about:blank',
      createdAt: DateTime.now(),
    );
    
    _setupWebViewListeners();
  }

  void _setupWebViewListeners() {
    _controller.setNavigationDelegate(
      NavigationDelegate(
        onPageStarted: (String url) {
          _currentPage = _currentPage.copyWith(
            url: url,
            isLoading: true,
            loadingProgress: 0.0,
            errorMessage: null, // Clear any previous errors
          );
          notifyListeners();
        },
        onPageFinished: (String url) {
          _updatePageInfo();
        },
        onWebResourceError: (WebResourceError error) {
          // Only show error page for actual navigation errors, not cache issues
          _currentPage = _currentPage.copyWith(
            isLoading: false,
            loadingProgress: 1.0,
            errorMessage: error.description,
          );
          notifyListeners();
        },
        onProgress: (int progress) {
          _currentPage = _currentPage.copyWith(
            loadingProgress: progress / 100.0,
          );
          notifyListeners();
        },
        onNavigationRequest: (NavigationRequest request) {
          // Allow all navigation by default
          // Could be extended to block certain URLs or implement ad blocking
          return NavigationDecision.navigate;
        },
      ),
    );
  }

  Future<void> _updatePageInfo() async {
    try {
      final urlResult = await _controller.currentUrl();
      final canGoBackResult = await _controller.canGoBack();
      final canGoForwardResult = await _controller.canGoForward();

      String? titleResult;
      try {
        // Try to get title using JavaScript since .title() method may not exist
        titleResult = await _controller.runJavaScriptReturningResult('document.title') as String?;
      } catch (e) {
        titleResult = null;
      }

      _currentPage = _currentPage.copyWith(
        url: urlResult ?? _currentPage.url,
        title: titleResult ?? '',
        isLoading: false,
        loadingProgress: 1.0,
        lastVisitedAt: DateTime.now(),
        faviconUrl: urlResult != null ? UrlUtils.getFaviconUrl(urlResult) : null,
      );

      _canGoBack = canGoBackResult;
      _canGoForward = canGoForwardResult;
    } catch (e) {
      // Handle any errors gracefully
      debugPrint('Error updating page info: $e');
    }

    notifyListeners();
  }

  // Getters
  BrowserPage get currentPage => _currentPage;
  String get url => _currentPage.url;
  String get title => _currentPage.title;
  bool get isLoading => _currentPage.isLoading;
  double get loadingProgress => _currentPage.loadingProgress;
  String? get errorMessage => _currentPage.errorMessage;
  bool get canGoBack => _canGoBack;
  bool get canGoForward => _canGoForward;
  bool get isFullscreen => _isFullscreen;
  String get searchEngine => _searchEngine;
  WebViewController get controller => _controller;

  /// Navigate to a URL or search query
  Future<void> navigateTo(String input) async {
    String targetUrl;
    
    if (UrlUtils.isValidUrl(input)) {
      targetUrl = UrlUtils.ensureScheme(input);
    } else if (UrlUtils.isSearchQuery(input)) {
      targetUrl = UrlUtils.toSearchUrl(input, engine: _searchEngine);
    } else {
      // Try as domain name
      targetUrl = UrlUtils.ensureScheme(input);
    }

    await _controller.loadRequest(Uri.parse(targetUrl));
  }

  /// Reload current page
  Future<void> reload() async {
    await _controller.reload();
  }

  /// Go back in history
  Future<void> goBack() async {
    if (_canGoBack) {
      await _controller.goBack();
    }
  }

  /// Go forward in history
  Future<void> goForward() async {
    if (_canGoForward) {
      await _controller.goForward();
    }
  }

  /// Stop loading
  Future<void> stopLoading() async {
    // In newer versions of webview_flutter, we can just reload or do nothing
    // The stop() method has been removed in favor of letting pages load naturally
    // This is a no-op to maintain API compatibility
    debugPrint('stopLoading() called - no longer supported in this WebView version');
  }

  /// Navigate to home page
  Future<void> goToHome() async {
    await navigateTo('https://www.google.com');
  }

  /// Toggle fullscreen mode
  void toggleFullscreen() {
    _isFullscreen = !_isFullscreen;
    notifyListeners();
  }

  /// Set search engine
  void setSearchEngine(String engine) {
    _searchEngine = engine;
    notifyListeners();
  }

  /// Clear browsing data
  Future<void> clearBrowsingData() async {
    await _controller.clearCache();
    // Reset to blank page
    await _controller.loadRequest(Uri.parse('about:blank'));
  }
}

/// Widget that provides browser provider to its descendants
class BrowserProviderWidget extends StatelessWidget {
  final WebViewController controller;
  final Widget child;

  const BrowserProviderWidget({
    super.key,
    required this.controller,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => BrowserProvider(controller),
      child: child,
    );
  }
}
