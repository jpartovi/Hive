//
//  DateSelectorViewController.swift
//  Hive MessagesExtension
//
//  Created by Jude Partovi on 6/21/22.
//

import Foundation
import UIKit

class DateSelectorViewController: UIViewController {
    
    @IBOutlet weak var doneButton: PrimaryButton!
    
    var selectedDates: [Date] = []
    var selectedTimes: [TimeFrame] = []
    
    let cellsPerRow = 7
    let rows = 3
    let inset: CGFloat = 0//10
    let minimumLineSpacing: CGFloat = 0 //10
    let minimumInteritemSpacing: CGFloat = 0 //10
    
    var today: Date!
    
    let calendar = Calendar(identifier: .gregorian)
    
    private lazy var dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "d"
        return dateFormatter
    }()
    
    @IBOutlet var dateCollectionView: UICollectionView?
    
    private lazy var days: [Day] = generateDays(for: today)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        today = Date()
    
        dateCollectionView!.contentInsetAdjustmentBehavior = .always
        dateCollectionView!.register(DateCollectionViewCell.self, forCellWithReuseIdentifier: DateCollectionViewCell.reuseIdentifier)
        dateCollectionView!.dataSource = self
        dateCollectionView!.delegate = self
        
        dateCollectionView!.reloadData()
    }
    
    func monthMetadata(for today: Date) throws -> MonthMetadata {

        guard
            let numberOfDaysInMonth = calendar.range(
                of: .day,
                in: .month,
                for: today)?.count,
            let firstDayOfMonth = calendar.date(
                from: calendar.dateComponents([.year, .month], from: today))
            else {
                // 3
                fatalError("Month Metadata generation error")
            }

        let firstDayWeekday = calendar.component(.weekday, from: today)

        return MonthMetadata(
            numberOfDays: numberOfDaysInMonth,
            firstDay: firstDayOfMonth,
            firstDayWeekday: firstDayWeekday)
    }
    
    func generateDays(for today: Date) -> [Day] {
        
        guard let metadata = try? monthMetadata(for: today) else {
          preconditionFailure("An error occurred when generating the metadata for \(today)")
        }

        let numberOfDaysInMonth = metadata.numberOfDays
        let offsetInInitialRow = metadata.firstDayWeekday
        let firstDayOfMonth = metadata.firstDay

        var days: [Day] = []
        
        let firstDay = Int(dateFormatter.string(from: today))! - offsetInInitialRow + 1
        
        for day in (1...(cellsPerRow * rows)) {
            
            let inFuture = day >= offsetInInitialRow // 4
            
            let dayOffset = day - offsetInInitialRow
            
            let inNextMonth = day > numberOfDaysInMonth - Int(dateFormatter.string(from: today))! + offsetInInitialRow

            days.append(generateDay(
                offsetBy: dayOffset,
                for: today,
                inFuture: inFuture,
                inNextMonth: inNextMonth))
        }

        return days
    }

    func generateDay(offsetBy dayOffset: Int, for today: Date, inFuture: Bool, inNextMonth: Bool) -> Day {
          
        let date = calendar.date(byAdding: .day, value: dayOffset, to: today) ?? today
        
        let isSelected: Bool
        
        if selectedDates.contains(date) {
            isSelected = true
        } else {
            isSelected = false
        }
        
        return Day(
          date: date,
          number: dateFormatter.string(from: date),
          
          // TODO: Make the already selected days be already selected
          //isSelected: calendar.isDate(date, inSameDayAs: selectedDate),
          
          isSelected: isSelected,
          inFuture: inFuture,
          inNextMonth: inNextMonth
        )
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        selectedDates = []
        
        for day in days {
            if day.isSelected {
                
                selectedDates.append(day.date)
            }
        }

        if let destination = segue.destination as? ConfirmTimesViewController {
            destination.selectedTimes = selectedTimes
            destination.selectedDates = selectedDates
        }
    }
}

// MARK: - UICollectionViewDataSource
extension DateSelectorViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        days.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    
        let day = days[indexPath.row]

        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: DateCollectionViewCell.reuseIdentifier, for: indexPath) as! DateCollectionViewCell

        cell.day = day
        
        return cell
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension DateSelectorViewController: UICollectionViewDelegateFlowLayout {
    
    
    
    // TODO: When a cell is selected...
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        var day = days[indexPath.row]
        
        if day.inFuture {
            day.isSelected = !day.isSelected
            days[indexPath.row] = day
            dateCollectionView!.reloadData()
        }
        
        //selectedDateChanged(day.date)
        //dismiss(animated: true, completion: nil)
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
        
        let marginsAndInsets = inset * 2 + collectionView.safeAreaInsets.left + collectionView.safeAreaInsets.right + minimumInteritemSpacing * CGFloat(cellsPerRow - 1)
        let width = Int(collectionView.frame.width - marginsAndInsets) / cellsPerRow
        let height = width
        
        return CGSize(width: width, height: width)
    }
}
