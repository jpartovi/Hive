//
//  DateCollectionViewCell.swift
//  Hive MessagesExtension
//
//  Created by Jude Partovi on 6/21/22.
//

import UIKit

class DateCollectionViewCell: UICollectionViewCell {
    
    private lazy var selectionBackgroundView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.clipsToBounds = false//true
        view.backgroundColor = Style.primaryColor
        return view
    }()
    
    private lazy var monthBackgroundView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.clipsToBounds = false//true
        view.alpha = 0.5
        return view
    }()
    
    var numberLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        label.textColor = Style.darkColor
        return label
    }()
    
    /*
    private lazy var accessibilityDateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.calendar = Calendar(identifier: .gregorian)
        dateFormatter.setLocalizedDateFormatFromTemplate("EEEE, MMMM d")
        return dateFormatter
    }()
    */
     
    static let reuseIdentifier = String(describing: DateCollectionViewCell.self)

    var day: Day? {
        didSet {
            guard let day = day else { return }

            numberLabel.text = day.number
            
            // accessibilityLabel = accessibilityDateFormatter.string(from: day.date)
            updateSelectionStatus()
            style(inFuture: day.inFuture, inNextMonth: day.inNextMonth)
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        isAccessibilityElement = true
        accessibilityTraits = .button
        
        contentView.addSubview(selectionBackgroundView)
        contentView.addSubview(monthBackgroundView)
        contentView.addSubview(numberLabel)
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
        NSLayoutConstraint.deactivate(selectionBackgroundView.constraints)

        let selectorSize = min(min(frame.width, frame.height) - 10, 60)

        
        NSLayoutConstraint.activate([
            numberLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            numberLabel.centerXAnchor.constraint(equalTo: centerXAnchor),

            selectionBackgroundView.centerYAnchor.constraint(equalTo: numberLabel.centerYAnchor),
            selectionBackgroundView.centerXAnchor.constraint(equalTo: numberLabel.centerXAnchor),
            selectionBackgroundView.widthAnchor.constraint(equalToConstant: selectorSize),
            selectionBackgroundView.heightAnchor.constraint(equalTo: selectionBackgroundView.widthAnchor),
            
            monthBackgroundView.centerYAnchor.constraint(equalTo: numberLabel.centerYAnchor),
            monthBackgroundView.centerXAnchor.constraint(equalTo: numberLabel.centerXAnchor),
            monthBackgroundView.widthAnchor.constraint(equalToConstant: frame.width + 1),
            monthBackgroundView.heightAnchor.constraint(equalToConstant: frame.height)
        ])
         

        selectionBackgroundView.layer.cornerRadius = selectorSize / 2
    }

    /*
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        layoutSubviews()
    }
    */
}

// MARK: - Appearance
private extension DateCollectionViewCell {

    func updateSelectionStatus() {
        guard let day = day else { return }

        if day.isSelected {
            showSelected()
        } else {
            showUnselected()
        }
    }

    /*
    var isSmallScreenSize: Bool {
        let isCompact = traitCollection.horizontalSizeClass == .compact
        let smallWidth = UIScreen.main.bounds.width <= 350
        let widthGreaterThanHeight = UIScreen.main.bounds.width > UIScreen.main.bounds.height

        return isCompact && (smallWidth || widthGreaterThanHeight)
    }
     */

    func showSelected() {
        accessibilityTraits.insert(.selected)
        accessibilityHint = nil

        //numberLabel.textColor = Style.lightColor
        selectionBackgroundView.isHidden = false
        //selectionBackgroundView.isHidden = isSmallScreenSize
    }
    
    func showUnselected() {
        selectionBackgroundView.isHidden = true
    }
    
    func style(inFuture: Bool, inNextMonth: Bool) {
        accessibilityTraits.remove(.selected)
        accessibilityHint = "Tap to select"

        if !inFuture {
            numberLabel.textColor = .secondaryLabel
            monthBackgroundView.backgroundColor = Style.lightColor
        } else if inNextMonth {
            numberLabel.textColor = Style.lightColor
            monthBackgroundView.backgroundColor = Style.primaryColor
        } else{
            numberLabel.textColor = Style.lightColor
            monthBackgroundView.backgroundColor = Style.darkColor
        }
    }
}
