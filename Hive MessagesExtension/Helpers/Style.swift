//
//  Style.swift
//  Hive MessagesExtension
//
//  Created by Jude Partovi on 6/20/22.
//

import Foundation
import UIKit

class Style {
    
    static let primaryColor = UIColor(displayP3Red: 114/255, green: 196/255, blue: 163/255, alpha: 1)

    static let secondaryColor = UIColor(displayP3Red: 70/255, green: 70/255, blue: 70/255, alpha: 1)
    
    static func styleTextField(_ textField: UITextField, color: UIColor) {
        let bottomLine = CALayer()
                bottomLine.frame = CGRect(origin: CGPoint(x: 0, y:textField.frame.height - 2), size: CGSize(width: textField.frame.width, height:  2))
        bottomLine.backgroundColor = color.cgColor
                textField.borderStyle = UITextField.BorderStyle.none
                textField.layer.addSublayer(bottomLine)
    }
    
    static func styleButton(_ button: UIButton, color: UIColor, filled: Bool) {
        button.layer.cornerRadius = button.frame.size.height / 2.0
        if filled {
            button.backgroundColor = color
            button.tintColor = color
        } else {
            button.layer.borderWidth = 2
            button.layer.borderColor = color.cgColor
            button.tintColor = color
        }
    }
    
}

