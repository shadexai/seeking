import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/theme/app_theme.dart';

/// Settings screen for browser configuration.
/// 
/// Allows users to customize browser behavior and appearance.
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String _selectedSearchEngine = 'Google';
  bool _javascriptEnabled = true;
  bool _blockPopups = true;
  bool _autoFullscreen = false;
  String _homePage = 'https://www.google.com';

  final List<String> _searchEngines = ['Google', 'Bing', 'DuckDuckGo'];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search Engine Section
            _buildSection(
              title: 'Search Engine',
              children: [
                _buildDropdownSetting(
                  title: 'Default Search Engine',
                  value: _selectedSearchEngine,
                  items: _searchEngines,
                  onChanged: (value) {
                    setState(() {
                      _selectedSearchEngine = value!;
                    });
                  },
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Privacy & Security Section
            _buildSection(
              title: 'Privacy & Security',
              children: [
                _buildSwitchSetting(
                  title: 'Enable JavaScript',
                  subtitle: 'Required for most websites to work properly',
                  value: _javascriptEnabled,
                  onChanged: (value) {
                    setState(() {
                      _javascriptEnabled = value;
                    });
                  },
                ),
                _buildSwitchSetting(
                  title: 'Block Pop-ups',
                  subtitle: 'Prevent unwanted pop-up windows',
                  value: _blockPopups,
                  onChanged: (value) {
                    setState(() {
                      _blockPopups = value;
                    });
                  },
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Appearance Section
            _buildSection(
              title: 'Appearance',
              children: [
                _buildSwitchSetting(
                  title: 'Auto Fullscreen',
                  subtitle: 'Automatically enter fullscreen mode when browsing',
                  value: _autoFullscreen,
                  onChanged: (value) {
                    setState(() {
                      _autoFullscreen = value;
                    });
                  },
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Home Page Section
            _buildSection(
              title: 'Home Page',
              children: [
                _buildTextSetting(
                  title: 'Home Page URL',
                  value: _homePage,
                  onChanged: (value) {
                    setState(() {
                      _homePage = value;
                    });
                  },
                ),
              ],
            ),

            const SizedBox(height: 32),

            // Clear Data Button
            _buildClearDataButton(theme),
          ],
        ),
      ),
    );
  }

  /// Builds a settings section with title and children
  Widget _buildSection({
    required String title,
    required List<Widget> children,
  }) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: theme.textTheme.titleLarge?.copyWith(
            color: theme.colorScheme.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        ...children,
      ],
    );
  }

  /// Builds a dropdown setting widget
  Widget _buildDropdownSetting({
    required String title,
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          DropdownButton<String>(
            value: value,
            dropdownColor: Theme.of(context).colorScheme.surface,
            style: Theme.of(context).textTheme.bodyLarge,
            items: items.map((String item) {
              return DropdownMenuItem<String>(
                value: item,
                child: Text(item),
              );
            }).toList(),
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  /// Builds a switch setting widget
  Widget _buildSwitchSetting({
    required String title,
    String? subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[400],
                      fontSize: 14,
                    ),
                  ),
                ],
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  /// Builds a text input setting widget
  Widget _buildTextSetting({
    required String title,
    required String value,
    required ValueChanged<String> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 12),
          TextField(
            decoration: InputDecoration(
              hintText: 'Enter URL',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            controller: TextEditingController(text: value),
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  /// Builds the clear data button
  Widget _buildClearDataButton(ThemeData theme) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.error.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.error.withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Clear Browsing Data',
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.error,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Clear cache, cookies, and browsing history',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: Colors.grey[400],
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () {
              _showClearDataConfirmation();
            },
            icon: const Icon(Icons.delete_outline),
            label: const Text('Clear Data'),
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.colorScheme.error,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  /// Shows confirmation dialog for clearing data
  void _showClearDataConfirmation() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Clear Browsing Data?'),
          content: const Text(
            'This will clear your cache, cookies, and browsing history. This action cannot be undone.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                // TODO: Implement clear data functionality
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Browsing data cleared')),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.error,
              ),
              child: const Text('Clear'),
            ),
          ],
        );
      },
    );
  }
}
