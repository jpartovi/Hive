//
//  DateTimePairsCollectionViewCell.swift
//  Hive MessagesExtension
//
//  Created by Jude Partovi on 6/24/22.
//
/*
import UIKit

class TimesCollectionViewCell: UICollectionViewCell {
    
    //@IBOutlet weak var timeOfDayLabel: UILabel!
    //@IBOutlet weak var startTimeLabel: UILabel!
    //@IBOutlet weak var endTimeLabel: UILabel!
    
    

    var dayTimePair: DayTimePair? {
        didSet {
            guard let dayTimePair = dayTimePair else {
                print("Error loading dayTimePair")
                return
            }
            
            timeOfDayLabel.text = dayTimePair.timeFrame.timeOfDay.title
            startTimeLabel.text = dayTimePair.timeFrame.startTime.format()
            endTimeLabel.text = dayTimePair.timeFrame.endTime.format()
            
            // accessibilityLabel = accessibilityDateFormatter.string(from: day.date)
            updateSelectionStatus()
            style()
        }
    }
    
    var timeOfDayLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        label.textColor = Style.lightColor
        return label
    }()
    
    var startTimeLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        label.textColor = Style.lightColor
        return label
    }()
    
    var endTimeLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        label.textColor = Style.lightColor
        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        contentView.addSubview(timeOfDayLabel)
        contentView.addSubview(startTimeLabel)
        contentView.addSubview(endTimeLabel)
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
            timeOfDayLabel.topAnchor.constraint(equalTo: topAnchor),
            timeOfDayLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            
            startTimeLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            startTimeLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            
            endTimeLabel.bottomAnchor.constraint(equalTo: bottomAnchor),
            endTimeLabel.centerXAnchor.constraint(equalTo: centerXAnchor)
        ])
    }

    static let reuseIdentifier = String(describing: TimesCollectionViewCell.self)
}

// MARK: - Appearance
private extension TimesCollectionViewCell {

    func updateSelectionStatus() {

        if dayTimePair!.isSelected {
            showSelected()
        } else {
            showUnselected()
        }
    }

    func showSelected() {
        self.backgroundColor = Style.primaryColor
    }
    
    func showUnselected() {
        self.backgroundColor = Style.darkColor
    }
    
    func style() {
        
        self.layer.cornerRadius = 20
    }
}
*/
