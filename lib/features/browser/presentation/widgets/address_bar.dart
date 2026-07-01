import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/tv_focusable.dart';
import '../providers/browser_provider.dart';

/// Address bar widget for entering URLs and search queries.
/// 
/// Optimized for Android TV with large text and D-pad navigation.
class AddressBar extends StatefulWidget {
  final Function(String) onNavigate;
  final String? initialUrl;

  const AddressBar({
    super.key,
    required this.onNavigate,
    this.initialUrl,
  });

  @override
  State<AddressBar> createState() => _AddressBarState();
}

class _AddressBarState extends State<AddressBar> {
  late TextEditingController _controller;
  final FocusNode _focusNode = FocusNode();
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialUrl ?? '');
    
    _focusNode.addListener(() {
      setState(() {
        _isEditing = _focusNode.hasFocus;
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _handleSubmit() {
    final input = _controller.text.trim();
    if (input.isNotEmpty) {
      widget.onNavigate(input);
      _focusNode.unfocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final browserProvider = Provider.of<BrowserProvider>(context, listen: true);
    
    // Update controller when URL changes from WebView
    if (!_focusNode.hasFocus && browserProvider.url.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_controller.text != browserProvider.url) {
          _controller.text = browserProvider.url;
        }
      });
    }

    return Container(
      height: 64,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _isEditing 
              ? theme.colorScheme.primary 
              : theme.dividerColor,
          width: _isEditing ? 2 : 1,
        ),
      ),
      child: Row(
        children: [
          // URL Input Field
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: TextField(
                controller: _controller,
                focusNode: _focusNode,
                style: const TextStyle(
                  fontSize: 18,
                  color: Colors.white,
                ),
                decoration: InputDecoration(
                  hintText: 'Search or enter address',
                  hintStyle: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 18,
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 20),
                ),
                textInputAction: TextInputAction.go,
                onSubmitted: (_) => _handleSubmit(),
              ),
            ),
          ),
          
          // Go Button (shown when focused or has text)
          if (_isEditing || _controller.text.isNotEmpty)
            TvIconButton(
              icon: Icons.arrow_forward,
              onPressed: _handleSubmit,
              tooltip: 'Go',
            ),
          
          const SizedBox(width: 8),
        ],
      ),
    );
  }
}

/// Navigation controls widget (back, forward, refresh, home).
/// 
/// Displays large, focusable buttons optimized for TV remote navigation.
class NavigationControls extends StatelessWidget {
  const NavigationControls({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final browserProvider = Provider.of<BrowserProvider>(context, listen: true);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Back Button
          TvIconButton(
            icon: Icons.arrow_back,
            onPressed: browserProvider.canGoBack ? browserProvider.goBack : null,
            tooltip: 'Back',
            enabled: browserProvider.canGoBack,
          ),
          
          const SizedBox(width: 8),
          
          // Forward Button
          TvIconButton(
            icon: Icons.arrow_forward,
            onPressed: browserProvider.canGoForward ? browserProvider.goForward : null,
            tooltip: 'Forward',
            enabled: browserProvider.canGoForward,
          ),
          
          const SizedBox(width: 8),
          
          // Refresh Button
          TvIconButton(
            icon: browserProvider.isLoading 
                ? Icons.close 
                : Icons.refresh,
            onPressed: browserProvider.isLoading 
                ? browserProvider.stopLoading 
                : browserProvider.reload,
            tooltip: browserProvider.isLoading ? 'Stop' : 'Refresh',
          ),
          
          const SizedBox(width: 8),
          
          // Home Button
          TvIconButton(
            icon: Icons.home,
            onPressed: browserProvider.goToHome,
            tooltip: 'Home',
          ),
          
          const SizedBox(width: 16),
          
          // Loading Progress Indicator
          if (browserProvider.isLoading)
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: LinearProgressIndicator(
                  value: browserProvider.loadingProgress,
                  backgroundColor: theme.colorScheme.surface,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    theme.colorScheme.primary,
                  ),
                  minHeight: 4,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Browser toolbar combining address bar and navigation controls.
class BrowserToolbar extends StatelessWidget {
  const BrowserToolbar({super.key});

  @override
  Widget build(BuildContext context) {
    final browserProvider = Provider.of<BrowserProvider>(context, listen: true);

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const NavigationControls(),
            AddressBar(
              onNavigate: browserProvider.navigateTo,
              initialUrl: browserProvider.url.isEmpty ? null : browserProvider.url,
            ),
          ],
        ),
      ),
    );
  }
}
