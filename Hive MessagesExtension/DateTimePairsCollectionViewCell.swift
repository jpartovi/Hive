//
//  DateTimePairsCollectionViewCell.swift
//  Hive MessagesExtension
//
//  Created by Jude Partovi on 6/24/22.
//

import UIKit

class DateTimePairsCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var timeOfDayLabel: UILabel!
    @IBOutlet weak var timeRangeLabel: UILabel!
    
    /*
    private lazy var selectionBackgroundView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.clipsToBounds = false//true
        view.backgroundColor = Style.primaryColor
        return view
    }()
    */
    /*
    var numberLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        label.textColor = Style.darkColor
        return label
    }()
     */
    
    var dateTimePair: DateTimePair? {
        didSet {
            guard var dateTimePair = dateTimePair else {
                print("Error loading dateTimePair")
                return
            }
            

            dateLabel.text = dateTimePair.formatDate()
            timeOfDayLabel.text = dateTimePair.timeFrame.timeOfDay.title
            timeRangeLabel.text = "00:00_m-00:00_m"
            //numberLabel.text = day.number
            
            // accessibilityLabel = accessibilityDateFormatter.string(from: day.date)
            updateSelectionStatus()
            //style(inFuture: day.inFuture, inNextMonth: day.inNextMonth)
        }
    }

    static let reuseIdentifier = String(describing: DateTimePairsCollectionViewCell.self)
/*
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        print("INIT")
        dateLabel.text = dateTimePair?.formatDate()
        timeOfDayLabel.text = dateTimePair?.timeFrame.timeOfDay.title
        timeRangeLabel.text = "00:00_m-00:00_m"
        // contentView.addSubview(selectionBackgroundView)
        //contentView.addSubview(numberLabel)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
*/
    override func layoutSubviews() {
        super.layoutSubviews()

        // This allows for rotations and trait collection
        // changes (e.g. entering split view on iPad) to update constraints correctly.
        // Removing old constraints allows for new ones to be created
        // regardless of the values of the old ones
        //NSLayoutConstraint.deactivate(selectionBackgroundView.constraints)

        //let selectorSize = min(min(frame.width, frame.height) - 10, 60)

        /*
        NSLayoutConstraint.activate([
            numberLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            numberLabel.centerXAnchor.constraint(equalTo: centerXAnchor),

            selectionBackgroundView.centerYAnchor.constraint(equalTo: numberLabel.centerYAnchor),
            selectionBackgroundView.centerXAnchor.constraint(equalTo: numberLabel.centerXAnchor),
            selectionBackgroundView.widthAnchor.constraint(equalToConstant: selectorSize),
            selectionBackgroundView.heightAnchor.constraint(equalTo: selectionBackgroundView.widthAnchor),
        ])
         */
         

        //selectionBackgroundView.layer.cornerRadius = selectorSize / 2
    }
}

// MARK: - Appearance
private extension DateTimePairsCollectionViewCell {

    func updateSelectionStatus() {

        if dateTimePair!.isSelected {
            showSelected()
        } else {
            showUnselected()
        }
    }

    func showSelected() {

        //numberLabel.textColor = Style.lightColor
        self.backgroundColor = Style.primaryColor
        print("Selected")
    }
    
    func showUnselected() {
        self.backgroundColor = Style.errorColor
        print("Unselected")
    }
    
    func style(inFuture: Bool, inNextMonth: Bool) {

    }
}
