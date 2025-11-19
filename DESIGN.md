# TalkLens iOS App - Design Document

## Table of Contents
1. [Overview](#overview)
2. [Goals and Requirements](#goals-and-requirements)
3. [Architecture](#architecture)
4. [Technology Stack](#technology-stack)
5. [UI/UX Design](#uiux-design)
6. [Module Design](#module-design)
7. [Data Flow](#data-flow)
8. [Implementation Phases](#implementation-phases)
9. [Future Enhancements](#future-enhancements)

---

## Overview

**TalkLens** is an iOS application that provides on-device document translation capabilities. The app enables users to translate documents between foreign languages and English using device-local machine learning models, ensuring privacy and offline functionality.

### Key Features
- Multi-page document scanning with live camera
- Translation from image files stored on device
- Bidirectional translation (Foreign Language ↔ English)
- Configurable language preferences
- Completely on-device processing (no cloud dependency)
- Tab-based navigation for intuitive user experience

---

## Goals and Requirements

### Functional Requirements
1. **Document Scanning**: Capture multiple pages using device camera with auto-detection
2. **Image Translation**: Process existing images/PDFs from device storage
3. **Text Recognition**: Extract text from images using OCR
4. **Translation**: Translate extracted text between language pairs
5. **Settings Management**: Configure source/target languages and app preferences
6. **Result Display**: Show original and translated text with formatting preservation

### Non-Functional Requirements
1. **Privacy**: All processing happens on-device
2. **Performance**: Real-time text detection, translation within 2-3 seconds per page
3. **Usability**: Intuitive interface suitable for all age groups
4. **Offline Support**: Full functionality without internet connection
5. **Accessibility**: Support VoiceOver and Dynamic Type
6. **Storage**: Efficient caching of models and translation history

---

## Architecture

### Design Principles
- **Modular**: Clear separation of concerns with well-defined module boundaries
- **MVVM Pattern**: Model-View-ViewModel architecture for SwiftUI
- **Protocol-Oriented**: Use protocols for dependency injection and testability
- **Reactive**: Combine framework for data flow and state management
- **Async/Await**: Modern concurrency for ML operations

### High-Level Architecture

```
┌─────────────────────────────────────────────────────────┐
│                    Presentation Layer                    │
│  (SwiftUI Views + ViewModels)                           │
│  - CameraView, LibraryView, SettingsView                │
└────────────────┬────────────────────────────────────────┘
                 │
┌────────────────┴────────────────────────────────────────┐
│                   Business Logic Layer                   │
│  - TranslationService                                    │
│  - DocumentProcessor                                     │
│  - LanguageManager                                       │
└────────────────┬────────────────────────────────────────┘
                 │
┌────────────────┴────────────────────────────────────────┐
│                      Core Services                       │
│  - OCRService (Text Recognition)                        │
│  - TranslationEngine (ML Translation)                   │
│  - CameraService (Image Capture)                        │
│  - StorageService (Persistence)                         │
└────────────────┬────────────────────────────────────────┘
                 │
┌────────────────┴────────────────────────────────────────┐
│                    Infrastructure Layer                  │
│  - Google MLKit Vision SDK                              │
│  - Google MLKit Translation SDK                         │
│  - Core Data / UserDefaults                             │
│  - File Manager                                          │
└─────────────────────────────────────────────────────────┘
```

---

## Technology Stack

### Core Frameworks
- **SwiftUI**: UI framework for declarative interface
- **Combine**: Reactive programming for data flow
- **AVFoundation**: Camera access and image capture
- **Vision**: Apple's computer vision framework (fallback)
- **PhotosUI**: Photo library access

### Machine Learning SDKs
1. **Google MLKit Vision** (Primary)
   - Text Recognition v2 (supports 100+ languages)
   - Document scanning with auto-detect
   - On-device processing

2. **Google MLKit Translation** (Primary)
   - 59 language support
   - Downloadable language models (~30-40 MB each)
   - Neural machine translation

3. **Apple CoreML** (Alternative/Fallback)
   - Custom translation models
   - Vision framework for OCR

### Data Persistence
- **UserDefaults**: App settings and preferences
- **Core Data**: Translation history (optional)
- **FileManager**: Cached models and temporary files

### Dependencies (CocoaPods/SPM)
```
- GoogleMLKit/TextRecognition
- GoogleMLKit/Translate
- GoogleMLKit/LanguageID
```

---

## UI/UX Design

### Tab Structure

```
┌─────────────────────────────────────────────────────────┐
│                    TalkLens App                         │
└─────────────────────────────────────────────────────────┘
         │
         ├─── Tab 1: Camera Scan 📷
         │    └─── Multi-page document scanning
         │
         ├─── Tab 2: Library 🖼️
         │    └─── Import from Photos/Files
         │
         └─── Tab 3: Settings ⚙️
              └─── Language & preferences
```

### Tab 1: Camera Scan View

**Purpose**: Capture multiple pages of documents for translation

**UI Components**:
- Full-screen camera preview
- Document edge detection overlay (green/yellow/red)
- Auto-capture indicator
- Manual capture button
- Page counter (e.g., "Page 1 of 5")
- Thumbnail strip at bottom showing captured pages
- "Process & Translate" button
- Flash toggle
- Cancel/Done buttons

**User Flow**:
1. User opens camera tab
2. Points camera at document
3. App detects document edges automatically
4. Auto-captures or user taps capture button
5. Thumbnail appears in bottom strip
6. Repeat for multiple pages
7. Tap "Translate" to process all pages
8. Navigate to results view

### Tab 2: Library View

**Purpose**: Translate documents from existing images/files

**UI Components**:
- Recent translations list (cards with preview)
- "Import Image" button
- "Import PDF" button
- Search bar (for history)
- Each item shows:
  - Thumbnail
  - Source language
  - Date
  - Page count
  - Translation status

**User Flow**:
1. User taps import button
2. Photo picker or file picker opens
3. User selects image(s) or PDF
4. App processes and displays results
5. Translation saved to history

### Tab 3: Settings View

**Purpose**: Configure app preferences

**Sections**:
1. **Translation Settings**
   - Source Language (dropdown)
   - Target Language (dropdown)
   - Auto-detect language (toggle)
   - Translation direction toggle

2. **Camera Settings**
   - Auto-capture (toggle)
   - Document edge detection sensitivity
   - Flash default setting
   - Image quality (High/Medium)

3. **Downloaded Models**
   - List of installed language models
   - Download/Delete buttons
   - Storage space indicator

4. **General**
   - Translation history (toggle)
   - Keep original images (toggle)
   - Clear cache
   - App version

5. **About**
   - Privacy policy
   - Terms of service
   - Licenses

### First-Time Setup / Onboarding

**Purpose**: Guide users through initial app configuration and essential model downloads

**Trigger**: Displayed on first launch or when required language models are not downloaded

**UI Components**:
- Welcome screen with app introduction
- Language pair selection (Source → Target)
- Model download screen with:
  - Language model size information
  - Download progress indicator
  - Wi-Fi/Cellular warning
  - "Download Now" or "Download Later" options
- Quick tutorial (3-4 slides)
  - How to scan documents
  - How to import from library
  - How to change languages
- Permission requests (Camera, Photo Library)
- "Get Started" button

**User Flow**:
1. User launches app for the first time
2. Welcome screen appears with app logo and tagline
3. Language selection screen:
   - "Select your primary language pair"
   - Dropdown for source language (default: auto-detect)
   - Dropdown for target language (default: English)
   - Popular pairs suggested (e.g., Spanish↔English, French↔English)
4. Model download screen:
   - "Download required models to get started"
   - Shows selected language pair models
   - Displays total size (e.g., "60 MB for English + Spanish")
   - Network warning if on cellular
   - Download button starts download
   - Progress bar shows download status
   - Skip option: "Download Later" (takes user to main app with limited functionality)
5. Optional tutorial carousel (can be skipped)
6. Permission requests presented in context
7. "Get Started" → Navigate to main tab view

**State Management**:
- `UserDefaults` key: `hasCompletedOnboarding`
- `UserDefaults` key: `requiredModelsDownloaded`
- Check on app launch: if either is `false`, show setup flow

**Skip Behavior**:
- User can skip model download
- App shows limited functionality message in tabs
- Prompt to download models when attempting translation
- "Complete Setup" banner in Settings tab

### Results View (Modal/Push)

**UI Components**:
- Side-by-side or tabbed view
- Original text on left/top
- Translated text on right/bottom
- Copy button for each section
- Share button
- Save to Files
- Language indicators
- Page navigation (for multi-page)

---

## Module Design

### 1. Core Modules

#### 1.1 Models
```swift
// Models/Document.swift
struct Document: Identifiable, Codable {
    let id: UUID
    var pages: [DocumentPage]
    let sourceLanguage: Language
    let targetLanguage: Language
    let createdAt: Date
    var status: ProcessingStatus
}

// Models/DocumentPage.swift
struct DocumentPage: Identifiable, Codable {
    let id: UUID
    let imageData: Data
    var recognizedText: String?
    var translatedText: String?
    let pageNumber: Int
}

// Models/Language.swift
struct Language: Codable, Hashable {
    let code: String // ISO 639-1
    let name: String
    let isDownloaded: Bool
}

// Models/ProcessingStatus.swift
enum ProcessingStatus: String, Codable {
    case pending
    case recognizing
    case translating
    case completed
    case failed
}
```

#### 1.2 Services

##### OCRService
```swift
// Services/OCR/OCRServiceProtocol.swift
protocol OCRServiceProtocol {
    func recognizeText(
        in image: UIImage,
        language: Language?
    ) async throws -> RecognizedText
}

// Services/OCR/MLKitOCRService.swift
class MLKitOCRService: OCRServiceProtocol {
    // Implementation using Google MLKit Text Recognition
}

// Services/OCR/VisionOCRService.swift
class VisionOCRService: OCRServiceProtocol {
    // Fallback using Apple Vision framework
}
```

##### TranslationService
```swift
// Services/Translation/TranslationServiceProtocol.swift
protocol TranslationServiceProtocol {
    func translate(
        text: String,
        from: Language,
        to: Language
    ) async throws -> String

    func downloadModel(for language: Language) async throws
    func deleteModel(for language: Language) throws
    func isModelDownloaded(for language: Language) -> Bool
}

// Services/Translation/MLKitTranslationService.swift
class MLKitTranslationService: TranslationServiceProtocol {
    // Implementation using Google MLKit Translation
}
```

##### CameraService
```swift
// Services/Camera/CameraServiceProtocol.swift
protocol CameraServiceProtocol {
    var framePublisher: AnyPublisher<UIImage, Never> { get }
    func startSession()
    func stopSession()
    func capturePhoto() async throws -> UIImage
    func toggleFlash()
}

// Services/Camera/AVCameraService.swift
class AVCameraService: CameraServiceProtocol {
    // Implementation using AVFoundation
}
```

##### DocumentProcessorService
```swift
// Services/DocumentProcessor.swift
class DocumentProcessor {
    private let ocrService: OCRServiceProtocol
    private let translationService: TranslationServiceProtocol

    func processDocument(
        _ document: Document
    ) async throws -> Document {
        // Orchestrates OCR + Translation pipeline
    }
}
```

##### LanguageManager
```swift
// Services/LanguageManager.swift
class LanguageManager: ObservableObject {
    @Published var sourceLanguage: Language
    @Published var targetLanguage: Language
    @Published var availableLanguages: [Language]
    @Published var downloadedLanguages: [Language]

    func swapLanguages()
    func updateDownloadedLanguages()
}
```

##### StorageService
```swift
// Services/Storage/StorageServiceProtocol.swift
protocol StorageServiceProtocol {
    func saveDocument(_ document: Document) throws
    func fetchDocuments() throws -> [Document]
    func deleteDocument(_ id: UUID) throws
}

// Services/Storage/UserDefaultsStorageService.swift
class UserDefaultsStorageService: StorageServiceProtocol {
    // Simple implementation for settings
}

// Services/Storage/FileStorageService.swift
class FileStorageService: StorageServiceProtocol {
    // Implementation for document persistence
}
```

#### 1.3 ViewModels

##### CameraViewModel
```swift
// ViewModels/CameraViewModel.swift
@MainActor
class CameraViewModel: ObservableObject {
    @Published var capturedPages: [DocumentPage] = []
    @Published var isProcessing = false
    @Published var processingProgress: Double = 0.0
    @Published var error: AppError?

    private let cameraService: CameraServiceProtocol
    private let documentProcessor: DocumentProcessor
    private let languageManager: LanguageManager

    func captureImage()
    func deletePageToProcess()
    func translate() async
}
```

##### LibraryViewModel
```swift
// ViewModels/LibraryViewModel.swift
@MainActor
class LibraryViewModel: ObservableObject {
    @Published var documents: [Document] = []
    @Published var isLoading = false
    @Published var selectedDocument: Document?

    private let storageService: StorageServiceProtocol
    private let documentProcessor: DocumentProcessor

    func loadDocuments()
    func importImages(_ images: [UIImage])
    func deleteDocument(_ id: UUID)
    func searchDocuments(query: String)
}
```

##### SettingsViewModel
```swift
// ViewModels/SettingsViewModel.swift
@MainActor
class SettingsViewModel: ObservableObject {
    @Published var settings: AppSettings

    private let languageManager: LanguageManager
    private let translationService: TranslationServiceProtocol

    func updateSourceLanguage(_ language: Language)
    func updateTargetLanguage(_ language: Language)
    func downloadLanguageModel(_ language: Language) async
    func deleteLanguageModel(_ language: Language)
    func clearCache()
}
```

##### OnboardingViewModel
```swift
// ViewModels/OnboardingViewModel.swift
@MainActor
class OnboardingViewModel: ObservableObject {
    @Published var currentStep: OnboardingStep = .welcome
    @Published var selectedSourceLanguage: Language?
    @Published var selectedTargetLanguage: Language?
    @Published var downloadProgress: Double = 0.0
    @Published var isDownloading = false
    @Published var error: AppError?
    @Published var hasCompletedOnboarding = false

    private let languageManager: LanguageManager
    private let translationService: TranslationServiceProtocol

    func selectLanguagePair(source: Language, target: Language)
    func downloadRequiredModels() async
    func skipDownload()
    func completeOnboarding()
    func nextStep()
    func previousStep()
}

// Models/OnboardingStep.swift
enum OnboardingStep {
    case welcome
    case languageSelection
    case modelDownload
    case tutorial
    case permissions
    case complete
}
```

#### 1.4 Views

##### Main App Structure
```swift
// TalkLensApp.swift
@main
struct TalkLensApp: App {
    @StateObject private var languageManager = LanguageManager()
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false

    var body: some Scene {
        WindowGroup {
            if hasCompletedOnboarding {
                RootTabView()
                    .environmentObject(languageManager)
            } else {
                OnboardingView()
                    .environmentObject(languageManager)
            }
        }
    }
}

// Views/RootTabView.swift
struct RootTabView: View {
    @EnvironmentObject var languageManager: LanguageManager

    var body: some View {
        TabView {
            CameraView()
                .tabItem { Label("Scan", systemImage: "camera") }

            LibraryView()
                .tabItem { Label("Library", systemImage: "photo.on.rectangle") }

            SettingsView()
                .tabItem { Label("Settings", systemImage: "gear") }
        }
    }
}
```

##### Camera View Components
```swift
// Views/Camera/CameraView.swift
struct CameraView: View {
    @StateObject private var viewModel: CameraViewModel
    // Camera preview, capture button, thumbnails
}

// Views/Camera/CameraPreviewView.swift
struct CameraPreviewView: UIViewRepresentable {
    // AVCaptureVideoPreviewLayer wrapper
}

// Views/Camera/DocumentDetectionOverlay.swift
struct DocumentDetectionOverlay: View {
    // Edge detection visualization
}

// Views/Camera/PageThumbnailStrip.swift
struct PageThumbnailStrip: View {
    // Horizontal scroll view of captured pages
}
```

##### Library View Components
```swift
// Views/Library/LibraryView.swift
struct LibraryView: View {
    @StateObject private var viewModel: LibraryViewModel
    // Document list, import buttons
}

// Views/Library/DocumentCard.swift
struct DocumentCard: View {
    // Individual document preview card
}

// Views/Library/ImageImportSheet.swift
struct ImageImportSheet: View {
    // Photo/file picker wrapper
}
```

##### Onboarding View Components
```swift
// Views/Onboarding/OnboardingView.swift
struct OnboardingView: View {
    @StateObject private var viewModel: OnboardingViewModel
    @EnvironmentObject var languageManager: LanguageManager
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false

    var body: some View {
        // Step-based navigation
        switch viewModel.currentStep {
        case .welcome: WelcomeScreen()
        case .languageSelection: LanguageSelectionScreen()
        case .modelDownload: ModelDownloadScreen()
        case .tutorial: TutorialCarousel()
        case .permissions: PermissionsScreen()
        case .complete: /* Set hasCompletedOnboarding = true */
        }
    }
}

// Views/Onboarding/WelcomeScreen.swift
struct WelcomeScreen: View {
    // App logo, tagline, "Get Started" button
}

// Views/Onboarding/LanguageSelectionScreen.swift
struct LanguageSelectionScreen: View {
    // Source and target language pickers
    // Popular language pairs suggestions
    // "Continue" button
}

// Views/Onboarding/ModelDownloadScreen.swift
struct ModelDownloadScreen: View {
    // Model size display
    // Network type warning (Wi-Fi/Cellular)
    // Download progress bar
    // "Download Now" / "Download Later" buttons
}

// Views/Onboarding/TutorialCarousel.swift
struct TutorialCarousel: View {
    // 3-4 tutorial slides with images
    // Page indicator
    // "Skip" / "Next" / "Done" buttons
}

// Views/Onboarding/PermissionsScreen.swift
struct PermissionsScreen: View {
    // Camera permission request
    // Photo library permission request
    // Explanations for each permission
}
```

##### Settings View Components
```swift
// Views/Settings/SettingsView.swift
struct SettingsView: View {
    @StateObject private var viewModel: SettingsViewModel
    @EnvironmentObject var languageManager: LanguageManager
    // Settings sections
}

// Views/Settings/LanguagePicker.swift
struct LanguagePicker: View {
    // Language selection interface
}

// Views/Settings/ModelManagementView.swift
struct ModelManagementView: View {
    // Download/delete language models
}
```

##### Shared Components
```swift
// Views/Shared/TranslationResultView.swift
struct TranslationResultView: View {
    let document: Document
    // Side-by-side text display
}

// Views/Shared/LoadingOverlay.swift
struct LoadingOverlay: View {
    // Processing indicator with progress
}

// Views/Shared/ErrorAlert.swift
struct ErrorAlert: View {
    // Error display and retry options
}
```

#### 1.5 Utilities

```swift
// Utilities/ImageProcessor.swift
class ImageProcessor {
    static func enhanceForOCR(_ image: UIImage) -> UIImage
    static func cropToDocument(_ image: UIImage, corners: [CGPoint]) -> UIImage
    static func compress(_ image: UIImage, quality: CompressionQuality) -> Data
}

// Utilities/DocumentDetector.swift
class DocumentDetector {
    func detectDocumentEdges(in image: UIImage) -> [CGPoint]?
    func calculateDetectionQuality(_ corners: [CGPoint]) -> DetectionQuality
}

// Utilities/AppError.swift
enum AppError: LocalizedError {
    case cameraAccessDenied
    case ocrFailed(underlying: Error)
    case translationFailed(underlying: Error)
    case modelNotDownloaded(language: Language)
    case networkRequired
    // ...
}

// Utilities/Logger.swift
class AppLogger {
    static func log(_ message: String, level: LogLevel)
    static func logError(_ error: Error)
}
```

### 2. Module Dependencies Graph

```
Views → ViewModels → Services → MLKit/Vision
  ↓         ↓            ↓
Models ← Models ←── Models
  ↓
Utilities
```

---

## Data Flow

### Camera Scan Flow
```
1. User Opens Camera Tab
   ↓
2. CameraService starts AVCaptureSession
   ↓
3. Frame publisher emits images
   ↓
4. DocumentDetector analyzes frames for document edges
   ↓
5. User captures / Auto-capture triggered
   ↓
6. Image saved as DocumentPage
   ↓
7. Repeat for multiple pages
   ↓
8. User taps "Translate"
   ↓
9. DocumentProcessor receives Document
   ↓
10. For each page:
    - OCRService extracts text
    - TranslationService translates text
    ↓
11. Updated Document returned
    ↓
12. TranslationResultView displayed
    ↓
13. StorageService persists Document
```

### Library Import Flow
```
1. User taps "Import Image"
   ↓
2. PhotosPicker presented
   ↓
3. User selects image(s)
   ↓
4. Images converted to DocumentPages
   ↓
5. Document created with pages
   ↓
6. DocumentProcessor processes
   ↓
7. Results displayed
   ↓
8. Document saved to storage
```

### Settings Language Change Flow
```
1. User changes source/target language
   ↓
2. LanguageManager updated
   ↓
3. Check if model downloaded
   ↓
4. If not:
   - Prompt user to download
   - TranslationService downloads model
   - Progress shown to user
   ↓
5. Language persisted to UserDefaults
   ↓
6. Other views observe change via @EnvironmentObject
```

---

## Implementation Phases

### Phase 1: Foundation & Core Infrastructure (Week 1-2)
**Goal**: Set up project structure and basic navigation

**Tasks**:
- [ ] Create module folder structure
- [ ] Set up dependency injection container
- [ ] Implement base protocols (OCRServiceProtocol, TranslationServiceProtocol, etc.)
- [ ] Create data models (Document, DocumentPage, Language, etc.)
- [ ] Implement RootTabView with placeholder tabs
- [ ] Set up LanguageManager with basic language list
- [ ] Configure Google MLKit SDK integration (CocoaPods/SPM)
- [ ] Create AppError and logging utilities
- [ ] Set up UserDefaults for settings persistence

**Deliverables**:
- Navigable tab structure
- Basic app settings
- Model layer complete
- MLKit SDK integrated

**Testing**:
- Unit tests for models
- Tab navigation verification

---

### Phase 2: OCR Implementation (Week 3-4)
**Goal**: Text recognition from images

**Tasks**:
- [ ] Implement MLKitOCRService
- [ ] Create VisionOCRService as fallback
- [ ] Implement ImageProcessor utility (enhancement, cropping)
- [ ] Create simple test view for OCR
- [ ] Handle multiple languages in OCR
- [ ] Implement text block positioning and formatting
- [ ] Add error handling for OCR failures
- [ ] Optimize for performance (background processing)

**Deliverables**:
- Working OCR from static images
- Support for 10+ languages
- Text positioning metadata
- Error handling

**Testing**:
- Unit tests for OCRService
- Integration tests with sample images
- Performance benchmarks

---

### Phase 3: Translation Implementation (Week 5-6)
**Goal**: Text translation engine

**Tasks**:
- [ ] Implement MLKitTranslationService
- [ ] Model download/management functionality
- [ ] Implement DocumentProcessor (OCR + Translation pipeline)
- [ ] Create ModelManagementView in Settings
- [ ] Add translation progress tracking
- [ ] Implement caching for translations
- [ ] Handle offline/online model availability
- [ ] Language auto-detection

**Deliverables**:
- Working translation for 5+ language pairs
- Model download UI
- Translation pipeline working end-to-end
- Offline functionality

**Testing**:
- Translation accuracy verification
- Model download/delete functionality
- Offline mode testing
- Memory usage profiling

---

### Phase 4: Camera & Document Scanning (Week 7-8)
**Goal**: Live camera capture with document detection

**Tasks**:
- [ ] Implement AVCameraService
- [ ] Create CameraPreviewView (UIViewRepresentable)
- [ ] Implement DocumentDetector (edge detection)
- [ ] Create DocumentDetectionOverlay
- [ ] Implement auto-capture logic
- [ ] Create PageThumbnailStrip
- [ ] Implement CameraViewModel
- [ ] Add flash controls
- [ ] Handle camera permissions
- [ ] Multi-page capture workflow

**Deliverables**:
- Working camera with preview
- Document edge detection
- Multi-page capture
- Auto-capture option
- Thumbnail management

**Testing**:
- Camera permissions flow
- Edge detection accuracy
- Multi-page capture workflow
- Memory management for images

---

### Phase 5: Library & History (Week 9-10)
**Goal**: Import from files and manage translation history

**Tasks**:
- [ ] Implement PhotosPicker integration
- [ ] Implement file picker (PDF support)
- [ ] Create LibraryViewModel
- [ ] Implement StorageService (FileManager)
- [ ] Create DocumentCard view
- [ ] Implement document list with search
- [ ] Add pull-to-refresh
- [ ] Implement document deletion
- [ ] PDF page extraction
- [ ] Export functionality (share sheet)

**Deliverables**:
- Photo/file import working
- Translation history list
- Document management (delete, share)
- PDF support (basic)

**Testing**:
- Import from various sources
- Storage persistence
- Large document handling
- Search functionality

---

### Phase 6: Results & User Experience (Week 11-12)
**Goal**: Polish translation results display

**Tasks**:
- [ ] Create TranslationResultView (side-by-side layout)
- [ ] Implement copy/share functionality
- [ ] Add page navigation for multi-page documents
- [ ] Implement text formatting preservation
- [ ] Create LoadingOverlay with progress
- [ ] Add haptic feedback
- [ ] Implement empty states
- [ ] Create first-time setup flow with model download
  - [ ] Implement OnboardingViewModel and OnboardingStep model
  - [ ] Create WelcomeScreen view
  - [ ] Create LanguageSelectionScreen view
  - [ ] Create ModelDownloadScreen with progress tracking
  - [ ] Create TutorialCarousel (3-4 slides)
  - [ ] Create PermissionsScreen for Camera/Photos access
  - [ ] Update TalkLensApp to check hasCompletedOnboarding
  - [ ] Add skip/later functionality for model downloads
- [ ] Implement app icon and branding
- [ ] Localize UI strings

**Deliverables**:
- Polished results view
- Copy/share functionality
- Loading states
- Complete first-time setup/onboarding flow with model downloads
- App icon

**Testing**:
- User flow testing
- Accessibility audit (VoiceOver, Dynamic Type)
- Localization testing

---

### Phase 7: Settings & Preferences (Week 13)
**Goal**: Complete settings functionality

**Tasks**:
- [ ] Complete SettingsView UI
- [ ] Implement all settings options
- [ ] Add language auto-detect toggle
- [ ] Create "About" section
- [ ] Implement cache management
- [ ] Add storage space calculation
- [ ] Create privacy policy content
- [ ] Implement tutorial/help section

**Deliverables**:
- Complete settings interface
- Cache management
- About/legal pages

**Testing**:
- Settings persistence
- Cache clearing
- Language switching

---

### Phase 8: Optimization & Polish (Week 14-15)
**Goal**: Performance optimization and bug fixes

**Tasks**:
- [ ] Memory optimization for image handling
- [ ] Background processing optimization
- [ ] Battery usage optimization
- [ ] Model loading optimization
- [ ] UI responsiveness improvements
- [ ] Fix known bugs
- [ ] Performance profiling (Instruments)
- [ ] Reduce app size
- [ ] Optimize model download sizes

**Deliverables**:
- Optimized performance
- Bug fixes
- Profiling reports
- Reduced app footprint

**Testing**:
- Performance testing on older devices
- Battery drain testing
- Memory leak detection
- Stress testing (100+ page document)

---

### Phase 9: Testing & QA (Week 16)
**Goal**: Comprehensive testing before release

**Tasks**:
- [ ] Complete unit test coverage (80%+)
- [ ] Integration testing
- [ ] UI testing (XCUITest)
- [ ] Beta testing with TestFlight
- [ ] Accessibility testing
- [ ] Localization verification
- [ ] Edge case handling
- [ ] Error scenario testing
- [ ] Device compatibility testing

**Deliverables**:
- Test coverage report
- Bug tracking and fixes
- Beta feedback incorporated
- Release candidate

**Testing**:
- Full regression testing
- Real-world usage scenarios
- Multiple device types (iPhone, iPad)
- iOS version compatibility (iOS 15+)

---

### Phase 10: Release Preparation (Week 17)
**Goal**: App Store submission

**Tasks**:
- [ ] App Store assets (screenshots, preview video)
- [ ] App description and metadata
- [ ] Privacy manifest
- [ ] App Store review preparation
- [ ] Final bug fixes
- [ ] Analytics integration (optional)
- [ ] Crash reporting setup (optional)
- [ ] Version 1.0 release notes
- [ ] Submit to App Store

**Deliverables**:
- App Store submission
- Marketing assets
- Support documentation

---

## Future Enhancements (Post-1.0)

### v1.1 - Enhanced Features
- **Batch Translation**: Process multiple documents simultaneously
- **OCR History**: Save recognized text separately for re-translation
- **Text Editing**: Edit recognized text before translation
- **Language Packs**: Support 100+ languages
- **Dark Mode**: Full dark mode support

### v1.2 - Advanced Features
- **Handwriting Recognition**: Support handwritten documents
- **Table Detection**: Preserve table structures
- **Cloud Sync**: iCloud sync for translation history (optional)
- **Voice Output**: Text-to-speech for translations
- **Custom Dictionaries**: User-defined translation overrides

### v1.3 - Professional Features
- **PDF Annotation**: Annotate translated PDFs
- **Multi-format Export**: Export as DOCX, TXT, PDF
- **Translation Memory**: Reuse previous translations
- **Collaborative Translation**: Share and collaborate
- **API Integration**: Third-party translation services (optional)

### v2.0 - AI-Powered Features
- **Context-Aware Translation**: Better translation quality
- **Document Summarization**: Summarize translated content
- **Entity Recognition**: Highlight names, dates, locations
- **Image Translation**: Translate text within images in-place
- **AR Translation**: Real-time AR overlay translation

---

## Technical Considerations

### Performance Targets
- **OCR Processing**: < 2 seconds per page (iPhone 12+)
- **Translation**: < 1 second per page (model downloaded)
- **App Launch**: < 1 second cold start
- **Memory**: < 100 MB baseline, < 300 MB during processing
- **Battery**: < 5% drain for 50-page document processing

### Device Support
- **Minimum**: iOS 15.0+
- **Recommended**: iOS 16.0+ for best performance
- **Devices**: iPhone 8 and newer, iPad (6th gen) and newer
- **Storage**: 500 MB minimum free space (for models)

### Privacy & Security
- **On-Device Only**: No data sent to servers
- **Privacy Manifest**: Declare API usage
- **Permissions**: Camera, Photo Library (with clear explanations)
- **No Analytics**: No user tracking (or opt-in only)
- **Data Retention**: User controls history retention

### Model Management
- **Initial Download**: English ↔ Spanish (~60 MB)
- **Language Model Size**: 30-40 MB per language
- **Auto-Download**: Prompt before downloading on cellular
- **Cleanup**: Remove unused models automatically
- **Update**: Check for model updates monthly

---

## Development Guidelines

### Code Style
- Follow Swift API Design Guidelines
- Use SwiftLint for code consistency
- Document public APIs with DocC comments
- Meaningful variable and function names
- Maximum function length: 50 lines

### Version Control
- Feature branch workflow (git flow)
- Conventional commits (feat:, fix:, docs:, etc.)
- Pull requests for all changes
- Code review required before merge

### Testing Strategy
- Unit tests: 80% coverage minimum
- Integration tests for critical paths
- UI tests for main user flows
- Performance tests for ML operations
- Accessibility tests

### Documentation
- README with setup instructions
- Architecture decision records (ADRs)
- API documentation (DocC)
- User guide (in-app help)
- Troubleshooting guide

---

## Risk Assessment & Mitigation

### Technical Risks

| Risk | Impact | Probability | Mitigation |
|------|--------|-------------|------------|
| MLKit model performance on older devices | High | Medium | Support iOS 15+, fallback to Vision framework |
| OCR accuracy for poor quality images | High | High | Image enhancement, user can edit text |
| Translation quality issues | Medium | Medium | Multiple model options, user feedback |
| Model download failures | Medium | Medium | Retry logic, resume downloads |
| Memory constraints with large PDFs | High | Low | Page-by-page processing, compression |

### Business Risks

| Risk | Impact | Probability | Mitigation |
|------|--------|-------------|------------|
| App Store rejection | High | Low | Follow guidelines strictly, privacy manifest |
| Limited language support | Medium | Medium | Start with popular languages, add more |
| User adoption | Medium | Medium | Good UX, clear value proposition |
| Competition | Low | High | Focus on privacy, offline capability |

---

## Success Metrics

### Phase 1-10 Metrics
- [ ] 100% feature completion
- [ ] < 10 critical bugs at launch
- [ ] 80%+ test coverage
- [ ] Performance targets met
- [ ] Accessibility audit passed

### Post-Launch Metrics (v1.0)
- App Store rating > 4.0
- Crash-free rate > 99%
- 1000+ downloads in first month
- Average session length > 3 minutes
- User retention > 30% (30-day)

---

## Appendix

### A. Supported Languages (Initial Launch)

**Tier 1** (Model pre-bundled):
- English (en)
- Spanish (es)

**Tier 2** (Download on demand):
- French (fr)
- German (de)
- Italian (it)
- Portuguese (pt)
- Chinese Simplified (zh)
- Japanese (ja)
- Korean (ko)
- Arabic (ar)
- Hindi (hi)
- Russian (ru)

### B. Third-Party Dependencies

```ruby
# Podfile
platform :ios, '15.0'

target 'TalkLens' do
  use_frameworks!

  # Google MLKit
  pod 'GoogleMLKit/TextRecognition', '~> 4.0'
  pod 'GoogleMLKit/Translate', '~> 4.0'
  pod 'GoogleMLKit/LanguageID', '~> 4.0'

  # Optional: Analytics & Crash Reporting
  # pod 'FirebaseAnalytics'
  # pod 'FirebaseCrashlytics'
end
```

### C. Folder Structure

```
TalkLens/
├── App/
│   ├── TalkLensApp.swift
│   └── AppDelegate.swift
├── Models/
│   ├── Document.swift
│   ├── DocumentPage.swift
│   ├── Language.swift
│   ├── ProcessingStatus.swift
│   ├── OnboardingStep.swift
│   └── AppSettings.swift
├── Services/
│   ├── OCR/
│   │   ├── OCRServiceProtocol.swift
│   │   ├── MLKitOCRService.swift
│   │   └── VisionOCRService.swift
│   ├── Translation/
│   │   ├── TranslationServiceProtocol.swift
│   │   └── MLKitTranslationService.swift
│   ├── Camera/
│   │   ├── CameraServiceProtocol.swift
│   │   └── AVCameraService.swift
│   ├── Storage/
│   │   ├── StorageServiceProtocol.swift
│   │   └── FileStorageService.swift
│   ├── DocumentProcessor.swift
│   └── LanguageManager.swift
├── ViewModels/
│   ├── CameraViewModel.swift
│   ├── LibraryViewModel.swift
│   ├── SettingsViewModel.swift
│   └── OnboardingViewModel.swift
├── Views/
│   ├── RootTabView.swift
│   ├── Onboarding/
│   │   ├── OnboardingView.swift
│   │   ├── WelcomeScreen.swift
│   │   ├── LanguageSelectionScreen.swift
│   │   ├── ModelDownloadScreen.swift
│   │   ├── TutorialCarousel.swift
│   │   └── PermissionsScreen.swift
│   ├── Camera/
│   │   ├── CameraView.swift
│   │   ├── CameraPreviewView.swift
│   │   ├── DocumentDetectionOverlay.swift
│   │   └── PageThumbnailStrip.swift
│   ├── Library/
│   │   ├── LibraryView.swift
│   │   ├── DocumentCard.swift
│   │   └── ImageImportSheet.swift
│   ├── Settings/
│   │   ├── SettingsView.swift
│   │   ├── LanguagePicker.swift
│   │   └── ModelManagementView.swift
│   └── Shared/
│       ├── TranslationResultView.swift
│       ├── LoadingOverlay.swift
│       └── ErrorAlert.swift
├── Utilities/
│   ├── ImageProcessor.swift
│   ├── DocumentDetector.swift
│   ├── AppError.swift
│   └── Logger.swift
├── Resources/
│   ├── Assets.xcassets/
│   ├── Localizable.strings
│   └── Info.plist
└── Tests/
    ├── UnitTests/
    ├── IntegrationTests/
    └── UITests/
```

### D. Key Classes & Protocols Summary

| Component | Type | Responsibility |
|-----------|------|----------------|
| `Document` | Model | Represents a translated document |
| `OnboardingStep` | Model | Enum for onboarding flow steps |
| `OCRServiceProtocol` | Protocol | Text recognition interface |
| `TranslationServiceProtocol` | Protocol | Translation interface |
| `CameraServiceProtocol` | Protocol | Camera operations interface |
| `DocumentProcessor` | Service | Orchestrates OCR + Translation |
| `LanguageManager` | Service | Manages language state |
| `OnboardingViewModel` | ViewModel | First-time setup business logic |
| `CameraViewModel` | ViewModel | Camera tab business logic |
| `LibraryViewModel` | ViewModel | Library tab business logic |
| `SettingsViewModel` | ViewModel | Settings tab business logic |
| `OnboardingView` | View | First-time setup flow container |
| `RootTabView` | View | Main tab container |

---

## Conclusion

This design document provides a comprehensive blueprint for building the TalkLens iOS application. The modular architecture ensures maintainability and testability, while the phased implementation plan allows for iterative development and early feedback.

Key strengths of this design:
1. **Privacy-First**: Complete on-device processing
2. **Modular**: Clear separation of concerns
3. **Testable**: Protocol-based design with dependency injection
4. **Scalable**: Easy to add new languages and features
5. **User-Friendly**: Intuitive tab-based navigation with guided onboarding

The 17-week implementation plan balances feature development with quality assurance, ensuring a robust v1.0 release. Future enhancements provide a clear roadmap for continued improvement.

**Next Steps**:
1. Review and approve this design document
2. Set up development environment
3. Begin Phase 1 implementation
4. Establish regular sprint reviews

---

**Document Version**: 1.0
**Last Updated**: November 19, 2025
**Author**: TalkLens Development Team
**Status**: Ready for Implementation
