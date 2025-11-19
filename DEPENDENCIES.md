# TalkLens Dependencies

This document describes the external dependencies required for the TalkLens app to function with real OCR and translation capabilities.

## Current Implementation

The app now includes **production implementations** ready for use with MLKit:
- `MLKitOCRService` / `AdaptiveMLKitOCRService` - Real text recognition with MLKit
- `MLKitTranslationService` - Real translation with MLKit
- `AVCameraService` - Real camera functionality with AVFoundation

**Mock implementations** are also available for testing without MLKit:
- `MockOCRService` - Simulates text recognition
- `MockTranslationService` - Simulates translation
- `MockCameraService` - Simulates camera functionality

**Note:** The app is currently configured to use the production services. All views have been updated to use the real implementations.

## Required Dependencies for Production

To enable real OCR and translation functionality, you need to integrate Google MLKit:

### Option 1: Swift Package Manager (Recommended)

Add the following packages to your Xcode project:

1. Open your project in Xcode
2. Go to File > Add Packages...
3. Add the following repositories:

```
https://github.com/google/GoogleMLKit-iOS
```

Add these specific packages:
- `GoogleMLKit/TextRecognition`
- `GoogleMLKit/Translate`
- `GoogleMLKit/LanguageID`

### Option 2: CocoaPods

Create a `Podfile` in your project root with the following content:

```ruby
platform :ios, '15.0'
use_frameworks!

target 'TalkLens' do
  pod 'GoogleMLKit/TextRecognition'
  pod 'GoogleMLKit/Translate'
  pod 'GoogleMLKit/LanguageID'
end
```

Then run:
```bash
pod install
```

## Production Service Implementations

The following production services have been implemented and are ready to use:

### 1. MLKitOCRService (Implemented)

Location: `TalkLens/Services/OCR/MLKitOCRService.swift`

Two implementations are available:

```swift
// Services/OCR/MLKitOCRService.swift
import MLKit

class MLKitOCRService: OCRServiceProtocol {
    private let textRecognizer: TextRecognizer

    init() {
        textRecognizer = TextRecognizer.textRecognizer()
    }

    func recognizeText(
        in image: UIImage,
        language: Language?
    ) async throws -> RecognizedText {
        let visionImage = VisionImage(image: image)

        let result = try await textRecognizer.process(visionImage)

        return RecognizedText(
            text: result.text,
            confidence: 0.9, // MLKit doesn't provide overall confidence
            language: language
        )
    }
}
```

### 2. MLKitTranslationService (Implemented)

Location: `TalkLens/Services/Translation/MLKitTranslationService.swift`

Features:
- Automatic language detection support
- Model download progress tracking
- Persistent model management
- Support for 12+ languages
- Offline translation once models are downloaded

```swift
// Services/Translation/MLKitTranslationService.swift
import MLKit

class MLKitTranslationService: TranslationServiceProtocol {
    private var translators: [String: Translator] = [:]
    private var downloadedModels: Set<String> = []

    func translate(
        text: String,
        from sourceLanguage: Language,
        to targetLanguage: Language
    ) async throws -> String {
        let options = TranslatorOptions(
            sourceLanguage: .init(rawValue: sourceLanguage.code)!,
            targetLanguage: .init(rawValue: targetLanguage.code)!
        )

        let translator = Translator.translator(options: options)

        // Ensure model is downloaded
        let conditions = ModelDownloadConditions(
            allowsCellularAccess: true,
            allowsBackgroundDownloading: true
        )

        try await translator.downloadModelIfNeeded(with: conditions)

        return try await translator.translate(text)
    }

    func downloadModel(for language: Language) async throws {
        // Implementation for model download
    }

    func deleteModel(for language: Language) throws {
        // Implementation for model deletion
    }

    func isModelDownloaded(for language: Language) -> Bool {
        downloadedModels.contains(language.code)
    }

    func downloadProgress(for language: Language) -> Double {
        // Track download progress
        return 0.0
    }
}
```

### 3. AVCameraService (Implemented)

Location: `TalkLens/Services/Camera/AVCameraService.swift`

Features:
- High-resolution photo capture
- Real-time video frames for document detection
- Flash control
- Auto-focus and exposure
- Camera preview with `CameraPreviewRepresentable`

```swift
// Services/Camera/AVCameraService.swift
import AVFoundation
import Combine

class AVCameraService: NSObject, CameraServiceProtocol {
    private let captureSession = AVCaptureSession()
    private let photoOutput = AVCapturePhotoOutput()
    private let frameSubject = PassthroughSubject<UIImage, Never>()
    private(set) var isFlashOn: Bool = false

    var framePublisher: AnyPublisher<UIImage, Never> {
        frameSubject.eraseToAnyPublisher()
    }

    func startSession() {
        // Setup and start capture session
    }

    func stopSession() {
        captureSession.stopRunning()
    }

    func capturePhoto() async throws -> UIImage {
        // Capture photo implementation
    }

    func toggleFlash() {
        isFlashOn.toggle()
        // Apply flash setting to camera
    }
}
```

## Dependency Injection (Already Updated)

All views have been updated to use production services:

- `CameraView` → Uses `AVCameraService`, `AdaptiveMLKitOCRService`, `MLKitTranslationService`
- `LibraryView` → Uses `AdaptiveMLKitOCRService`, `MLKitTranslationService`
- `SettingsView` → Uses `MLKitTranslationService`
- `TalkLensApp` → Uses `MLKitTranslationService` for LanguageManager

To switch back to mock services for testing, simply change the service initialization in each view's `init()` method.

## Privacy Permissions (Already Added)

An `Info.plist` file has been created at `TalkLens/Info.plist` with the following permissions:

```xml
<key>NSCameraUsageDescription</key>
<string>TalkLens needs access to your camera to scan documents for translation. All processing happens on-device to protect your privacy.</string>

<key>NSPhotoLibraryUsageDescription</key>
<string>TalkLens needs access to your photo library to import images for translation. Your photos never leave your device.</string>

<key>NSPhotoLibraryAddUsageDescription</key>
<string>TalkLens can save translated documents to your photo library for easy access.</string>
```

**Important:** Ensure this Info.plist is added to your Xcode project target.

## Additional Configuration

1. Enable "On-Device Only" mode in MLKit settings for privacy
2. Pre-download commonly used language models during onboarding
3. Handle model download failures gracefully
4. Implement proper error handling for camera access denials

## Testing

After integration:
1. Test OCR with various document types and languages
2. Verify translation accuracy
3. Test offline functionality
4. Validate model download/delete operations
5. Check camera functionality on real devices

## Resources

- [Google MLKit iOS Documentation](https://developers.google.com/ml-kit/vision/text-recognition/ios)
- [MLKit Translation Guide](https://developers.google.com/ml-kit/language/translation/ios)
- [AVFoundation Documentation](https://developer.apple.com/documentation/avfoundation)
