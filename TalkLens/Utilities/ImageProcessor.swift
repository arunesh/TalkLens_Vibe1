//
//  ImageProcessor.swift
//  TalkLens
//
//  Created by Claude on 11/19/25.
//

import Foundation
import UIKit
import CoreImage
import CoreImage.CIFilterBuiltins

/// Utility for image processing operations
class ImageProcessor {
    /// Enhances an image for better OCR recognition
    /// - Parameter image: The image to enhance
    /// - Returns: Enhanced image
    static func enhanceForOCR(_ image: UIImage) -> UIImage {
        guard let ciImage = CIImage(image: image) else { return image }

        let context = CIContext()

        // Apply filters for better OCR
        // 1. Increase contrast
        let contrastFilter = CIFilter.colorControls()
        contrastFilter.inputImage = ciImage
        contrastFilter.contrast = 1.3
        contrastFilter.brightness = 0.1
        contrastFilter.saturation = 0

        guard let contrastOutput = contrastFilter.outputImage else { return image }

        // 2. Sharpen
        let sharpenFilter = CIFilter.sharpenLuminance()
        sharpenFilter.inputImage = contrastOutput
        sharpenFilter.sharpness = 0.7

        guard let finalOutput = sharpenFilter.outputImage,
              let cgImage = context.createCGImage(finalOutput, from: finalOutput.extent) else {
            return image
        }

        return UIImage(cgImage: cgImage, scale: image.scale, orientation: image.imageOrientation)
    }

    /// Crops an image to document boundaries
    /// - Parameters:
    ///   - image: The image to crop
    ///   - corners: The four corners of the document
    /// - Returns: Cropped image
    static func cropToDocument(_ image: UIImage, corners: [CGPoint]) -> UIImage {
        guard corners.count == 4 else { return image }

        // For simplicity, calculate bounding rect
        let minX = corners.map { $0.x }.min() ?? 0
        let minY = corners.map { $0.y }.min() ?? 0
        let maxX = corners.map { $0.x }.max() ?? image.size.width
        let maxY = corners.map { $0.y }.max() ?? image.size.height

        let cropRect = CGRect(x: minX, y: minY, width: maxX - minX, height: maxY - minY)

        guard let cgImage = image.cgImage?.cropping(to: cropRect) else {
            return image
        }

        return UIImage(cgImage: cgImage, scale: image.scale, orientation: image.imageOrientation)
    }

    /// Compresses an image
    /// - Parameters:
    ///   - image: The image to compress
    ///   - quality: Compression quality (0.0-1.0)
    /// - Returns: Compressed image data
    static func compress(_ image: UIImage, quality: AppSettings.ImageQuality) -> Data? {
        image.jpegData(compressionQuality: quality.compressionQuality)
    }

    /// Resizes an image to a maximum dimension while maintaining aspect ratio
    /// - Parameters:
    ///   - image: The image to resize
    ///   - maxDimension: Maximum width or height
    /// - Returns: Resized image
    static func resize(_ image: UIImage, maxDimension: CGFloat) -> UIImage {
        let size = image.size
        let aspectRatio = size.width / size.height

        var newSize: CGSize
        if size.width > size.height {
            newSize = CGSize(width: maxDimension, height: maxDimension / aspectRatio)
        } else {
            newSize = CGSize(width: maxDimension * aspectRatio, height: maxDimension)
        }

        let renderer = UIGraphicsImageRenderer(size: newSize)
        return renderer.image { _ in
            image.draw(in: CGRect(origin: .zero, size: newSize))
        }
    }

    /// Rotates an image to correct orientation
    /// - Parameter image: The image to rotate
    /// - Returns: Correctly oriented image
    static func correctOrientation(_ image: UIImage) -> UIImage {
        guard image.imageOrientation != .up else { return image }

        UIGraphicsBeginImageContextWithOptions(image.size, false, image.scale)
        image.draw(in: CGRect(origin: .zero, size: image.size))
        let normalizedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return normalizedImage ?? image
    }
}
