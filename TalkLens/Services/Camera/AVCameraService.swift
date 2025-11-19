//
//  AVCameraService.swift
//  TalkLens
//
//  Created by Claude on 11/19/25.
//

import Foundation
import UIKit
import AVFoundation
import Combine

/// Production camera service using AVFoundation
class AVCameraService: NSObject, CameraServiceProtocol {
    let captureSession = AVCaptureSession() // Public for camera preview
    private let photoOutput = AVCapturePhotoOutput()
    private let videoOutput = AVCaptureVideoDataOutput()
    private var currentDevice: AVCaptureDevice?

    private let frameSubject = PassthroughSubject<UIImage, Never>()
    private var photoContinuation: CheckedContinuation<UIImage, Error>?

    private(set) var isFlashOn: Bool = false

    var framePublisher: AnyPublisher<UIImage, Never> {
        frameSubject.eraseToAnyPublisher()
    }

    override init() {
        super.init()
        setupCaptureSession()
    }

    func startSession() {
        guard !captureSession.isRunning else { return }

        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            self?.captureSession.startRunning()
            AppLogger.info("Camera session started")
        }
    }

    func stopSession() {
        guard captureSession.isRunning else { return }

        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            self?.captureSession.stopRunning()
            AppLogger.info("Camera session stopped")
        }
    }

    func capturePhoto() async throws -> UIImage {
        guard let device = currentDevice else {
            throw AppError.cameraAccessDenied
        }

        return try await withCheckedThrowingContinuation { continuation in
            photoContinuation = continuation

            let settings = AVCapturePhotoSettings()

            // Configure flash
            if device.hasFlash {
                settings.flashMode = isFlashOn ? .on : .off
            }

            // Enable high-resolution capture
            settings.isHighResolutionPhotoEnabled = true

            // Configure for best quality
            if let photoCodec = settings.availablePhotoCodecTypes.first {
                settings.photoQualityPrioritization = .quality
            }

            photoOutput.capturePhoto(with: settings, delegate: self)
        }
    }

    func toggleFlash() {
        isFlashOn.toggle()
        AppLogger.info("Flash toggled: \(isFlashOn)")
    }

    // MARK: - Private Methods

    private func setupCaptureSession() {
        captureSession.beginConfiguration()

        // Set session preset for high quality
        if captureSession.canSetSessionPreset(.photo) {
            captureSession.sessionPreset = .photo
        }

        // Setup camera input
        guard let camera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) else {
            AppLogger.error("Failed to get camera device")
            captureSession.commitConfiguration()
            return
        }

        currentDevice = camera

        do {
            let input = try AVCaptureDeviceInput(device: camera)

            if captureSession.canAddInput(input) {
                captureSession.addInput(input)
            }

            // Add photo output
            if captureSession.canAddOutput(photoOutput) {
                captureSession.addOutput(photoOutput)

                // Configure photo output
                photoOutput.isHighResolutionCaptureEnabled = true
                if let connection = photoOutput.connection(with: .video) {
                    if connection.isVideoStabilizationSupported {
                        connection.preferredVideoStabilizationMode = .auto
                    }
                }
            }

            // Add video output for frame processing (optional, for document detection)
            videoOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "videoQueue"))
            if captureSession.canAddOutput(videoOutput) {
                captureSession.addOutput(videoOutput)
            }

            captureSession.commitConfiguration()

            AppLogger.info("Camera setup completed")

        } catch {
            AppLogger.logError(error)
            captureSession.commitConfiguration()
        }
    }

    private func configureDevice(_ device: AVCaptureDevice, for mode: CaptureMode) {
        do {
            try device.lockForConfiguration()

            // Set focus mode
            if device.isFocusModeSupported(.continuousAutoFocus) {
                device.focusMode = .continuousAutoFocus
            }

            // Set exposure mode
            if device.isExposureModeSupported(.continuousAutoExposure) {
                device.exposureMode = .continuousAutoExposure
            }

            // Set white balance
            if device.isWhiteBalanceModeSupported(.continuousAutoWhiteBalance) {
                device.whiteBalanceMode = .continuousAutoWhiteBalance
            }

            device.unlockForConfiguration()
        } catch {
            AppLogger.logError(error)
        }
    }

    private enum CaptureMode {
        case photo
        case video
    }
}

// MARK: - AVCapturePhotoCaptureDelegate

extension AVCameraService: AVCapturePhotoCaptureDelegate {
    func photoOutput(
        _ output: AVCapturePhotoOutput,
        didFinishProcessingPhoto photo: AVCapturePhoto,
        error: Error?
    ) {
        if let error = error {
            photoContinuation?.resume(throwing: error)
            photoContinuation = nil
            AppLogger.logError(error)
            return
        }

        guard let imageData = photo.fileDataRepresentation(),
              let image = UIImage(data: imageData) else {
            photoContinuation?.resume(throwing: AppError.imageProcessingFailed)
            photoContinuation = nil
            return
        }

        // Correct image orientation
        let correctedImage = ImageProcessor.correctOrientation(image)

        photoContinuation?.resume(returning: correctedImage)
        photoContinuation = nil

        AppLogger.info("Photo captured successfully")
    }

    func photoOutput(
        _ output: AVCapturePhotoOutput,
        didCapturePhotoFor resolvedSettings: AVCaptureResolvedPhotoSettings
    ) {
        // Photo capture started
        AppLogger.debug("Photo capture initiated")
    }
}

// MARK: - AVCaptureVideoDataOutputSampleBufferDelegate

extension AVCameraService: AVCaptureVideoDataOutputSampleBufferDelegate {
    func captureOutput(
        _ output: AVCaptureOutput,
        didOutput sampleBuffer: CMSampleBuffer,
        from connection: AVCaptureConnection
    ) {
        // Convert sample buffer to UIImage for document detection
        guard let imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {
            return
        }

        let ciImage = CIImage(cvImageBuffer: imageBuffer)
        let context = CIContext()

        guard let cgImage = context.createCGImage(ciImage, from: ciImage.extent) else {
            return
        }

        let image = UIImage(cgImage: cgImage)

        // Publish frame for real-time processing (e.g., document detection)
        frameSubject.send(image)
    }

    func captureOutput(
        _ output: AVCaptureOutput,
        didDrop sampleBuffer: CMSampleBuffer,
        from connection: AVCaptureConnection
    ) {
        AppLogger.debug("Frame dropped")
    }
}

// MARK: - Camera Preview View

/// UIView wrapper for camera preview layer
class CameraPreviewView: UIView {
    override class var layerClass: AnyClass {
        AVCaptureVideoPreviewLayer.self
    }

    var previewLayer: AVCaptureVideoPreviewLayer {
        layer as! AVCaptureVideoPreviewLayer
    }

    var session: AVCaptureSession? {
        get { previewLayer.session }
        set { previewLayer.session = newValue }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupPreviewLayer()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupPreviewLayer()
    }

    private func setupPreviewLayer() {
        previewLayer.videoGravity = .resizeAspectFill
    }
}

/// SwiftUI wrapper for camera preview
import SwiftUI

struct CameraPreviewRepresentable: UIViewRepresentable {
    let session: AVCaptureSession

    func makeUIView(context: Context) -> CameraPreviewView {
        let view = CameraPreviewView()
        view.session = session
        return view
    }

    func updateUIView(_ uiView: CameraPreviewView, context: Context) {
        // Update if needed
    }
}
