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

enum ScanMode {
    case cardHolder
    case cardNumBer
    case issueDate
    case expiryDate

    static let modes = [cardHolder, cardNumBer, issueDate, expiryDate]

    var modeString: String {
        switch self {
        case .cardHolder:
            return "Card Holder"

        case .cardNumBer:
            return "Card Number"

        case .issueDate:
            return "Issue Date"

        case .expiryDate:
            return "Expiry Date"
        }
    }
}

enum ResultCheckInfo: String {
    case success
    case invalidCardHolder
    case invalidCardNumber
    case invalidIssueDate
    case invalidExpiryDate
}

class ScanTextViewModel {

    var infoCard: Card?
    var image: CIImage
    private let maxCardNumber = 19
    private let minCardNumber = 16
    weak var delegate: ScanTextViewModelDelegate?

    init(image: CIImage) {
        self.image = image
    }

    func checkValidInfo(infoCard: Card) -> ResultCheckInfo {

        // Check valid Name
        if !isValidCardHolder(cardHolder: infoCard.cardHolder) {
            return ResultCheckInfo.invalidCardHolder
        }

        // Check valid bank number
        if !isValidCardNumber(cardNumber: infoCard.cardNumber) {
            return ResultCheckInfo.invalidCardNumber
        }

        // check valid created date
        if !isValidIssueDate(checkIssueDate: infoCard.issueDate ?? "") {
            return ResultCheckInfo.invalidIssueDate
        }

        // check valid validate date
        if !isValidExpiryDate(checkExpiryDate: infoCard.expiryDate ?? "") {
            return ResultCheckInfo.invalidExpiryDate
        }
        self.infoCard = infoCard
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
        let dateStringAfterFilter = String(checkIssueDate.getDateString())
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/yy"
        let inputDate = dateFormatter.date(from: dateStringAfterFilter)
        guard let checkInputDate = inputDate else {
            return false }
        return checkInputDate < Date()
    }

    private func isValidExpiryDate(checkExpiryDate: String) -> Bool {
        let dateStringAfterFilter = String(checkExpiryDate.getDateString())
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/yy"
        let inputDate = dateFormatter.date(from: dateStringAfterFilter)
        guard let checkInputDate = inputDate else { return false }
        return checkInputDate > Date()
    }

    private func getInfoCardAuto(information: [String]?) -> Card {
        Logger.log(information as Any)
        var infoCard = Card(cardHolder: "",
                            cardNumber: "",
                            issueDate: "",
                            expiryDate: "")
        guard let checkInformation = information else { return infoCard }

        for index in stride(from: checkInformation.count - 1, to: 0, by: -1) {

            if isValidCardHolder(cardHolder: checkInformation[index]) &&
                (((infoCard.cardHolder.isEmpty))) {
                infoCard.cardHolder = checkInformation[index]
            }

            if isValidCardNumber(cardNumber: checkInformation[index])
                && ((infoCard.cardNumber.isEmpty)) {
                infoCard.cardNumber = checkInformation[index]
            }

            if isValidIssueDate(checkIssueDate: checkInformation[index])
                && ((infoCard.issueDate!.isEmpty)) {
                infoCard.issueDate = String(checkInformation[index].getDateString())
            }

            if isValidExpiryDate(checkExpiryDate: checkInformation[index])
                && ((infoCard.expiryDate!.isEmpty)) {
                infoCard.expiryDate = String(checkInformation[index].getDateString())
            }
        }
        return infoCard
    }

    func parseCardInfo() {
        let context = CIContext()
        guard let cgImage = context.createCGImage(image, from: image.extent) else {
            Logger.log("Can't created cgImage from image")
            return }

        ImageDetector.detectText(cgImage: cgImage) { (resultOfDetectText) in
            switch resultOfDetectText {
            case .success(let strings):
                self.infoCard = self.getInfoCardAuto(information: strings)

            case .failure(let error):
                Logger.log(error.localizedDescription)
            }
        }
    }

    func setTextInfoWithMode(textImage: CGImage, mode: ScanMode) {
        ImageDetector.detectText(cgImage: textImage) { (resultOfDetectText) in
            switch resultOfDetectText {
            case .success(let strings):
                switch mode {
                case .cardHolder:
                    self.infoCard?.cardHolder = strings.first ?? ""

                case .cardNumBer:
                    self.infoCard?.cardNumber = strings.first ?? ""

                case .issueDate:
                    self.infoCard?.issueDate = strings.first

                case .expiryDate:
                    self.infoCard?.expiryDate = strings.first
                }

            case .failure(let error):
                Logger.log(error.localizedDescription)
            }
        }
        delegate?.didGetCardInfo()
    }
}
