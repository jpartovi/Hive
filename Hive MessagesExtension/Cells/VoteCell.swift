//
//  VoteCell.swift
//  Hive MessagesExtension
//
//  Created by Jack Albright on 7/12/22.
//

import UIKit

class VoteCell: UITableViewCell {
    
    static let reuseIdentifier = String(describing: VoteCell.self)
    
    let voteCount: UIView = {
        let count = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        return count
    }()
    
    let label: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = Style.darkTextColor
        return label
    }()
    
    let counter: UILabel = {
        let counter = UILabel()
        counter.translatesAutoresizingMaskIntoConstraints = false
        counter.textColor = Style.darkTextColor
        return counter
    }()
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        self.backgroundColor = Style.lightGreyColor
        self.layer.cornerRadius = self.frame.height/2
        
        self.contentView.addSubview(voteCount)
        self.contentView.addSubview(label)
        self.contentView.addSubview(counter)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let inset = CGFloat(20)

        NSLayoutConstraint.activate([
            voteCount.leftAnchor.constraint(equalTo: leftAnchor),
            voteCount.centerYAnchor.constraint(equalTo: centerYAnchor),
            
            label.leftAnchor.constraint(equalTo: leftAnchor, constant: inset),
            label.rightAnchor.constraint(equalTo: rightAnchor, constant: -inset),
            label.centerYAnchor.constraint(equalTo: centerYAnchor),
            
            
            counter.rightAnchor.constraint(equalTo: rightAnchor, constant: -inset),
            counter.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }

}
