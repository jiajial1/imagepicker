//
//  UITextFieldDelegate.swift
//  imagepicker
//
//  Created by Jiajia Li on 12/10/22.
//

import Foundation
import UIKit

// MARK: - CashTextFieldDelegate: NSObject, UITextFieldDelegate

class CashTextFieldDelegate: NSObject, UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField.text!.isEmpty {
            textField.text = "$0.00"
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        
        return true;
    }
}

