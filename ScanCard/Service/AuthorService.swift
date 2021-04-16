//
//  AuthorService.swift
//  ScanCard
//
//  Created by admin on 06/04/2021.
//

import Foundation
import AVFoundation
import UIKit

class AuthorService {
    static let share = AuthorService()
    private init() {}

    func reQuestUsingCamera(completion: (AVAuthorizationStatus) -> Void) {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized: // The user has previously granted access to the camera.
            completion(.authorized)
        case .notDetermined: // The user has not yet been asked for camera access.
            AVCaptureDevice.requestAccess(for: .video) { granted in
                if granted {
                    print("User granted")
                } else {
                    print("User not granted")
                }
            }
        case .denied: // The user has previously denied access.
            // Show dialog
            completion(.denied)
            print("User denied")
            return
        case .restricted: // The user can't grant access due to restrictions.
            completion(.restricted)
            print("User restricted")
            return
        @unknown default:
            print("Something cameup")
        }
    }
}
