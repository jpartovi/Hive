//
//  Format.swift
//  Hive MessagesExtension
//
//  Created by Jude Partovi on 7/26/22.
//

import Foundation
import UIKit

enum Format {
    
    // Font
    static func font(size: CGFloat = 18) -> UIFont {
        let font = UIFont(name: "Helvetica", size: size)!
        return font
    }
    
    // Comma separated list
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
}
