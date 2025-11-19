# TalkLens Dependencies

This document describes the external dependencies required for the TalkLens app to function with real OCR and translation capabilities.

## Current Implementation

The app currently uses **mock implementations** for development and testing:
- `MockOCRService` - Simulates text recognition
- `MockTranslationService` - Simulates translation
- `MockCameraService` - Simulates camera functionality

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

## Implementing Real Services

Once dependencies are added, create production implementations:

### 1. Create MLKitOCRService

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

### 2. Create MLKitTranslationService

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

### 3. Create AVCameraService

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

## Updating Dependency Injection

Update the view initializers to use real services instead of mocks:

```swift
// In CameraView.swift
init() {
    let cameraService = AVCameraService()  // Instead of MockCameraService()
    let ocrService = MLKitOCRService()     // Instead of MockOCRService()
    let translationService = MLKitTranslationService()  // Instead of MockTranslationService()
    // ... rest of initialization
}
```

## Privacy Permissions

Add the following keys to your `Info.plist`:

```xml
<key>NSCameraUsageDescription</key>
<string>Camera access is required to scan documents for translation</string>

<key>NSPhotoLibraryUsageDescription</key>
<string>Photo library access is required to import images for translation</string>
```

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
