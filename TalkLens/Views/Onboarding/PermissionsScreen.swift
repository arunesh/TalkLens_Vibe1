//
//  PermissionsScreen.swift
//  TalkLens
//
//  Created by Claude on 11/19/25.
//

import SwiftUI
import AVFoundation
import Photos

struct PermissionsScreen: View {
    @ObservedObject var viewModel: OnboardingViewModel

    @State private var cameraPermissionGranted = false
    @State private var photosPermissionGranted = false

    var body: some View {
        VStack(spacing: 30) {
            // Header
            VStack(spacing: 10) {
                Image(systemName: "hand.raised")
                    .font(.system(size: 60))
                    .foregroundColor(.blue)

                Text("Required Permissions")
                    .font(.title)
                    .fontWeight(.bold)

                Text("TalkLens needs access to work properly")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            .padding(.top, 60)

            Spacer()

            // Permissions List
            VStack(spacing: 20) {
                PermissionCard(
                    icon: "camera",
                    title: "Camera",
                    description: "To scan documents and capture images",
                    isGranted: cameraPermissionGranted
                ) {
                    requestCameraPermission()
                }

                PermissionCard(
                    icon: "photo",
                    title: "Photo Library",
                    description: "To import images for translation",
                    isGranted: photosPermissionGranted
                ) {
                    requestPhotosPermission()
                }
            }
            .padding(.horizontal, 40)

            Spacer()

            // Continue Button
            Button(action: {
                viewModel.nextStep()
            }) {
                Text(allPermissionsGranted ? "Get Started" : "Continue Anyway")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(allPermissionsGranted ? Color.blue : Color.secondary)
                    .cornerRadius(12)
            }
            .padding(.horizontal, 40)
            .padding(.bottom, 40)

            if !allPermissionsGranted {
                Text("You can grant permissions later in Settings")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding(.bottom, 20)
            }
        }
        .onAppear {
            checkPermissions()
        }
    }

    var allPermissionsGranted: Bool {
        cameraPermissionGranted && photosPermissionGranted
    }

    func checkPermissions() {
        // Check camera permission
        cameraPermissionGranted = AVCaptureDevice.authorizationStatus(for: .video) == .authorized

        // Check photos permission
        photosPermissionGranted = PHPhotoLibrary.authorizationStatus() == .authorized
    }

    func requestCameraPermission() {
        AVCaptureDevice.requestAccess(for: .video) { granted in
            DispatchQueue.main.async {
                cameraPermissionGranted = granted
            }
        }
    }

    func requestPhotosPermission() {
        PHPhotoLibrary.requestAuthorization { status in
            DispatchQueue.main.async {
                photosPermissionGranted = status == .authorized
            }
        }
    }
}

struct PermissionCard: View {
    let icon: String
    let title: String
    let description: String
    let isGranted: Bool
    let action: () -> Void

    var body: some View {
        HStack(spacing: 15) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(.blue)
                .frame(width: 40)

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                Text(description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }

            Spacer()

            if isGranted {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.green)
            } else {
                Button(action: action) {
                    Text("Allow")
                        .font(.subheadline)
                        .foregroundColor(.white)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(Color.blue)
                        .cornerRadius(8)
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}
