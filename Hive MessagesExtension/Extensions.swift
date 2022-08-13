//
//  Utilities.swift
//  Hive MessagesExtension
//
//  Created by Jude Partovi on 7/11/22.
//

import Foundation
import UIKit



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
    
    func isBlank() -> Bool {
        return self.trimmingCharacters(in: .whitespacesAndNewlines) == ""
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
    func size(width: CGFloat! = nil, height: CGFloat! = nil) -> UIImage {
        
        let scaleFactor: CGFloat
        
        if width != nil && height != nil {
            let targetSize = CGSize(width: width, height: height)

            // Compute the scaling ratio for the width and height separately
            let widthScaleRatio = targetSize.width / self.size.width
            let heightScaleRatio = targetSize.height / self.size.height

            // To keep the aspect ratio, scale by the smaller scaling ratio
            scaleFactor = min(widthScaleRatio, heightScaleRatio)
        } else if width != nil {
            scaleFactor = width / self.size.width
        } else if height != nil {
            scaleFactor = height / self.size.height
        } else {
            fatalError("Either width or height parameters must be filled.")
        }
        
        
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

extension UITableView {
    func setBackgroundColor(color: UIColor = Colors.backgroundColor) {
        self.backgroundColor = Colors.backgroundColor
    }
}

extension UICollectionView {
    func setBackgroundColor(color: UIColor = Colors.backgroundColor) {
        self.backgroundColor = color
    }
}
