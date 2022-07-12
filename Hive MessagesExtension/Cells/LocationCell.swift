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
    
    let titleTextField: UITextField = {
        let textField = UITextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.textColor = Style.darkTextColor
        textField.placeholder = "Enter Location Name"
        return textField
    }()
    
    let changeAddressButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitleColor(Style.greyColor, for: .normal)
        button.contentHorizontalAlignment = .left
        button.titleLabel?.lineBreakMode = .byTruncatingTail
        return button
    }()
    
    let addOrRemoveAddressButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("+ address", for: .normal)
        button.setTitleColor(.white, for: .normal)
        return button
    }()
    
    let deleteButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        //button.clipsToBounds = true
        button.setTitle("X", for: .normal)
        
        button.backgroundColor = Style.greyColor
        button.setTitleColor(.white, for: .normal)
        return button
    }()
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        self.backgroundColor = Style.lightGreyColor
        self.layer.cornerRadius = self.frame.height / 2 
        
        self.contentView.addSubview(titleTextField)
        self.contentView.addSubview(changeAddressButton)
        self.contentView.addSubview(addOrRemoveAddressButton)
        self.contentView.addSubview(deleteButton)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let inset = CGFloat(20)

        NSLayoutConstraint.activate([
            titleTextField.leftAnchor.constraint(equalTo: leftAnchor, constant: inset),
            titleTextField.rightAnchor.constraint(equalTo: addOrRemoveAddressButton.leftAnchor, constant: -inset),
            titleTextField.topAnchor.constraint(equalTo: topAnchor, constant: 12),
            titleTextField.heightAnchor.constraint(equalToConstant: 26),
        
            changeAddressButton.leftAnchor.constraint(equalTo: leftAnchor, constant: inset),
            changeAddressButton.rightAnchor.constraint(equalTo: deleteButton.leftAnchor, constant: -inset),
            changeAddressButton.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -12),
            changeAddressButton.heightAnchor.constraint(equalToConstant: 26),
            
            addOrRemoveAddressButton.rightAnchor.constraint(equalTo: deleteButton.leftAnchor, constant: -inset),
            addOrRemoveAddressButton.topAnchor.constraint(equalTo: topAnchor, constant: 12),
            addOrRemoveAddressButton.heightAnchor.constraint(equalToConstant: 26),
            addOrRemoveAddressButton.widthAnchor.constraint(equalToConstant: 80),
            
            deleteButton.heightAnchor.constraint(equalToConstant: 26),//min(self.frame.height - (inset * 2), 30)),
            deleteButton.widthAnchor.constraint(equalTo: deleteButton.heightAnchor),
            deleteButton.rightAnchor.constraint(equalTo: rightAnchor, constant: -inset),
            deleteButton.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
        
        
        deleteButton.layer.cornerRadius = deleteButton.frame.height / 2
    }

}
