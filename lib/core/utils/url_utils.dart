/// URL Utilities for the browser.
/// 
/// Provides helper methods for URL validation, parsing, and manipulation.

class UrlUtils {
  UrlUtils._();

  /// Validates if a string is a valid URL.
  static bool isValidUrl(String url) {
    if (url.isEmpty) return false;
    
    // Handle about: URLs (like about:blank)
    if (url.startsWith('about:')) return true;
    
    try {
      final uri = Uri.parse(url);
      return uri.hasScheme && (uri.scheme == 'http' || uri.scheme == 'https');
    } catch (e) {
      return false;
    }
  }

  /// Ensures the URL has a proper scheme (http/https).
  /// If no scheme is provided, adds https:// by default.
  static String ensureScheme(String url) {
    url = url.trim();
    
    if (url.isEmpty) return '';
    
    // Handle special URLs
    if (url.startsWith('about:') || 
        url.startsWith('file:') || 
        url.startsWith('data:')) {
      return url;
    }
    
    // Check if URL already has a scheme
    if (url.contains('://')) {
      return url;
    }
    
    // Add https:// by default for security
    return 'https://$url';
  }

  /// Extracts domain from URL.
  static String? extractDomain(String url) {
    try {
      final uri = Uri.parse(url);
      return uri.host;
    } catch (e) {
      return null;
    }
  }

  /// Checks if URL is a search query (not a full URL).
  static bool isSearchQuery(String input) {
    input = input.trim();
    
    // Empty input is not a search query
    if (input.isEmpty) return false;
    
    // If it contains spaces, likely a search query
    if (input.contains(' ')) return true;
    
    // If it doesn't contain a dot, likely not a domain
    if (!input.contains('.')) return true;
    
    // If it doesn't start with www. or have a common TLD, might be search
    final commonTlds = ['com', 'org', 'net', 'edu', 'gov', 'io', 'co'];
    final parts = input.split('.');
    if (parts.length >= 2) {
      final tld = parts.last.toLowerCase();
      if (!commonTlds.contains(tld) && tld.length > 3) {
        return true;
      }
    }
    
    return false;
  }

  /// Creates a search URL from a query.
  static String toSearchUrl(String query, {String engine = 'google'}) {
    switch (engine.toLowerCase()) {
      case 'bing':
        return 'https://www.bing.com/search?q=${Uri.encodeComponent(query)}';
      case 'duckduckgo':
        return 'https://duckduckgo.com/?q=${Uri.encodeComponent(query)}';
      case 'google':
      default:
        return 'https://www.google.com/search?q=${Uri.encodeComponent(query)}';
    }
  }

  /// Normalizes URL for display (removes http/https and trailing slashes).
  static String normalizeForDisplay(String url) {
    try {
      final uri = Uri.parse(url);
      
      // Handle special URLs
      if (url.startsWith('about:')) return url;
      
      var display = uri.toString();
      
      // Remove scheme
      display = display.replaceFirst('https://', '');
      display = display.replaceFirst('http://', '');
      
      // Remove trailing slash if it's the only path component
      if (display.endsWith('/') && !display.contains('/', 1)) {
        display = display.substring(0, display.length - 1);
      }
      
      return display;
    } catch (e) {
      return url;
    }
  }

  /// Gets favicon URL from a domain.
  static String getFaviconUrl(String url) {
    final domain = extractDomain(url);
    if (domain != null && domain.isNotEmpty) {
      return 'https://www.google.com/s2/favicons?domain=$domain&sz=64';
    }
    return '';
  }
}
