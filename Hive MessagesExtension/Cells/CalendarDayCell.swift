//
//  CalendarDayCell.swift
//  Hive MessagesExtension
//
//  Created by Jude Partovi on 6/21/22.
//

import UIKit

class CalendarDayCell: UICollectionViewCell {
    
    static let reuseIdentifier = String(describing: CalendarDayCell.self)
    
    private lazy var selectionBackgroundView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.clipsToBounds = true
        view.backgroundColor = Style.primaryColor
        return view
    }()
    
    private lazy var monthBackgroundView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.clipsToBounds = false//true
        view.layer.borderWidth = 2

        //view.alpha = 0.5
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

    var day: CalendarDay? {
        didSet {
            guard let day = day else { return }

            numberLabel.text = day.number
            
            updateSelectionStatus()
            style(inFuture: day.inFuture, inNextMonth: day.inNextMonth, isToday: day.isToday)
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        isAccessibilityElement = true
        accessibilityTraits = .button
        
        contentView.addSubview(monthBackgroundView)
        contentView.addSubview(selectionBackgroundView)
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

    func updateSelectionStatus() {
        guard let day = day else { return }
        

        if day.isSelected {
            showSelected()
        } else {
            showUnselected()
        }
    }

    func showSelected() {

        //numberLabel.textColor = Style.lightColor
        selectionBackgroundView.isHidden = false
    }
    
    func showUnselected() {
        
        selectionBackgroundView.isHidden = true
    }
    
    func style(inFuture: Bool, inNextMonth: Bool, isToday: Bool) {

        if !inFuture {
            numberLabel.textColor = .secondaryLabel
            monthBackgroundView.backgroundColor = Style.lightColor
            monthBackgroundView.layer.borderColor = Style.darkColor.withAlphaComponent(0).cgColor
        } else if inNextMonth {
            numberLabel.textColor = Style.darkColor
            monthBackgroundView.backgroundColor = Style.tertiaryColor
            monthBackgroundView.layer.borderColor = Style.darkColor.withAlphaComponent(0).cgColor
        } else {
            numberLabel.textColor = Style.darkColor
            monthBackgroundView.backgroundColor = Style.secondaryColor
            if isToday {
                monthBackgroundView.layer.borderColor = Style.darkColor.withAlphaComponent(1).cgColor
            } else {
                monthBackgroundView.layer.borderColor = Style.darkColor.withAlphaComponent(0).cgColor
            }
        }
    }
}
