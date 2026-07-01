# Seeking Browser - Architecture Documentation

## Overview

Seeking Browser is a modern web browser built specifically for Android TV using Flutter. The application follows Clean Architecture principles with a feature-based folder structure.

## Project Structure

```
lib/
├── main.dart                          # App entry point
├── core/                              # Core functionality shared across features
│   ├── constants/
│   │   └── app_constants.dart         # App-wide constants
│   ├── errors/
│   │   └── exceptions.dart            # Custom exception classes
│   ├── theme/
│   │   └── app_theme.dart             # TV-optimized theme configuration
│   ├── utils/
│   │   └── url_utils.dart             # URL parsing and validation utilities
│   └── widgets/
│       └── tv_focusable.dart          # TV-optimized focusable widgets
├── features/                          # Feature modules
│   ├── browser/                       # Browser feature
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   │   └── browser_page.dart  # Browser page entity
│   │   │   └── repositories/
│   │   │       └── browser_repository.dart  # Repository interface
│   │   ├── data/
│   │   │   └── repositories/
│   │   │       └── webview_browser_repository_impl.dart  # Repository implementation
│   │   └── presentation/
│   │       ├── providers/
│   │       │   └── browser_provider.dart  # State management
│   │       ├── screens/
│   │       │   └── browser_screen.dart    # Main browser screen
│   │       └── widgets/
│   │           ├── address_bar.dart       # URL bar and navigation controls
│   │           └── browser_widgets.dart   # Error page, loading indicator, etc.
│   └── settings/                      # Settings feature
│       └── presentation/
│           └── screens/
│               └── settings_screen.dart   # Settings UI
└── services/                          # Global services (future)
```

## Architecture Layers

### 1. Presentation Layer
- **Screens**: Full-page UI components (BrowserScreen, SettingsScreen)
- **Widgets**: Reusable UI components (AddressBar, TvButton, etc.)
- **Providers**: State management using Provider pattern

### 2. Domain Layer
- **Entities**: Business objects (BrowserPage)
- **Repositories**: Abstract interfaces defining business operations
- **Use Cases**: Business logic operations (to be added)

### 3. Data Layer
- **Repositories**: Concrete implementations of domain interfaces
- **Sources**: Data sources (local storage, remote APIs)

## Key Design Decisions

### 1. TV-First Design
- All UI elements are optimized for D-pad navigation
- Large touch targets (minimum 56x56dp)
- High contrast colors for visibility from distance
- Landscape-only orientation
- Dark theme by default (better for TV viewing)

### 2. Focus Management
- Custom `TvFocusable` widget provides consistent focus states
- Visual feedback: scale animation + border + glow on focus
- Keyboard event handling for remote control buttons

### 3. State Management
- Provider pattern for simple, efficient state management
- BrowserProvider manages all browser-related state
- ChangeNotifier for reactive UI updates

### 4. Error Handling
- Functional approach using `dartz` Either type
- Custom exception hierarchy for type-safe error handling
- User-friendly error pages with retry options

### 5. WebView Integration
- webview_flutter package for rendering web content
- NavigationDelegate for handling page events
- Progress callbacks for loading indicators

## Android TV Optimizations

### Remote Control Support
- Back button: Navigate back in history
- Menu button: Toggle toolbar visibility
- D-pad: Navigate between focusable elements
- Enter/OK: Activate focused element

### UI/UX Considerations
- Font sizes: 18sp minimum for readability
- Spacing: Generous padding for visual clarity
- Animations: Smooth but quick (200-300ms)
- Colors: High contrast, dark background

### Performance
- Lightweight dependencies
- Efficient state updates
- Lazy loading where possible

## Phase 1 Features (Current)

✅ Home screen with browser
✅ URL/Search bar with smart detection
✅ Built-in WebView
✅ Navigation controls (Back, Forward, Refresh, Home)
✅ Loading progress bar
✅ Error page with retry
✅ Full-screen browsing
✅ Settings page (basic)
✅ TV remote optimization
✅ Dark theme

## Phase 2 Features (Planned)

- [ ] Bookmarks management
- [ ] Browsing history
- [ ] Favorites/Quick links
- [ ] Incognito mode
- [ ] Multiple tabs
- [ ] Download manager
- [ ] Search engine selection
- [ ] Voice search
- [ ] User-agent switcher
- [ ] Ad blocking (optional)

## Getting Started

1. Ensure Flutter SDK is installed
2. Run `flutter pub get` to install dependencies
3. Connect Android TV device or emulator
4. Run `flutter run`

## Dependencies

- `webview_flutter`: WebView rendering
- `provider`: State management
- `dartz`: Functional programming (Either type)
- `shared_preferences`: Local storage
- `sqflite`: SQLite database
- `uuid`: Unique ID generation

## Code Quality

- Null safety enabled
- Material 3 design
- Modular and scalable architecture
- Meaningful file names
- Reusable widgets
- Comments for complex logic
