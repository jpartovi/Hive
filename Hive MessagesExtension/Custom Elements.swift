//
//  Custom Elements.swift
//  Hive MessagesExtension
//
//  Created by Jude Partovi on 7/20/22.
//

import Foundation
import UIKit
import Messages
/*
class ErrorLabel: UILabel {
    
    // TODO: This does not work
    override func drawText(in rect: CGRect) {
        super.drawText(in: rect)
        
        self.textColor = Style.errorColor
        self.font = UIFont.systemFont(ofSize: 10.0)
        self.alpha = 0
    }
    
    func showMessage(message: String) {
        self.text = message
        self.alpha = 1
    }
}
*/
class StyleTextField: UITextField {
    
    var fullColor: UIColor = Style.greyColor
    let emptyColor: UIColor = Style.errorColor
    var bottomLine = CALayer()
    
    func addDoneButton(){
        let doneToolbar: UIToolbar = UIToolbar(frame: CGRect.init(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 50))
        doneToolbar.barStyle = .default

        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let doneButton: UIBarButtonItem = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(self.doneButtonAction))
        
        let items = [flexSpace, doneButton]
        doneToolbar.items = items
        doneToolbar.sizeToFit()

        self.inputAccessoryView = doneToolbar
    }

    @objc func doneButtonAction(sender: StyleTextField){
        print("donebuttonaction")
        superview!.endEditing(true)
    }
    
    func style(placeholderText: String, color: UIColor? = nil, textColor: UIColor = Style.darkTextColor, fontSize: CGFloat = 18) {
        if let color = color {
            self.fullColor = color
        }
        //underline(color: fullColor)
        self.placeholder = placeholderText
        self.textColor = textColor
        self.adjustsFontSizeToFitWidth = false
        self.font = Style.font(size: fontSize)
        self.borderStyle = .none
        self.layer.addSublayer(bottomLine)
        colorStatus()
    }
    
    // Check if the textfield is empty or not
    func getStatus(withDisplay: Bool) -> Bool {
        let color: UIColor
        let isFull: Bool
        if self.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" {
            isFull = false
            color = emptyColor
        } else {
            isFull = true
            color = fullColor
        }
        if withDisplay {
            underline(color: color)
        }
        return isFull
    }
    
    func underline(color: UIColor) {
        bottomLine.frame = CGRect(origin: CGPoint(x: 0, y: self.frame.height - 2), size: CGSize(width: self.frame.width, height:  2))
        bottomLine.backgroundColor = color.cgColor
        self.borderStyle = UITextField.BorderStyle.none
    }
    
    func colorStatus() {
        let color: UIColor
        if self.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" {
            color = emptyColor
        } else {
            color = fullColor
        }
        underline(color: color)
    }
    
    func resetColor() {
        underline(color: fullColor)
    }
}

class StyleLabel: UILabel {
    func style(text: String, textColor: UIColor = Style.tertiaryColor, fontSize: CGFloat = 30) {
        self.text = text
        self.textColor = textColor
        self.font = Style.font(size: fontSize)
        self.numberOfLines = 0
        self.textAlignment = .center
    }
    
    func adjustHeight(){
        
        let label: UILabel = UILabel(frame: CGRect(x: 0, y: 0, width: self.frame.width, height: CGFloat.greatestFiniteMagnitude))
        label.numberOfLines = 0
        label.lineBreakMode = NSLineBreakMode.byWordWrapping
        label.font = self.font
        label.text = self.text

        label.sizeToFit()
        self.heightAnchor.constraint(equalToConstant: label.frame.height).isActive = true
    }
}


class HexButton: UIButton {
    
    var size: CGFloat = 100
    var textSize: CGFloat = 20
    
    func size(size: CGFloat, textSize: CGFloat) {
        self.size = size
        self.textSize = textSize
    }
    
    func color(title: String) {
        style(title: title, imageTag: "ColorHex")
    }
    
    func grey(title: String) {
        style(title: title, imageTag: "GreyHex", textColor: UIColor.white)
    }
    
    func style(title: String? = nil, imageTag: String = "ColorHex", textColor: UIColor = Style.lightTextColor) {
        let backgroundImage = UIImage(named: imageTag)?.size(width: size, height: size)
        self.setBackgroundImage(backgroundImage, for: .normal)
        self.setTitleColor(textColor, for: .normal)
        self.titleLabel?.font = Style.font(size: textSize)
        self.titleLabel?.widthAnchor.constraint(equalToConstant: (backgroundImage?.size.width)! - 20).isActive = true
        self.titleLabel?.textAlignment = .center
        self.titleLabel?.numberOfLines = 0
        if title != nil {
            self.setTitle(title, for: .normal)
        }
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

class LargeHexButton: HexButton {
    
    let sizef: CGFloat = 150
    let textfSize = CGFloat(25)
    
    override func draw(_ rect: CGRect) {
        //style(imageTag: "ColorHex", textColor: Style.lightGreyColor)
    }
}

class SelectionLargeHexButton: LargeHexButton {
    
    var active: Bool = false
    
    // Set the selected properties
    func setSelected() {
        style(imageTag: "SelectedHex")
    }
    
    // Set the deselcted properties
    func setDeselected() {
        style(imageTag: "ColorHex")
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

class StyleViewController: MSMessagesAppViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        enableTouchAwayKeyboardDismiss()
        setBackgroundColor()
    }
    
    func setBackgroundColor() {
        self.view.backgroundColor = Style.backgroundColor
    }
    
    func addHexFooter() {
        let frameHeight = self.view.frame.height
        let frameWidth = self.view.frame.width
        let footerImage = UIImage(named: "HexFooter")?.size(width: frameWidth, height: frameWidth * 0.34)
        let footerImageView = UIImageView( image: footerImage)
        footerImageView.frame = CGRect(x: 0, y: frameHeight - footerImageView.frame.height, width: frameWidth, height: footerImageView.frame.height)
        self.view.addSubview(footerImageView)
        self.view.sendSubviewToBack(footerImageView)
    }
    
    func enableTouchAwayKeyboardDismiss() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    //Calls this function when the tap is recognized.
    @objc func dismissKeyboard() {
        print("dismissed")
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }

    func textFieldsFull(textFields: [StyleTextField], withDisplay: Bool) -> Bool {
        var textFieldsFull = true
        print(textFields)
        for textField in textFields {
            if textField.getStatus(withDisplay: withDisplay) == false {
                textFieldsFull = false
            }
        }
        return textFieldsFull
    }
    
    func heightForView(text:String, font:UIFont, width:CGFloat) -> CGFloat{
        let label:UILabel = UILabel(frame: CGRect(x: 0, y: 0, width: width, height: CGFloat.greatestFiniteMagnitude))
        label.numberOfLines = 0
        label.lineBreakMode = NSLineBreakMode.byWordWrapping
        label.font = font
        label.text = text

        label.sizeToFit()
        return label.frame.height
    }
}

/*
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

class PrimaryButton: StyleButton {
    
    var color: UIColor = Style.primaryColor
    
    override func draw(_ rect: CGRect) {
        
        super.style(color: color, filled: true, roundedCornerPosition: RoundedCornerPosition.all.number)
        
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
*/
