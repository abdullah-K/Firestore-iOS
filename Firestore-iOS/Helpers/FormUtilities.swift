//
//  FormUtilities.swift
//  Firestore-iOS
//
//  Created by Abdullah Khan on 2019-09-14.
//  Copyright © 2019 Abdullah Khan. All rights reserved.
//

import Foundation
import UIKit

class FormUtilities {
    
    // test password validity against a regex pattern
    static func isValidPassword(_ password: String) -> Bool {
        // Minimum eight characters, at least one letter and one number
        let passwordTest = NSPredicate(format: "SELF MATCHES %@", "^(?=.*[A-Za-z])(?=.*\\d)[A-Za-z\\d]{8,}$");
        return passwordTest.evaluate(with: password)
    }
    
    static func sanitizeInput(_ input:UITextField) -> String {
        return input.text!.trimmingCharacters(in: .whitespacesAndNewlines)
    }

}
