import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/tv_focusable.dart';

/// Error page widget displayed when a page fails to load.
/// 
/// Shows a user-friendly error message with retry option.
class ErrorPage extends StatelessWidget {
  final String errorMessage;
  final String? url;
  final VoidCallback onRetry;

  const ErrorPage({
    super.key,
    required this.errorMessage,
    this.url,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 600),
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Error Icon
            Icon(
              Icons.cloud_off_outlined,
              size: 80,
              color: theme.colorScheme.error,
            ),
            
            const SizedBox(height: 24),
            
            // Error Title
            Text(
              'Unable to load page',
              style: theme.textTheme.displayMedium?.copyWith(
                color: theme.colorScheme.error,
              ),
              textAlign: TextAlign.center,
            ),
            
            const SizedBox(height: 16),
            
            // URL (if available)
            if (url != null && url!.isNotEmpty)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  url!,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[400],
                    fontSize: 16,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            
            const SizedBox(height: 24),
            
            // Error Message
            Text(
              errorMessage,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: Colors.grey[300],
              ),
              textAlign: TextAlign.center,
            ),
            
            const SizedBox(height: 32),
            
            // Retry Button
            TvButton(
              icon: Icons.refresh,
              label: 'Retry',
              onPressed: onRetry,
            ),
            
            const SizedBox(height: 16),
            
            // Tips
            Text(
              'Tips: Check your internet connection or try a different website',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: Colors.grey[500],
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

/// Loading indicator widget for page loads.
class PageLoadingIndicator extends StatelessWidget {
  final double progress;

  const PageLoadingIndicator({
    super.key,
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Stack(
      children: [
        // Full-width progress bar at top
        LinearProgressIndicator(
          value: progress,
          backgroundColor: theme.colorScheme.surface,
          valueColor: AlwaysStoppedAnimation<Color>(
            theme.colorScheme.primary,
          ),
          minHeight: 3,
        ),
        
        // Center loading spinner for initial load
        if (progress < 0.3)
          Center(
            child: CircularProgressIndicator(
              value: progress,
              valueColor: AlwaysStoppedAnimation<Color>(
                theme.colorScheme.primary,
              ),
              strokeWidth: 4,
            ),
          ),
      ],
    );
  }
}

/// Blank/new tab page widget.
class NewTabPage extends StatelessWidget {
  final Function(String) onNavigate;

  const NewTabPage({
    super.key,
    required this.onNavigate,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // App Logo/Icon
          Icon(
            Icons.public,
            size: 120,
            color: theme.colorScheme.primary.withOpacity(0.8),
          ),
          
          const SizedBox(height: 24),
          
          // Welcome Text
          Text(
            'Seeking Browser',
            style: theme.textTheme.displayLarge?.copyWith(
              color: theme.colorScheme.primary,
            ),
          ),
          
          const SizedBox(height: 8),
          
          Text(
            'Fast & Simple Web Browsing for TV',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: Colors.grey[400],
            ),
          ),
          
          const SizedBox(height: 48),
          
          // Quick Start Button
          TvButton(
            icon: Icons.search,
            label: 'Start Browsing',
            onPressed: () {
              // Focus will move to address bar
              onNavigate('https://www.google.com');
            },
          ),
          
          const SizedBox(height: 24),
          
          // Keyboard hint
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.keyboard,
                size: 20,
                color: Colors.grey[600],
              ),
              const SizedBox(width: 8),
              Text(
                'Use your remote to navigate',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
