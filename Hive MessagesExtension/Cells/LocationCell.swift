//
//  LocationCell.swift
//  Hive MessagesExtension
//
//  Created by Jude Partovi on 7/6/22.
//

import Foundation
import UIKit

class LocationCell: UITableViewCell {
    
    static let reuseIdentifier = String(describing: LocationCell.self)
    
    let textField: UITextField = {
        let textField = UITextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.textColor = Style.darkTextColor
        return textField
    }()
    
    let addressLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = Style.greyColor
        return label
    }()
    
    let deleteButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.clipsToBounds = true
        button.setTitle("X", for: .normal)
        
        button.backgroundColor = Style.greyColor
        button.tintColor = Style.lightTextColor
        return button
    }()
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        self.backgroundColor = Style.lightGreyColor
        self.layer.cornerRadius = self.frame.height / 2 
        
        self.contentView.addSubview(textField)
        self.contentView.addSubview(addressLabel)
        self.contentView.addSubview(deleteButton)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let inset = CGFloat(20)

        NSLayoutConstraint.activate([
            textField.leftAnchor.constraint(equalTo: leftAnchor, constant: inset),
            textField.rightAnchor.constraint(equalTo: deleteButton.leftAnchor, constant: -inset),
            textField.centerYAnchor.constraint(equalTo: centerYAnchor, constant: -15),
            
            addressLabel.leftAnchor.constraint(equalTo: leftAnchor, constant: inset),
            addressLabel.rightAnchor.constraint(equalTo: deleteButton.leftAnchor, constant: -inset),
            addressLabel.centerYAnchor.constraint(equalTo: centerYAnchor, constant: 15),
            
            deleteButton.heightAnchor.constraint(equalToConstant: min(self.frame.height - (inset * 2), 30)),
            deleteButton.widthAnchor.constraint(equalTo: deleteButton.heightAnchor),
            deleteButton.rightAnchor.constraint(equalTo: rightAnchor, constant: -inset),
            deleteButton.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
        
        
        deleteButton.layer.cornerRadius = deleteButton.frame.height / 2
    }

}
