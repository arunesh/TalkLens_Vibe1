//
//  MockCameraService.swift
//  TalkLens
//
//  Created by Claude on 11/19/25.
//

import Foundation
import UIKit
import Combine

/// Mock implementation of camera service for development and testing
class MockCameraService: CameraServiceProtocol {
    private let frameSubject = PassthroughSubject<UIImage, Never>()
    private(set) var isFlashOn: Bool = false

    var framePublisher: AnyPublisher<UIImage, Never> {
        frameSubject.eraseToAnyPublisher()
    }

    func startSession() {
        // Mock: Start publishing frames
        print("Mock camera session started")
    }

    func stopSession() {
        // Mock: Stop publishing frames
        print("Mock camera session stopped")
    }

    func capturePhoto() async throws -> UIImage {
        // Simulate capture delay
        try await Task.sleep(nanoseconds: 500_000_000) // 0.5 seconds

        // Return a placeholder image (1x1 white pixel as placeholder)
        let size = CGSize(width: 1080, height: 1920)
        let renderer = UIGraphicsImageRenderer(size: size)
        let image = renderer.image { context in
            UIColor.white.setFill()
            context.fill(CGRect(origin: .zero, size: size))

            // Draw some text to simulate a document
            let text = "Sample Document\n\nThis is a mock captured image\nfor development purposes."
            let attributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 40),
                .foregroundColor: UIColor.black
            ]
            let textRect = CGRect(x: 50, y: 100, width: size.width - 100, height: size.height - 200)
            text.draw(in: textRect, withAttributes: attributes)
        }

        return image
    }

    func toggleFlash() {
        isFlashOn.toggle()
    }
}
