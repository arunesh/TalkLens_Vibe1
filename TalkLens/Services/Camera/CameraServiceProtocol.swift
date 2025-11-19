//
//  CameraServiceProtocol.swift
//  TalkLens
//
//  Created by Claude on 11/19/25.
//

import Foundation
import UIKit
import Combine

/// Protocol for camera services
protocol CameraServiceProtocol {
    /// Publisher that emits camera frames
    var framePublisher: AnyPublisher<UIImage, Never> { get }

    /// Starts the camera session
    func startSession()

    /// Stops the camera session
    func stopSession()

    /// Captures a photo from the camera
    /// - Returns: Captured image
    func capturePhoto() async throws -> UIImage

    /// Toggles the camera flash
    func toggleFlash()

    /// Current flash state
    var isFlashOn: Bool { get }
}
