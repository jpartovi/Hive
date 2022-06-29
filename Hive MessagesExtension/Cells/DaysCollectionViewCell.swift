//
//  DatesCollectionViewCell.swift
//  Hive MessagesExtension
//
//  Created by Jude Partovi on 6/28/22.
//

import UIKit

class DaysCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var dayOfWeekLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    
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
    
    override func apply(_ layoutAttributes: UICollectionViewLayoutAttributes) {
        super.apply(layoutAttributes)
        
        // dayOfWeekLabel.text = day!.formatDayOfWeek()
        // dateLabel.text = day!.formatDate()
    }

    static let reuseIdentifier = String(describing: TimesCollectionViewCell.self)
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
        
        self.layer.cornerRadius = 20
    }
}
