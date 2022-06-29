//
//  ConfirmTimesViewController.swift
//  Hive MessagesExtension
//
//  Created by Jude Partovi on 6/23/22.
//

// TODO: Scrollable view to see all dateTimePairs

import Foundation
import UIKit

class ConfirmTimesViewController: UIViewController {
    
    // let cellsPerRow = 3
    lazy var numberOfRows = selectedDays.count
    lazy var numberOfColumns = selectedTimes.count
    let cellHeight = 87
    let cellWidth = 96
    let rows = 4
    let inset: CGFloat = 10
    let minimumLineSpacing: CGFloat = 10
    let minimumInteritemSpacing: CGFloat = 10
    
    @IBOutlet weak var daysCollectionView: UICollectionView!
    @IBOutlet var timesCollectionView: UICollectionView!
    @IBOutlet weak var confirmButton: PrimaryButton!
    
    var selectedTimes: [TimeFrame] = []
    var selectedDays: [Day] = []
    
    lazy var dayTimePairs: [DayTimePair] = createDayTimePairs(times: selectedTimes, days: selectedDays)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadCollectionViews()
        sizeCollectionViews()
    }
    
    func loadCollectionViews() {
        
        daysCollectionView.contentInsetAdjustmentBehavior = .always
        daysCollectionView.register(DaysCollectionViewCell.self, forCellWithReuseIdentifier: DaysCollectionViewCell.reuseIdentifier)
        daysCollectionView.dataSource = self
        daysCollectionView.delegate = self
        daysCollectionView.reloadData()
        
        timesCollectionView.contentInsetAdjustmentBehavior = .always
        timesCollectionView.register(TimesCollectionViewCell.self, forCellWithReuseIdentifier: TimesCollectionViewCell.reuseIdentifier)
        timesCollectionView.dataSource = self
        timesCollectionView.delegate = self
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        timesCollectionView.collectionViewLayout = layout
        timesCollectionView.reloadData()
    }
    
    func sizeCollectionViews() {
        
        let daysCollectionViewWidth: CGFloat = CGFloat(cellWidth) + (2 * inset)
        let daysCollectionViewHeight: CGFloat = CGFloat((cellHeight * numberOfRows) + (Int(minimumLineSpacing) * (numberOfRows - 1))) + (2 * inset)
        
        let timesCollectionViewWidth: CGFloat = UIScreen.main.bounds.width - 32 - (CGFloat(cellWidth) + (2 * inset))
        let timesCollectionViewHeight: CGFloat = CGFloat((cellHeight * numberOfRows) + (Int(minimumLineSpacing) * (numberOfRows - 1))) + (2 * inset)
        
        NSLayoutConstraint.activate([
            daysCollectionView.heightAnchor.constraint(equalToConstant: daysCollectionViewHeight),
            daysCollectionView.widthAnchor.constraint(equalToConstant: daysCollectionViewWidth),
            timesCollectionView.heightAnchor.constraint(equalToConstant: timesCollectionViewHeight),
            timesCollectionView.widthAnchor.constraint(equalToConstant: timesCollectionViewWidth)
        ])
    }
    
    func createDayTimePairs(times: [TimeFrame], days: [Day]) -> [DayTimePair] {
        
        var dayTimePairs: [DayTimePair] = []
        
        for time in times {
            for day in days {
                dayTimePairs.append(DayTimePair(timeFrame: time, day: day, isSelected: true))
            }
        }
        
        return dayTimePairs
    }
    
    @IBAction func confirmButtonPressed(_ sender: Any) {
        
        var confirmedDayTimePairs: [DayTimePair] = []
        for pair in dayTimePairs {
            if pair.isSelected {
                confirmedDayTimePairs.append(pair)
            }
        }
        
        if let createEventVC = navigationController?.viewControllers.first as? CreateEventViewController {
            createEventVC.dateTimePairs = confirmedDayTimePairs
        }
        
        _ = navigationController?.popToRootViewController(animated: true)
    }
}

// MARK: - UICollectionViewDataSource
extension ConfirmTimesViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        var numberOfItems: Int = 0
        
        if collectionView == daysCollectionView {
            numberOfItems = selectedDays.count
        } else if collectionView == timesCollectionView {
            numberOfItems = dayTimePairs.count
        }
        
        return numberOfItems
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if collectionView == daysCollectionView {
            let day = selectedDays[indexPath.row]
            
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: DaysCollectionViewCell.reuseIdentifier, for: indexPath) as! DaysCollectionViewCell
            
            cell.day = day
            
            return cell
            
        } else { //if collectionView == timesCollectionView {
            
            let dayTimePair = dayTimePairs[indexPath.row]

            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TimesCollectionViewCell.reuseIdentifier, for: indexPath) as! TimesCollectionViewCell

            cell.dayTimePair = dayTimePair
            
            return cell
        
        }
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension ConfirmTimesViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == timesCollectionView {
            dayTimePairs[indexPath.row].isSelected = !dayTimePairs[indexPath.row].isSelected
            timesCollectionView!.reloadData()
        }
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
            return UIEdgeInsets(top: inset, left: inset, bottom: inset, right: inset)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return minimumLineSpacing
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return minimumInteritemSpacing
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout:UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        // let marginsAndInsets = inset * 2 + collectionView.safeAreaInsets.left + collectionView.safeAreaInsets.right + minimumInteritemSpacing * CGFloat(cellsPerRow - 1)
        let width = cellWidth
        let height = cellHeight
        
        return CGSize(width: width, height: height)
    }
}
