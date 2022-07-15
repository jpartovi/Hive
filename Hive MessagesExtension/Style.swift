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
    static let secondaryColor = Style.hexStringToUIColor(hex: "EED2A1")
    static let tertiaryColor = Style.hexStringToUIColor(hex: "6798C5")
    static let lightTextColor = Style.hexStringToUIColor(hex: "FFF7E8")
    static let darkTextColor = UIColor.black //Style.hexStringToUIColor(hex: "8E8E8E")
    static let greyColor = UIColor.lightGray
    static let lightGreyColor = Style.hexStringToUIColor(hex: "E3E3E3")
    //static let lightColor = UIColor.white
    static let errorColor = UIColor.red
    
    // Font
    static func font(size: CGFloat = 18) -> UIFont {
        let font = UIFont(name: "Helvetica", size: size)!
        return font
    }
    
    static func commaList(items: [String]) -> String {
        var commaList = ""
        for (index, item) in items.enumerated() {
            commaList += item
            if index != items.count - 1 {
                commaList += ", "
            }
        }
        return commaList
    }
    
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
    
    // TODO: This does not work
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

class StyleLabel: UILabel {
    func style(text: String, textColor: UIColor = Style.tertiaryColor, fontSize: CGFloat = 30) {
        self.text = text
        self.textColor = textColor
        self.font = Style.font(size: fontSize)
        self.numberOfLines = 0
    }
}

class StyleButton: UIButton {
    
    func style(color: UIColor = Style.primaryColor, filled: Bool, roundedCornerPosition: Int) {
        self.layer.cornerRadius = min(self.frame.size.height / 2.0, 20)
        self.layer.maskedCorners = RoundedCornerPosition.initWith(position: roundedCornerPosition).mask
        if filled {
            self.layer.backgroundColor = color.cgColor
            self.tintColor = Style.lightTextColor
        } else {
            self.layer.backgroundColor = Style.secondaryColor.cgColor
            self.layer.borderWidth = 2
            self.layer.borderColor = color.cgColor
            self.tintColor = color
        }
    }
    
    func embolden() {
        self.titleLabel?.font = UIFont.systemFont(ofSize: 30, weight: UIFont.Weight.bold)
    }
}

class HexButton: UIButton {
    
    func style(imageTag: String = "ColorHex", width: CGFloat, height: CGFloat, textColor: UIColor = Style.lightTextColor, fontSize: CGFloat = 18) {
        self.setBackgroundImage(UIImage(named: imageTag)?.size(width: width, height: height), for: .normal)
        self.setTitleColor(textColor, for: .normal)
        self.titleLabel?.font = Style.font(size: fontSize)
    }
    
    func getColourFromPoint(point:CGPoint) -> UIColor {
        
        let colorSpace:CGColorSpace = CGColorSpaceCreateDeviceRGB()
        let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedLast.rawValue)

        var pixelData:[UInt8] = [0, 0, 0, 0]

        let context = CGContext(data: &pixelData, width: 1, height: 1, bitsPerComponent: 8, bytesPerRow: 4, space: colorSpace, bitmapInfo: bitmapInfo.rawValue)
        context!.translateBy(x: -point.x, y: -point.y);
        self.layer.render(in: context!)

        let red:CGFloat = CGFloat(pixelData[0])/CGFloat(255.0)
        let green:CGFloat = CGFloat(pixelData[1])/CGFloat(255.0)
        let blue:CGFloat = CGFloat(pixelData[2])/CGFloat(255.0)
        let alpha:CGFloat = CGFloat(pixelData[3])/CGFloat(255.0)

        let color: UIColor = UIColor(red: red, green: green, blue: blue, alpha: alpha)
        return color
    }

    
    internal override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        
        if (!self.bounds.contains(point)) {
            return nil
        } else {
            let color : UIColor = getColourFromPoint(point: point)
            let alpha = color.cgColor.alpha
            if alpha <= 0.0 {
                return nil
            }
            return self
        }
    }
}

class ContinueHexButton: HexButton {
    
    let size: CGFloat = 100
    let textSize: CGFloat = 20
    
    override func draw(_ rect: CGRect) {
        //nextStyle()
    }
    
    func color(title: String = "Done") {
        self.setTitle(title, for: .normal)
        super.style(imageTag: "ColorHex", width: size, height: size, fontSize: textSize)
    }
    
    func grey(title: String = "Done") {
        self.setTitle(title, for: .normal)
        super.style(imageTag: "GreyHex", width: size, height: size, textColor: UIColor.white, fontSize: textSize)
    }
}

class SelectionButton: StyleButton {

    var color: UIColor = Style.secondaryColor
    var active: Bool = false
    var roundedCornerPosition: Int = RoundedCornerPosition.none.number
    
    override func draw(_ rect: CGRect) {
        
        // Update selection status
        setSelectionAppearance()
    }
    
    override func style(color: UIColor, filled: Bool, roundedCornerPosition: Int) {
        super.style(color: color, filled: filled, roundedCornerPosition: roundedCornerPosition)
        self.roundedCornerPosition = roundedCornerPosition
    }
    
    // Set the selected properties
    func setSelected() {
        super.style(color: color, filled: true, roundedCornerPosition: roundedCornerPosition)
    }
    
    // Set the deselcted properties
    func setDeselected() {
        super.style(color: color, filled: false, roundedCornerPosition: roundedCornerPosition)
    }
    
    func changeSelectionStatus() {
        active = !active
        setSelectionAppearance()
    }
    
    func setSelectionAppearance() {
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

extension UIImage {
    func size(width: CGFloat, height: CGFloat) -> UIImage {
        let targetSize = CGSize(width: width, height: height)

        // Compute the scaling ratio for the width and height separately
        let widthScaleRatio = targetSize.width / self.size.width
        let heightScaleRatio = targetSize.height / self.size.height

        // To keep the aspect ratio, scale by the smaller scaling ratio
        let scaleFactor = min(widthScaleRatio, heightScaleRatio)

        // Multiply the original image’s dimensions by the scale factor
        // to determine the scaled image size that preserves aspect ratio
        let scaledImageSize = CGSize(
            width: self.size.width * scaleFactor,
            height: self.size.height * scaleFactor
        )

        let renderer = UIGraphicsImageRenderer(size: scaledImageSize)
        let scaledImage = renderer.image { _ in
            self.draw(in: CGRect(origin: .zero, size: scaledImageSize))
        }
        
        return scaledImage
    }
}







class LargeHexButton: HexButton {
    
    let size: CGFloat = 150
    let textColor = Style.lightTextColor
    let textSize = CGFloat(25)
    
    override func draw(_ rect: CGRect) {
        style(imageTag: "ColorHex", width: size, height: size, textColor: textColor)
    }
}

class SelectionLargeHexButton: LargeHexButton {
    
    var active: Bool = false
    
    override func draw(_ rect: CGRect) {
        
        // Update selection status
        setSelectionAppearance()
    }
    
    // Set the selected properties
    func setSelected() {
        style(imageTag: "HexGreen", width: size, height: size, textColor: textColor)
    }
    
    // Set the deselcted properties
    func setDeselected() {
        style(imageTag: "ColorHex", width: size, height: size, textColor: textColor)
    }
    
    func changeSelectionStatus() {
        active = !active
        setSelectionAppearance()
    }
    
    func setSelectionAppearance() {
        if active {
            setSelected()
        } else {
            setDeselected()
        }
    }
    
}
