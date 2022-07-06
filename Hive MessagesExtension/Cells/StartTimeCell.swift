//
//  StartTimeCell.swift
//  Hive MessagesExtension
//
//  Created by Jude Partovi on 7/3/22.
//

import Foundation
import UIKit

class StartTimeCell: UICollectionViewCell {
    
    static let reuseIdentifier = String(describing: StartTimeCell.self)
    
    var timeLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        label.textColor = Style.lightColor
        return label
    }()
    
    var time: Time? {
        didSet {
            guard let time = time else {
                print("Error loading start time")
                return
            }
            
            timeLabel.text = time.format()
        }
    }
    
    var timeSelected: Bool? {
        didSet {
            guard timeSelected != nil else {
                print ("Error loading time selection status")
                return
            }
            
            updateSelectionStatus()
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.backgroundColor = Style.primaryColor
        contentView.addSubview(timeLabel)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        // This allows for rotations and trait collection
        // changes (e.g. entering split view on iPad) to update constraints correctly.
        // Removing old constraints allows for new ones to be created
        // regardless of the values of the old ones
        NSLayoutConstraint.activate([
            timeLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            timeLabel.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }

    func updateSelectionStatus() {

        if timeSelected! {
            showSelected()
        } else {
            showUnselected()
        }
    }

    func showSelected() {
        // TODO: Show selected
        self.backgroundColor = Style.secondaryColor
    }
    
    func showUnselected() {
        // TODO: Show unselected
        self.backgroundColor = Style.primaryColor
    }
}
