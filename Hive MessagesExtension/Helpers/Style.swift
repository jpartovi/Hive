//
//  Style.swift
//  Hive MessagesExtension
//
//  Created by Jude Partovi on 6/20/22.
//

import Foundation
import UIKit

class Style {
    
    
    // Color palletes: https://coolors.co/palettes/popular/yellow
    
    static func hexStringToUIColor(hex: String) -> UIColor {
        
        var cString:String = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()

        if (cString.hasPrefix("#")) {
            cString.remove(at: cString.startIndex)
        }

        if ((cString.count) != 6) {
            return UIColor.gray
        }

        var rgbValue:UInt64 = 0
        Scanner(string: cString).scanHexInt64(&rgbValue)

        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }
    
    // Colors
    static let primaryColor = Style.hexStringToUIColor(hex: "DF9F28")
    static let secondaryColor = Style.hexStringToUIColor(hex: "c36f09")
    static let darkColor = Style.hexStringToUIColor(hex: "3a3b3c")
    static let lightColor = UIColor.white
    static let errorColor = UIColor.red
    
    // Formating functions
    static func styleTextFieldAndLabel(_ textField: UITextField,_ label: UILabel) {
        let bottomLine = CALayer()
        bottomLine.frame = CGRect(origin: CGPoint(x: 0, y:textField.frame.height - 2), size: CGSize(width: textField.frame.width, height:  2))
        bottomLine.backgroundColor = primaryColor.cgColor
        textField.borderStyle = UITextField.BorderStyle.none
        textField.layer.addSublayer(bottomLine)
    }
}

class ErrorLabel: UILabel {
    
    // BUG: This does not work
    override func drawText(in rect: CGRect) {
        super.drawText(in: rect)
        
        self.textColor = Style.errorColor
        self.font = UIFont.systemFont(ofSize: 10.0)
        self.alpha = 0
        print("BLAAAAHHH")
    }
    
    func showMessage(message: String) {
        self.text = message
        self.alpha = 1
    }
}

class StyleButton: UIButton {
    
    func style(color: UIColor, filled: Bool, roundedCornerPosition: Int) {
        self.layer.cornerRadius = min(self.frame.size.height / 2.0, 20)
        self.layer.maskedCorners = RoundedCornerPosition.initWith(position: roundedCornerPosition).mask
        if filled {
            self.layer.backgroundColor = color.cgColor
            self.tintColor = UIColor.white
        } else {
            self.layer.backgroundColor = Style.lightColor.cgColor
            self.layer.borderWidth = 2
            self.layer.borderColor = color.cgColor
            self.tintColor = color
        }
    }
    
    func embolden() {
        self.titleLabel?.font = UIFont.systemFont(ofSize: 30, weight: UIFont.Weight.bold)
    }
}

class SelectionButton: StyleButton {

    var color: UIColor = Style.primaryColor
    var active: Bool = false
    var roundedCornerPosition: Int = RoundedCornerPosition.none.number
    
    override func draw(_ rect: CGRect) {
        
        // Update selection status
        updateSelectionStatus()
        
        // self.embolden()
        
        // Respond to touch events by user
        self.addTarget(self, action: #selector(onPress), for: .touchUpInside)
    }
    
    override func style(color: UIColor, filled: Bool, roundedCornerPosition: Int) {
        super.style(color: color, filled: filled, roundedCornerPosition: roundedCornerPosition)
        self.roundedCornerPosition = roundedCornerPosition
    }
    
    @objc func onPress() {
        active = !active
        updateSelectionStatus()
    }
    
    // Set the selected properties
    func setSelected() {
        super.style(color: color, filled: true, roundedCornerPosition: roundedCornerPosition)
    }
    
    // Set the deselcted properties
    func setDeselected() {
        super.style(color: color, filled: false, roundedCornerPosition: roundedCornerPosition)
    }
    
    func updateSelectionStatus() {
        if active {
            setSelected()
        } else {
            setDeselected()
        }
    }
}

class PrimaryButton: StyleButton {
    
    var color: UIColor = Style.primaryColor
    
    override func draw(_ rect: CGRect) {
        
        super.style(color: color, filled: true, roundedCornerPosition: RoundedCornerPosition.all.number)
        
    }
}

enum RoundedCornerPosition {
     
    case none
    case topLeft
    case topRight
    case bottomLeft
    case bottomRight
    case bothTop
    case bothleft
    case topLeftBottomRight
     
    case all
    case notTopLeft
    case notTopRight
    case notBottomLeft
    case notBottomRight
    case bothBotton
    case bothRight
    case topRightBottomLeft
     
    
    static func initWith(position: Int) -> Self {
        switch position {
            
            case 1:
                return .none
            case 2:
                return .topLeft
            case 3:
                return .topRight
            case 4:
                return .bottomLeft
            case 5:
                return .bottomRight
            case 6:
                return .bothTop
            case 7:
                return .bothleft
            case 8:
                return .topLeftBottomRight
            
            case -1:
                return .all
            case -2:
                return .notTopLeft
            case -3:
                return .notTopRight
            case -4:
                return .notBottomLeft
            case -5:
                return .notBottomRight
            case -6:
                return .bothBotton
            case -7:
                return .bothRight
            case -8:
                return .topRightBottomLeft
                
            default:
                return .none
        }
    }
    
    var number: Int {
        switch self {
            
            case .none:
                return 1
            case .topLeft:
                return 2
            case .topRight:
                return 3
            case .bottomLeft:
                return 4
            case .bottomRight:
                return 5
            case .bothTop:
                return 6
            case .bothleft:
                return 7
            case .topLeftBottomRight:
                return 8
                     
            case .all:
                return -1
            case .notTopLeft:
                return -2
            case .notTopRight:
                return -3
            case .notBottomLeft:
                return -4
            case .notBottomRight:
                return -5
            case .bothBotton:
                return -6
            case .bothRight:
                return -7
            case .topRightBottomLeft:
                return -8
            
            default:
                return 1
        }
    }
    
    
    var mask: CACornerMask {
        switch self {
            
            case .none:
                return []
            case .topLeft:
                return [.layerMinXMinYCorner]
            case .topRight:
                return [.layerMaxXMinYCorner]
            case .bottomLeft:
                return [.layerMinXMaxYCorner]
            case .bottomRight:
                return [.layerMaxXMaxYCorner]
            case .bothTop:
                return [.layerMinXMinYCorner, .layerMaxXMinYCorner]
            case .bothleft:
                return [.layerMinXMinYCorner, .layerMinXMaxYCorner]
            case .topLeftBottomRight:
                return [.layerMinXMinYCorner, .layerMaxXMaxYCorner]
                     
            case .all:
            return [.layerMinXMinYCorner, .layerMaxXMinYCorner, .layerMinXMaxYCorner, .layerMaxXMaxYCorner]
            case .notTopLeft:
                return [.layerMaxXMinYCorner, .layerMinXMaxYCorner, .layerMaxXMaxYCorner]
            case .notTopRight:
                return [.layerMinXMinYCorner, .layerMinXMaxYCorner, .layerMaxXMaxYCorner]
            case .notBottomLeft:
                return [.layerMinXMinYCorner, .layerMaxXMinYCorner, .layerMaxXMaxYCorner]
            case .notBottomRight:
                return [.layerMinXMinYCorner, .layerMaxXMinYCorner, .layerMinXMaxYCorner]
            case .bothBotton:
                return [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
            case .bothRight:
                return [.layerMaxXMinYCorner, .layerMaxXMaxYCorner]
            case .topRightBottomLeft:
                return [.layerMaxXMinYCorner, .layerMinXMaxYCorner]
        }
    }
}


