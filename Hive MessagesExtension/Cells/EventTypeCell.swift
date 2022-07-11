//
//  EventTypeCell.swift
//  Hive MessagesExtension
//
//  Created by Jude Partovi on 7/8/22.
//

import Foundation
import UIKit

class EventTypeCell: UICollectionViewCell {
    
    static let reuseIdentifier = String(describing: EventTypeCell.self)
    
    let hexBorder: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(named: "HexBorder")?.size(width: 130, height: 150)
        imageView.clipsToBounds = false
        return imageView
    }()
    
    let hexButton: HexButton = {
        let button = HexButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.style(imageTag: "HexFill", width: 100, height: 120, textColor: Style.lightTextColor, font: .systemFont(ofSize: 20))
        return button
    }()
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        self.contentView.isUserInteractionEnabled = true
        //self.contentView.layer.cornerRadius = self.contentView.frame.height / 2
        
        self.contentView.addSubview(hexBorder)
        self.contentView.addSubview(hexButton)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()

        NSLayoutConstraint.activate([
            hexButton.centerXAnchor.constraint(equalTo: centerXAnchor),
            hexButton.centerYAnchor.constraint(equalTo: centerYAnchor),
            
            hexBorder.centerXAnchor.constraint(equalTo: centerXAnchor),
            hexBorder.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }
}
