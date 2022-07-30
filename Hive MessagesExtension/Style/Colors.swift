//
//  Style.swift
//  Hive MessagesExtension
//
//  Created by Jude Partovi on 6/20/22.
//

import Foundation
import UIKit

enum Colors {
    
    // Colors
    static let primaryColor = Colors.hexStringToUIColor(hex: "DF9F28")
    static let secondaryColor = Colors.hexStringToUIColor(hex: "EED2A1")
    static let tertiaryColor = Colors.hexStringToUIColor(hex: "5A88B1")
    static let lightTextColor = Colors.hexStringToUIColor(hex: "FFF7E8")
    static let darkTextColor = Colors.hexStringToUIColor(hex: "4F4F4F")
    static let greyColor = Colors.hexStringToUIColor(hex: "9C9C9C")
    static let lightGreyColor = Colors.hexStringToUIColor(hex: "E3E3E3")
    static let errorColor = Colors.hexStringToUIColor(hex: "D24223")
    static let backgroundColor = Colors.hexStringToUIColor(hex: "FFFFFF")
    
    // Color palletes: https://coolors.co/palettes/popular/yellow
    
    static func hexStringToUIColor(hex: String) -> UIColor {
        
        var cString: String = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()

        if (cString.hasPrefix("#")) {
            cString.remove(at: cString.startIndex)
        }

        if ((cString.count) != 6) {
            return UIColor.gray
        }

        var rgbValue: UInt64 = 0
        Scanner(string: cString).scanHexInt64(&rgbValue)

        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }
}
