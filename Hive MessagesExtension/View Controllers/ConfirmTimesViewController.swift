//
//  ConfirmTimesViewController.swift
//  Hive MessagesExtension
//
//  Created by Jude Partovi on 6/23/22.
//

import Foundation
import UIKit

class ConfirmTimesViewController: UIViewController {
    
    let cellsPerRow = 7
    let rows = 3
    let inset: CGFloat = 0
    let minimumLineSpacing: CGFloat = 0
    let minimumInteritemSpacing: CGFloat = 0
    
    @IBOutlet var dateTimePairsCollectionView: UICollectionView!
    @IBOutlet weak var confirmButton: PrimaryButton!
    
    var selectedTimes: [TimeFrame] = []
    var selectedDates: [Date] = []
    
    lazy var dateTimePairs: [DateTimePair] = createDateTimePairs(times: selectedTimes, dates: selectedDates)
    
    private lazy var dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "d"
        return dateFormatter
    }()
    
    private lazy var monthFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "M"
        return dateFormatter
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadCollectionView()
    }
    
    func loadCollectionView() {
        dateTimePairsCollectionView.contentInsetAdjustmentBehavior = .always
        dateTimePairsCollectionView.register(DateCollectionViewCell.self, forCellWithReuseIdentifier: DateCollectionViewCell.reuseIdentifier)
        dateTimePairsCollectionView.dataSource = self
        dateTimePairsCollectionView.delegate = self
        dateTimePairsCollectionView.reloadData()
    }
    
    func createDateTimePairs(times: [TimeFrame], dates: [Date]) -> [DateTimePair] {
        
        print("ah")
        var dateTimePairs: [DateTimePair] = []
        
        for date in dates {
            for time in times {
                dateTimePairs.append(DateTimePair(timeFrame: time, date: date, isSelected: true))
            }
        }
        
        return dateTimePairs
        
    }
    
    @IBAction func confirmButtonPressed(_ sender: Any) {
        
        var confirmedDateTimePairs: [DateTimePair] = []
        for pair in dateTimePairs {
            if pair.isSelected {
                confirmedDateTimePairs.append(pair)
            }
        }
        
        if let createEventVC = navigationController?.viewControllers.first as? CreateEventViewController {
            createEventVC.dateTimePairs = confirmedDateTimePairs
        }
        
        _ = navigationController?.popToRootViewController(animated: true)
    }
}

// MARK: - UICollectionViewDataSource
extension ConfirmTimesViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        dateTimePairs.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    
        let dateTimePair = dateTimePairs[indexPath.row]

        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: DateTimePairsCollectionViewCell.reuseIdentifier, for: indexPath) as! DateTimePairsCollectionViewCell

        cell.dateTimePair = dateTimePair
        
        return cell
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension ConfirmTimesViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        dateTimePairs[indexPath.row].isSelected = !dateTimePairs[indexPath.row].isSelected
        dateTimePairsCollectionView!.reloadData()
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
/*
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout:UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let marginsAndInsets = inset * 2 + collectionView.safeAreaInsets.left + collectionView.safeAreaInsets.right + minimumInteritemSpacing * CGFloat(cellsPerRow - 1)
        let width = Int(collectionView.frame.width - marginsAndInsets) / cellsPerRow
        let height = width
        
        return CGSize(width: width, height: width)
    }*/
}
