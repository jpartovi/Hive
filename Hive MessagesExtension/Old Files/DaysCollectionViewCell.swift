//
//  DatesCollectionViewCell.swift
//  Hive MessagesExtension
//
//  Created by Jude Partovi on 6/28/22.
//
/*
import UIKit

class DaysCollectionViewCell: UICollectionViewCell {
    
    //@IBOutlet weak var dayOfWeekLabel: UILabel!
    //@IBOutlet weak var dateLabel: UILabel!
    
    var day: Day? {
        didSet {
            guard var day = day else {
                print("Error loading day")
                return
            }
            
            dayOfWeekLabel.text = day.formatDayOfWeek()
            dateLabel.text = day.formatDate()
            
            //updateSelectionStatus()
            style()
        }
    }
    
    var dayOfWeekLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        label.textColor = Style.lightColor
        return label
    }()
    
    var dateLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        label.textColor = Style.lightColor
        return label
    }()
     
    static let reuseIdentifier = String(describing: DaysCollectionViewCell.self)

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        contentView.addSubview(dayOfWeekLabel)
        contentView.addSubview(dateLabel)
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
            dayOfWeekLabel.topAnchor.constraint(equalTo: topAnchor),
            dayOfWeekLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            
            dateLabel.bottomAnchor.constraint(equalTo: bottomAnchor),
            dateLabel.centerXAnchor.constraint(equalTo: centerXAnchor)
        ])
    }
}

// MARK: - Appearance
private extension DaysCollectionViewCell {

    /*
    func updateSelectionStatus() {

        if dateTimePair!.isSelected {
            showSelected()
        } else {
            showUnselected()
        }
    }
    */

    func showSelected() {
        self.backgroundColor = Style.primaryColor
    }
    
    func showUnselected() {
        self.backgroundColor = Style.darkColor
    }
    
    func style() {
        
        self.backgroundColor = Style.secondaryColor
        self.layer.cornerRadius = 20
    }
}
*/
