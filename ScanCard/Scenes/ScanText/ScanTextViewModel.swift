//
//  ScanTextViewModel.swift
//  ScanCard
//
//  Created by admin on 16/04/2021.
//

import UIKit

protocol ScanTextViewModelDelegate: AnyObject {
    func didGetCardInfo()
}

enum ResultCheckInfo: String {
    case success
    case invalidCardHolder
    case invalidCardNumber
    case invalidIssueDate
    case invalidExpiryDate
}

class ScanTextViewModel {

    var cardInfo: Card?
    var image: CIImage
    let maxCardNumber = 19
    let minCardNumber = 16
    weak var delegate: ScanTextViewModelDelegate?

    init(image: CIImage) {
        self.image = image
    }

    func checkValidInfo(cardInfo: Card) -> ResultCheckInfo {

        // Check valid Name
        if !isValidCardHolder(cardHolder: cardInfo.cardHolder ?? "") {
            return ResultCheckInfo.invalidCardHolder
        }

        // Check valid bank number
        if !isValidCardNumber(cardNumber: cardInfo.cardNumber ?? "") {
            return ResultCheckInfo.invalidCardNumber
        }

        // check valid created date
        if !isValidIssueDate(checkIssueDate: cardInfo.issueDate ?? "") {
            return ResultCheckInfo.invalidIssueDate
        }

        // check valid validate date
        if !isValidExpiryDate(checkExpiryDate: cardInfo.expiryDate ?? "") {
            return ResultCheckInfo.invalidExpiryDate
        }
        self.cardInfo = cardInfo
        return ResultCheckInfo.success
    }

    private func isValidCardNumber(cardNumber: String) -> Bool {
        let vowels: Set<Character> = [" "]
        var checkCardNumber = ""
        checkCardNumber = cardNumber
        checkCardNumber.removeAll(where: { vowels.contains($0) })

        if !checkCardNumber.isNumeric { return false }

        if checkCardNumber.count<minCardNumber || checkCardNumber.count>maxCardNumber {
            return false
        }
        return true
    }

    private func isValidCardHolder(cardHolder: String) -> Bool {
        if !cardHolder.isOnlyUpCaseAndWhiteSpaceCharacter { return false }
        let nameAfterCutWhiteSpacesAndNewlines = cardHolder.components(separatedBy: .whitespacesAndNewlines)
            .filter({ !$0.isEmpty })
            .joined(separator: " ")
        return nameAfterCutWhiteSpacesAndNewlines.contains(" ")
        }

    private func isValidIssueDate(checkIssueDate: String) -> Bool {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/yy"
        let inputDate = dateFormatter.date(from: checkIssueDate)
        guard let checkInputDate = inputDate else {
            return false }
        return checkInputDate < Date()
    }

    private func isValidExpiryDate(checkExpiryDate: String) -> Bool {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/yy"
        let inputDate = dateFormatter.date(from: checkExpiryDate)
        guard let checkInputDate = inputDate else { return false }
        return checkInputDate > Date()
    }

    func getInfoCardAuto(information: [String]?) -> Card {
        var cardInfo = Card(cardHolder: "",
                            cardNumber: "",
                            issueDate: "",
                            expiryDate: "")
        guard let checkInformation = information else { return cardInfo }

        for index in stride(from: checkInformation.count - 1, to: 0, by: -1) {

            if self.isValidCardHolder(cardHolder: checkInformation[index]) &&
                (((cardInfo.cardHolder.isEmpty))) {
                cardInfo.cardHolder = checkInformation[index]
            }

            if self.isValidCardNumber(cardNumber: checkInformation[index])
                && ((cardInfo.cardNumber.isEmpty)) {
                cardInfo.cardNumber = checkInformation[index]
            }

            if self.isValidIssueDate(checkIssueDate: checkInformation[index])
                && ((cardInfo.issueDate!.isEmpty)) {
                cardInfo.issueDate = checkInformation[index]
            }

            if self.isValidExpiryDate(checkExpiryDate: checkInformation[index])
                && ((cardInfo.expiryDate!.isEmpty)) {
                cardInfo.expiryDate = checkInformation[index]
            }
        }
        return cardInfo
    }

    func parseCardInfo() {
        let context = CIContext()
        guard let cgImage = context.createCGImage(image, from: image.extent) else {
            Logger.log("Can't created cgImage from image")
            return }
        ImageDetector.detectText(cgImage: cgImage) { (strings) in
            Logger.log("with Detector: \(strings)")
            self.cardInfo = self.getInfoCardAuto(information: strings)
        }
    }

    func setTextInfoWithMode(textImage: CGImage, mode: String) {
        ImageDetector.detectText(cgImage: textImage) { (strings) in
            switch mode {
            case "Card Holder":
                self.cardInfo?.cardHolder = strings.first ?? ""

            case "Card Number":
                self.cardInfo?.cardNumber = strings.first ?? ""

            case "Issue Date":
                self.cardInfo?.issueDate = strings.first

            case "Expiry Date":
                self.cardInfo?.expiryDate = strings.first

            default:
                print("error")
            }
        }
        self.delegate?.didGetCardInfo()
    }
}
