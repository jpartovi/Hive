//
//  DayTimePairCell.swift
//  Hive MessagesExtension
//
//  Created by Jude Partovi on 7/6/22.
//

import Foundation
import UIKit

class DayAndTimesCell: UITableViewCell {
    
    static let reuseIdentifier = String(describing: DayAndTimesCell.self)
    
    static let cornerRadius: CGFloat = 20
    
    var times = [(time: Time, isSelected: Bool)]()
    var duration: Duration? = nil
    
    let dayLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let timesCollectionView: UICollectionView = {
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.itemSize = CGSize(width: 105, height: 30)
        let collectionView = UICollectionView(frame: CGRect(x: 0, y: 0, width: 10, height: 10), collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.isPagingEnabled = true
        collectionView.register(TimeCell.self, forCellWithReuseIdentifier: TimeCell.reuseIdentifier)
        collectionView.backgroundColor = Style.lightGreyColor
        return collectionView
    }()
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        
        
        self.backgroundColor = Style.lightGreyColor
        
        contentView.addSubview(timesCollectionView)
        contentView.addSubview(dayLabel)
    
        timesCollectionView.dataSource = self
        timesCollectionView.delegate = self
        timesCollectionView.reloadData()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let inset: CGFloat = 10

        NSLayoutConstraint.activate([
            dayLabel.leftAnchor.constraint(equalTo: leftAnchor, constant: inset),
            dayLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            
            timesCollectionView.leftAnchor.constraint(equalTo: dayLabel.rightAnchor, constant: inset),
            timesCollectionView.rightAnchor.constraint(equalTo: rightAnchor, constant: -inset),
            timesCollectionView.topAnchor.constraint(equalTo: topAnchor, constant: inset),
            timesCollectionView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -inset)
        ])
        
        timesCollectionView.layer.cornerRadius = 5
    }
}

extension DayAndTimesCell: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        times.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = timesCollectionView.dequeueReusableCell(withReuseIdentifier: TimeCell.reuseIdentifier, for: indexPath) as! TimeCell
        cell.timeLabel.text = times[indexPath.row].time.format(duration: duration)
        cell.deleteIcon.tag = indexPath.row
        if times[indexPath.row].isSelected {
            cell.backgroundColor = Style.primaryColor
            cell.timeLabel.textColor = Style.lightTextColor
        } else {
            cell.backgroundColor = Style.greyColor
            cell.timeLabel.textColor = UIColor.white
        }
        return cell
    }
    
    
}

extension DayAndTimesCell: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        times[indexPath.row].isSelected = !times[indexPath.row].isSelected
        timesCollectionView.reloadData()
    }
}

class TimeCell: UICollectionViewCell {
    static let reuseIdentifier = String(describing: TimeCell.self)
    
    let timeLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let deleteIcon: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.backgroundColor = Style.lightGreyColor
        label.textColor = Style.greyColor
        label.textAlignment = .center
        label.text = "X"
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        // Apply rounded corners
        self.layer.cornerRadius = 5
        
        contentView.addSubview(timeLabel)
        contentView.addSubview(deleteIcon)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        
        self.contentView.layer.cornerRadius = 5
        
        let inset: CGFloat = 5

        NSLayoutConstraint.activate([
            timeLabel.leftAnchor.constraint(equalTo: leftAnchor, constant: inset),
            timeLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            
            deleteIcon.heightAnchor.constraint(equalToConstant: self.frame.height - (inset * 2)),
            deleteIcon.widthAnchor.constraint(equalTo: deleteIcon.heightAnchor),
            deleteIcon.rightAnchor.constraint(equalTo: rightAnchor, constant: -inset),
            deleteIcon.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
        
        deleteIcon.layer.masksToBounds = true
        deleteIcon.layer.cornerRadius = deleteIcon.frame.height / 2
    }
}
