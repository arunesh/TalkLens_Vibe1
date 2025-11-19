//
//  DocumentDetector.swift
//  TalkLens
//
//  Created by Claude on 11/19/25.
//

import Foundation
import UIKit
import Vision

/// Quality of document edge detection
enum DetectionQuality {
    case excellent  // Clear, well-defined edges
    case good       // Acceptable edges
    case poor       // Edges detected but low confidence
    case none       // No document detected

    var color: UIColor {
        switch self {
        case .excellent:
            return .systemGreen
        case .good:
            return .systemYellow
        case .poor:
            return .systemOrange
        case .none:
            return .systemRed
        }
    }
}

/// Detects document edges in images
class DocumentDetector {
    /// Detects document edges in an image using Vision framework
    /// - Parameter image: The image to analyze
    /// - Returns: Four corner points if document is detected, nil otherwise
    func detectDocumentEdges(in image: UIImage) -> [CGPoint]? {
        guard let cgImage = image.cgImage else { return nil }

        let request = VNDetectRectanglesRequest()
        request.minimumAspectRatio = 0.3
        request.maximumAspectRatio = 1.6
        request.minimumSize = 0.3
        request.maximumObservations = 1

        let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])

        do {
            try handler.perform([request])

            guard let observation = request.results?.first else {
                return nil
            }

            // Convert normalized coordinates to image coordinates
            let imageSize = image.size
            let corners = [
                observation.topLeft,
                observation.topRight,
                observation.bottomRight,
                observation.bottomLeft
            ].map { point in
                CGPoint(
                    x: point.x * imageSize.width,
                    y: (1 - point.y) * imageSize.height
                )
            }

            return corners

        } catch {
            AppLogger.logError(error)
            return nil
        }
    }

    /// Calculates the quality of detected document edges
    /// - Parameter corners: The four corner points
    /// - Returns: Detection quality
    func calculateDetectionQuality(_ corners: [CGPoint]) -> DetectionQuality {
        guard corners.count == 4 else { return .none }

        // Calculate area
        let area = calculatePolygonArea(corners)

        // Simple heuristic: larger area = better quality
        if area > 500_000 {
            return .excellent
        } else if area > 200_000 {
            return .good
        } else if area > 50_000 {
            return .poor
        } else {
            return .none
        }
    }

    // MARK: - Private Methods

    private func calculatePolygonArea(_ points: [CGPoint]) -> CGFloat {
        guard points.count >= 3 else { return 0 }

        var area: CGFloat = 0
        let n = points.count

        for i in 0..<n {
            let j = (i + 1) % n
            area += points[i].x * points[j].y
            area -= points[j].x * points[i].y
        }

        return abs(area) / 2.0
    }
}
