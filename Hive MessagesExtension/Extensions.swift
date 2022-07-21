//
//  Utilities.swift
//  Hive MessagesExtension
//
//  Created by Jude Partovi on 7/11/22.
//

import Foundation
import UIKit

extension UIViewController {
    func showInputDialog(title: String,
                         subtitle: String? = nil,
                         actionTitle: String? = "Done",
                         cancelTitle: String? = "Cancel",
                         autofillText: String? = nil,
                         inputPlaceholder: String? = nil,
                         inputKeyboardType: UIKeyboardType = UIKeyboardType.default,
                         cancelHandler: ((UIAlertAction) -> Swift.Void)? = nil,
                         actionHandler: ((_ text: String?) -> Void)? = nil) {
        
        let alert = UIAlertController(title: title, message: subtitle, preferredStyle: .alert)
        alert.addTextField { (textField:UITextField) in
            textField.text = autofillText
            textField.placeholder = inputPlaceholder
            textField.keyboardType = inputKeyboardType
        }
        alert.addAction(UIAlertAction(title: actionTitle, style: .default, handler: { (action:UIAlertAction) in
            guard let textField =  alert.textFields?.first else {
                actionHandler?(nil)
                return
            }
            actionHandler?(textField.text)
        }))
        alert.addAction(UIAlertAction(title: cancelTitle, style: .cancel, handler: cancelHandler))
        
        self.present(alert, animated: true, completion: nil)
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
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
    
    func expandView() {
        let MVC = (self.parent?.parent as? MessagesViewController)!
        if MVC.presentationStyle == .compact {
            MVC.requestPresentationStyle(.expanded)
        }
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
}
// textfields
// show empty on did finish editing
// show full on is editing

extension UIScrollView {
    func scrollToBottom(animated: Bool) {
        if self.contentSize.height < self.bounds.size.height { return }
        let bottomOffset = CGPoint(x: 0, y: self.contentSize.height - self.bounds.size.height)
        self.setContentOffset(bottomOffset, animated: animated)
    }
}

extension Float {
    var clean: String {
       return self.truncatingRemainder(dividingBy: 1) == 0 ? String(format: "%.0f", self) : String(self)
    }
}

extension String {
    func index(from: Int) -> Index {
        return self.index(startIndex, offsetBy: from)
    }

    func substring(from: Int) -> String {
        let fromIndex = index(from: from)
        return String(self[fromIndex...])
    }

    func substring(to: Int) -> String {
        let toIndex = index(from: to)
        return String(self[..<toIndex])
    }

    func substring(with r: Range<Int>) -> String {
        let startIndex = index(from: r.lowerBound)
        let endIndex = index(from: r.upperBound)
        return String(self[startIndex..<endIndex])
    }
}

let fadePercentage: Double = 0.2

extension UIScrollView {
    
/*
    open override func layoutSubviews() {

        super.layoutSubviews()
        
        //self.bounds = self.frame.inset(by: UIEdgeInsets(top: self.frame.height * fadePercentage, left: 0, bottom: self.frame.height * fadePercentage, right: 0))

        let transparent = UIColor.clear.cgColor
        let opaque = UIColor.black.cgColor

        let maskLayer = CALayer()
        maskLayer.frame = self.bounds

        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = CGRect(x: self.bounds.origin.x, y: 0, width: self.bounds.size.width, height: self.bounds.size.height)
        gradientLayer.colors = [transparent, opaque, opaque, transparent]
        gradientLayer.locations = [0, NSNumber(floatLiteral: fadePercentage), NSNumber(floatLiteral: 1 - fadePercentage), 1]

        maskLayer.addSublayer(gradientLayer)
        self.layer.mask = maskLayer

    }
 */
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
