import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_theme.dart';
import '../providers/browser_provider.dart';
import '../widgets/address_bar.dart';
import '../widgets/browser_widgets.dart';

/// Main browser screen containing WebView and navigation controls.
/// 
/// This is the primary browsing interface optimized for Android TV.
class BrowserScreen extends StatefulWidget {
  final String? initialUrl;

  const BrowserScreen({
    super.key,
    this.initialUrl,
  });

  @override
  State<BrowserScreen> createState() => _BrowserScreenState();
}

class _BrowserScreenState extends State<BrowserScreen> {
  late WebViewController _controller;
  bool _showToolbar = true;
  bool _isFullscreen = false;

  @override
  void initState() {
    super.initState();
    
    // Initialize WebView with Android-specific settings
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.black)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            // Page loading started
          },
          onPageFinished: (String url) {
            // Page loading finished
          },
          onWebResourceError: (WebResourceError error) {
            // Handle web resource errors
            debugPrint('WebView Error: ${error.description}');
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.initialUrl ?? 'https://www.google.com'));
  }

  /// Toggle toolbar visibility
  void _toggleToolbar() {
    setState(() {
      _showToolbar = !_showToolbar;
    });
  }

  /// Handle remote key events for TV navigation
  Future<bool> _handleKeyEvent(KeyEvent event) async {
    // Only handle key down events
    if (event is! KeyDownEvent) return false;

    // Handle back button
    if (event.logicalKey == LogicalKeyboardKey.back ||
        event.logicalKey == LogicalKeyboardKey.goBack) {
      final provider = Provider.of<BrowserProvider>(context, listen: false);
      if (provider.canGoBack) {
        provider.goBack();
        return true;
      }
    }

    // Handle menu/settings button
    if (event.logicalKey == LogicalKeyboardKey.contextMenu) {
      _toggleToolbar();
      return true;
    }

    return false;
  }

  @override
  Widget build(BuildContext context) {
    return KeyboardListener(
      focusNode: FocusNode()..requestFocus(),
      onKeyEvent: (KeyEvent event) async {
        await _handleKeyEvent(event);
      },
      child: BrowserProviderWidget(
        controller: _controller,
        child: Consumer<BrowserProvider>(
          builder: (context, provider, child) {
            return Stack(
              children: [
                // WebView
                Positioned.fill(
                  child: WebViewWidget(
                    controller: _controller,
                  ),
                ),

                // Loading Progress Overlay
                if (provider.isLoading && provider.loadingProgress < 1.0)
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    child: PageLoadingIndicator(
                      progress: provider.loadingProgress,
                    ),
                  ),

                // Error Page Overlay
                if (provider.errorMessage != null)
                  Positioned.fill(
                    child: Container(
                      color: Theme.of(context).colorScheme.background,
                      child: ErrorPage(
                        errorMessage: provider.errorMessage!,
                        url: provider.url,
                        onRetry: provider.reload,
                      ),
                    ),
                  ),

                // Toolbar (slides in/out)
                AnimatedSlide(
                  offset: _showToolbar ? Offset.zero : const Offset(0, -1.2),
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  child: Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    child: const BrowserToolbar(),
                  ),
                ),

                // Fullscreen toggle hint (when in fullscreen)
                if (_isFullscreen && !_showToolbar)
                  Positioned(
                    bottom: 16,
                    right: 16,
                    child: Opacity(
                      opacity: 0.5,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.black54,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.fullscreen_exit,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }

  @override
  void dispose() {
    // Clean up if needed
    super.dispose();
  }
}
