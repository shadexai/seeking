/// Browser entity representing a single browsing session/page.
/// 
/// This is a domain entity that represents the state of a browser page.

class BrowserPage {
  final String id;
  final String url;
  final String title;
  final DateTime createdAt;
  final DateTime? lastVisitedAt;
  final bool isLoading;
  final double loadingProgress;
  final String? errorMessage;
  final String? faviconUrl;

  const BrowserPage({
    required this.id,
    required this.url,
    this.title = '',
    required this.createdAt,
    this.lastVisitedAt,
    this.isLoading = false,
    this.loadingProgress = 0.0,
    this.errorMessage,
    this.faviconUrl,
  });

  /// Creates a copy of this BrowserPage with updated fields.
  BrowserPage copyWith({
    String? id,
    String? url,
    String? title,
    DateTime? createdAt,
    DateTime? lastVisitedAt,
    bool? isLoading,
    double? loadingProgress,
    String? errorMessage,
    String? faviconUrl,
  }) {
    return BrowserPage(
      id: id ?? this.id,
      url: url ?? this.url,
      title: title ?? this.title,
      createdAt: createdAt ?? this.createdAt,
      lastVisitedAt: lastVisitedAt ?? this.lastVisitedAt,
      isLoading: isLoading ?? this.isLoading,
      loadingProgress: loadingProgress ?? this.loadingProgress,
      errorMessage: errorMessage ?? this.errorMessage,
      faviconUrl: faviconUrl ?? this.faviconUrl,
    );
  }

  /// Creates a BrowserPage from JSON.
  factory BrowserPage.fromJson(Map<String, dynamic> json) {
    return BrowserPage(
      id: json['id'] as String,
      url: json['url'] as String,
      title: json['title'] as String? ?? '',
      createdAt: DateTime.parse(json['created_at'] as String),
      lastVisitedAt: json['last_visited_at'] != null
          ? DateTime.parse(json['last_visited_at'] as String)
          : null,
      isLoading: json['is_loading'] as bool? ?? false,
      loadingProgress: (json['loading_progress'] as num?)?.toDouble() ?? 0.0,
      errorMessage: json['error_message'] as String?,
      faviconUrl: json['favicon_url'] as String?,
    );
  }

  /// Converts BrowserPage to JSON.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'url': url,
      'title': title,
      'created_at': createdAt.toIso8601String(),
      'last_visited_at': lastVisitedAt?.toIso8601String(),
      'is_loading': isLoading,
      'loading_progress': loadingProgress,
      'error_message': errorMessage,
      'favicon_url': faviconUrl,
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is BrowserPage &&
        other.id == id &&
        other.url == url &&
        other.title == title;
  }

  @override
  int get hashCode => Object.hash(id, url, title);

  @override
  String toString() {
    return 'BrowserPage(id: $id, url: $url, title: $title)';
  }
}
