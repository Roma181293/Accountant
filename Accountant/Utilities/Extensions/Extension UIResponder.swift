//
//  Extension UIResponder.swift
//  Accounting
//
//  Created by Roman Topchii on 21.11.2020.
//  Copyright © 2020 Roman Topchii. All rights reserved.
//

import UIKit

extension UIResponder: UITextFieldDelegate {
    
    public func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange,
                          replacementString string: String) -> Bool {
        let text = (textField.text ?? "") as NSString
        let newText = text.replacingCharacters(in: range, with: string)
        print("textField.tag", textField.tag)

        switch textField.tag {
        case 0...99:  // numbers
            if let regex = try? NSRegularExpression(pattern: "^[0-9]*((\\.|,)[0-9]{0,2})?$",
                                                    options: .caseInsensitive) {
                return regex.numberOfMatches(in: newText, options: .reportProgress, range:
                                                NSRange(location: 0, length: (newText as NSString).length)) > 0
            }
            return false
        case 100...199:  // names
            if let regex = try? NSRegularExpression(pattern: "^[^,:@]{0,32}?$", options: .caseInsensitive) {
                return regex.numberOfMatches(in: newText, options: .reportProgress, range:
                                                NSRange(location: 0, length: (newText as NSString).length)) > 0
            }
            return false
        case 200...299:  // comments
            if let regex = try? NSRegularExpression(pattern: "^[^,:@]{0,64}?$", options: .caseInsensitive) {
                return regex.numberOfMatches(in: newText, options: .reportProgress, range:
                                                NSRange(location: 0, length: (newText as NSString).length)) > 0
            }
            return false
        default:
            return true
        }
    }
}
