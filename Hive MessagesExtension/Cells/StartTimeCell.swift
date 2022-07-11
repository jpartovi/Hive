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
        label.textColor = Style.lightTextColor
        return label
    }()
    
    private lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
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
        
        contentView.addSubview(imageView)
        contentView.addSubview(timeLabel)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        NSLayoutConstraint.activate([
            timeLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            timeLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            
            imageView.centerXAnchor.constraint(equalTo: centerXAnchor),
            imageView.centerYAnchor.constraint(equalTo: centerYAnchor)
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
        imageView.image = UIImage(named: "SelectedLongHex")?.size(width: self.frame.width, height: self.frame.width)
    }
    
    func showUnselected() {
        // TODO: Show unselected
        imageView.image = UIImage(named: "LongHex")?.size(width: self.frame.width, height: self.frame.width)

    }
}
