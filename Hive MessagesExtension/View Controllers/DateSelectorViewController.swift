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
    
    var selectedDays: [Day] = []
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
    
    @IBOutlet var calendarCollectionView: UICollectionView?
    
    private lazy var calendarDays: [CalendarDay] = generateDays(for: today)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        today = Date()
    
        calendarCollectionView!.contentInsetAdjustmentBehavior = .always
        calendarCollectionView!.register(CalendarCollectionViewCell.self, forCellWithReuseIdentifier: CalendarCollectionViewCell.reuseIdentifier)
        calendarCollectionView!.dataSource = self
        calendarCollectionView!.delegate = self
        
        calendarCollectionView!.reloadData()
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
    
    func generateDays(for today: Date) -> [CalendarDay] {
        
        guard let metadata = try? monthMetadata(for: today) else {
          preconditionFailure("An error occurred when generating the metadata for \(today)")
        }

        let numberOfDaysInMonth = metadata.numberOfDays
        let offsetInInitialRow = metadata.firstDayWeekday
        let firstDayOfMonth = metadata.firstDay

        var days: [CalendarDay] = []
        
        let firstDay = Int(dateFormatter.string(from: today))! - offsetInInitialRow + 1
        
        for day in (1...(cellsPerRow * rows)) {
            
            let inFuture = day >= offsetInInitialRow
            
            let dayOffset = day - offsetInInitialRow
            
            let inNextMonth = day > numberOfDaysInMonth - Int(dateFormatter.string(from: today))! + offsetInInitialRow

            days.append(generateDay(
                offsetBy: dayOffset,
                for: today,
                inFuture: inFuture,
                inNextMonth: inNextMonth))
        }
        
        days[offsetInInitialRow - 1].isToday = true

        return days
    }

    func generateDay(offsetBy dayOffset: Int, for today: Date, inFuture: Bool, inNextMonth: Bool) -> CalendarDay {
          
        let date = calendar.date(byAdding: .day, value: dayOffset, to: today) ?? today
        
        var isSelected: Bool
        
        isSelected = false
        for day in selectedDays {
            if day.date == date {
                isSelected = true
                break
            }
        }
        
        return CalendarDay(
          date: date,
          number: dateFormatter.string(from: date),
          
          // TODO: Make the already selected days be already selected
          //isSelected: calendar.isDate(date, inSameDayAs: selectedDate),
          
          isSelected: isSelected,
          inFuture: inFuture,
          inNextMonth: inNextMonth,
          isToday: false
        )
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        selectedDays = []
        
        for calendarDay in calendarDays {
            if calendarDay.isSelected {
                
                selectedDays.append(Day(date: calendarDay.date))
            }
        }

        if let destination = segue.destination as? ConfirmTimesViewController {
            destination.selectedTimes = selectedTimes
            destination.selectedDays = selectedDays
        }
    }
}

// MARK: - UICollectionViewDataSource
extension DateSelectorViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        calendarDays.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    
        let day = calendarDays[indexPath.row]

        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CalendarCollectionViewCell.reuseIdentifier, for: indexPath) as! CalendarCollectionViewCell

        cell.day = day
        
        return cell
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension DateSelectorViewController: UICollectionViewDelegateFlowLayout {
    
    
    
    // TODO: When a cell is selected...
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        var day = calendarDays[indexPath.row]
        
        if day.inFuture {
            day.isSelected = !day.isSelected
            calendarDays[indexPath.row] = day
            calendarCollectionView!.reloadData()
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
