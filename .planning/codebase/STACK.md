# Technology Stack

**Analysis Date:** 2026-03-27

## Languages

**Primary:**
- Dart 3.11.1+ - All application logic, UI, and business logic

## Runtime

**Environment:**
- Flutter SDK (latest compatible with Dart 3.11.1)

**Package Manager:**
- Pub (Dart package manager)
- Lockfile: `pubspec.lock` present

## Frameworks

**Core:**
- Flutter - Mobile UI framework for iOS, Android, macOS, Windows, Linux, and web platforms

**State Management:**
- Flutter Riverpod 2.6.1 - Reactive state management and dependency injection
- Riverpod Annotation 2.3.0 - Code generation support for Riverpod

**Code Generation:**
- Build Runner 2.4.0 - Build system for generated code
- Freezed 2.4.0 - Immutable data classes and pattern matching
- Freezed Annotation 2.4.0 - Annotations for Freezed code generation
- JSON Serializable 6.7.0 - JSON serialization/deserialization
- JSON Annotation 4.8.0 - Annotations for JSON serialization
- Riverpod Generator 2.3.0 - Code generation for Riverpod providers

**Testing:**
- Flutter Test (SDK integrated) - Unit and widget testing framework

**Development Tools:**
- Flutter Lints 6.0.0 - Linting rules for Flutter/Dart projects

## Key Dependencies

**Critical:**
- Dio 5.3.0 - HTTP client for API communication with interceptor support, timeout configuration, and error handling
- Shared Preferences 2.5.4 - Local key-value storage for persisting favorites data

**Platform Support:**
- Cupertino Icons 1.0.8 - iOS-style icons

**Platform-Specific Storage:**
- shared_preferences_android 2.4.21
- shared_preferences_foundation 2.5.6 (iOS/macOS)
- shared_preferences_linux 2.4.1
- shared_preferences_web 2.4.3
- shared_preferences_windows 2.4.1

## Configuration

**Build Configuration:**
- `pubspec.yaml` - Main dependency and build configuration
- `analysis_options.yaml` - Linter rules (uses flutter_lints package)

**Environment:**
- No environment files required currently
- Base API URL configured in code: `https://api.example.com/api/v1`
- Configuration location: `lib/shared/providers/api_client_provider.dart`

**Entry Point:**
- `lib/main.dart` - Application entry point with Riverpod ProviderScope setup

## Platform Requirements

**Development:**
- Dart SDK 3.11.1+
- Flutter SDK
- IDE: Android Studio, IntelliJ IDEA, VS Code, or similar
- For iOS: Xcode and CocoaPods
- For Android: Android SDK and Android Studio
- For Windows: Visual Studio 2022 or Build Tools

**Production:**
- iOS 11.0+ (from analysis based on Flutter defaults)
- Android API Level 16+
- macOS 10.11+
- Windows 10+
- Linux (GTK 3.0+)
- Web browsers (Chromium-based, Firefox, Safari)

---

*Stack analysis: 2026-03-27*
