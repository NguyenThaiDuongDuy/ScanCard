//
//  Detetor.swift
//  ScanCard
//
//  Created by admin on 26/04/2021.
//

import Foundation
import Vision
import UIKit

enum ResultOfDetectCard <VNRectangleObservation, Error> {
    case success(VNRectangleObservation)
    case failure(Error)
}

class Detector {
    let minimumAspectRatioCard = VNAspectRatio(1.3)
    let maximumAspectRatioCard = VNAspectRatio(1.6)
    let maximum1TimeCardDetect = 1
    let minimumSizeDetectCard = Float(0.5)

    private init() {}
    static let share = Detector()

    func detectCard(videoFrame: CMSampleBuffer,
                    completion: @escaping (ResultOfDetectCard<VNRectangleObservation, Error>) -> Void) {
        func detectRectanglesCompletionHandler (request: VNRequest, error: Error?) {
                // Request fail
            if let error = error {
                    completion(.failure(error))
                }
                guard let rectanglesDetectFromVisionService = request.results as?
                        [VNRectangleObservation] else { return }
                guard let rectangleDetectFromVisionService = rectanglesDetectFromVisionService.first else { return }
            completion(.success(rectangleDetectFromVisionService))
        }

        let request = VNDetectRectanglesRequest(completionHandler: detectRectanglesCompletionHandler)
        request.minimumAspectRatio = minimumAspectRatioCard
        request.maximumAspectRatio = maximumAspectRatioCard
        request.minimumSize = minimumSizeDetectCard
        request.maximumObservations = maximum1TimeCardDetect

        let requestHandler = VNImageRequestHandler(cmSampleBuffer: videoFrame, options: [:])

        try? requestHandler.perform([request])
    }

    func getTextsFromImage(cgImage: CGImage?, completion: @escaping ([String]) -> Void) {
        let request = VNRecognizeTextRequest { (request, error) in

            if let error = error {
                print(error)
                return
            }

            guard let observations =
                    request.results as? [VNRecognizedTextObservation] else {
                return
            }

            let recognizedStrings = observations.compactMap { observation in
                observation.topCandidates(1).first?.string
            }
            completion(recognizedStrings)
        }
        request.recognitionLevel = .accurate
        request.minimumTextHeight = 1 / 20
        guard let textImage = cgImage else { return }
        let requestTextHandler = VNImageRequestHandler(cgImage: textImage, options: [:])
        try? requestTextHandler.perform([request])
    }
}
