//
//  DateTimePairsCollectionViewCell.swift
//  Hive MessagesExtension
//
//  Created by Jude Partovi on 6/24/22.
//

import UIKit

class TimesCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var timeOfDayLabel: UILabel!
    @IBOutlet weak var startTimeLabel: UILabel!
    @IBOutlet weak var endTimeLabel: UILabel!

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
