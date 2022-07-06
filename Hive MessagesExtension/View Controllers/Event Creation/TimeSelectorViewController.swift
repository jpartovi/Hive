/*
//
//  TimeSelectorViewController.swift
//  Hive MessagesExtension
//
//  Created by Jude Partovi on 6/17/22.
//

// TODO: Custom Time

import UIKit
import Messages

class TimeSelectorViewController: UIViewController {
    
    // Connect storyboard elements
    @IBOutlet var morningButton: SelectionButton!
    @IBOutlet var middayButton: SelectionButton!
    @IBOutlet var afternoonButton: SelectionButton!
    @IBOutlet var eveningButton: SelectionButton!
    @IBOutlet var lateButton: SelectionButton!
    @IBOutlet var allDayButton: SelectionButton!
    @IBOutlet var customButton: SelectionButton!
    @IBOutlet var nextButton: PrimaryButton!
    
    var buttonTimes: [(SelectionButton, TimeFrame)] = []
    
    var selectedTimes: [TimeFrame] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadTimes()
        updateButtonNames()
        setUpElements()

    }
    
    func loadTimes() {
        buttonTimes = [
           (self.morningButton, TimeFrame(timeOfDay: TimeOfDay(title: "Morning", icon: "M"), startTime: Time(hour: 8, minute: 0, period: "am"), endTime: Time(hour: 10, minute: 0, period: "am"))),
           (self.middayButton, TimeFrame(timeOfDay: TimeOfDay(title: "Midday", icon: "D"), startTime: Time(hour: 11, minute: 0, period: "am"), endTime: Time(hour: 1, minute: 0, period: "pm"))),
           (self.afternoonButton, TimeFrame(timeOfDay: TimeOfDay(title: "Afternoon", icon: "F"), startTime: Time(hour: 1, minute: 0, period: "pm"), endTime: Time(hour: 4, minute: 0, period: "pm"))),
           (self.eveningButton, TimeFrame(timeOfDay: TimeOfDay(title: "Evening", icon: "E"), startTime: Time(hour: 6, minute: 0, period: "pm"), endTime: Time(hour: 9, minute: 0, period: "pm"))),
           (self.lateButton, TimeFrame(timeOfDay: TimeOfDay(title: "Late", icon: "L"), startTime: Time(hour: 9, minute: 0, period: "pm"), endTime: Time(hour: 11, minute: 0, period: "pm"))),
           (self.allDayButton, TimeFrame(timeOfDay: TimeOfDay(title: "All-Day", icon: "A"), startTime: Time(hour: 8, minute: 0, period: "am"), endTime: Time(hour: 8, minute: 0, period: "pm")))
        ]
    }
    
    func updateButtonNames() {
        
        for (button, timeFrame) in buttonTimes {

            button.setTitle(timeFrame.format(title: true, timeRange: true), for: .normal)
        }
    }
    
    func setUpElements() {
        
        morningButton.style(color: Style.primaryColor, filled: true, roundedCornerPosition: RoundedCornerPosition.topLeft.number)
        allDayButton.style(color: Style.primaryColor, filled: true, roundedCornerPosition: RoundedCornerPosition.topRight.number)
        customButton.style(color: Style.primaryColor, filled: true, roundedCornerPosition: RoundedCornerPosition.bothBotton.number)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        selectedTimes = []

        for (button, timeFrame) in buttonTimes {
            if button.active {
                selectedTimes.append(timeFrame)
            }
        }
        
        if let destination = segue.destination as? DateSelectorViewController {
            destination.selectedTimes = selectedTimes
        }
    }
}
*/
//
//  TimeSelectorViewController.swift
//  Hive MessagesExtension
//
//  Created by Jude Partovi on 6/17/22.
//

// TODO: Custom Time

import UIKit
import Messages

class TimeSelectorViewController: UIViewController {
    
    static let storyboardID = String(describing: TimeSelectorViewController.self)
    
    var event: Event! = nil
    lazy var startTimes: [Time] = event.type.getStartTimes()
    var startTimesSelectionKey: [(Time, Bool)] = []
    lazy var selectedTimeFrames: [TimeFrame]? = event.times
    var anyStartTimeSelected: Bool = false
    let durations = [
        ("1 Hour", 1, 0),
        ("1.5 Hours", 1, 30),
        ("2 Hours", 2, 0),
        ("2.5 Hours", 2, 30),
        ("3 Hours", 3, 0),
        ("3.5 Hours", 3, 30),
        ("4 Hours", 4, 0)
    ]
    var selectedDuration: (Int, Int) = (0, 0)
    var dayTimePairs: [DayTimePair] = []
    
    @IBOutlet weak var durationPicker: UIPickerView!
    
    @IBOutlet weak var startTimesCollectionView: UICollectionView!
    let cellsPerRow = 2
    let rows = 3
    let inset: CGFloat = 10
    let minimumLineSpacing: CGFloat = 10
    let minimumInteritemSpacing: CGFloat = 10
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        durationPicker.dataSource = self
        durationPicker.delegate = self
        durationPicker.selectRow(2, inComponent: 0, animated: true)
        
        loadStartTimeSelectionKey()
    
        startTimesCollectionView.contentInsetAdjustmentBehavior = .always
        startTimesCollectionView.register(StartTimeCell.self, forCellWithReuseIdentifier: StartTimeCell.reuseIdentifier)
        startTimesCollectionView.dataSource = self
        startTimesCollectionView.delegate = self
        startTimesCollectionView.reloadData()
        
        updateNextButtonStatus()
    }
    
    func loadStartTimeSelectionKey() {
        for time in startTimes {
            startTimesSelectionKey.append((time, false))
        }
    }
    
    @IBAction func nextButtonPressed(_ sender: Any) {
        
        if anyStartTimeSelected {
            selectedTimeFrames = []
            
            let (durationHour, durationMinute) = selectedDuration
            for (startTime, isSelected) in startTimesSelectionKey {
                if isSelected {
                    // TODO: Make TimeFrame object
                    selectedTimeFrames!.append(TimeFrame(startTime: startTime, durationHour: durationHour, durationMinute: durationMinute))
                }
            }
            
            dayTimePairs = []
            for day in event.days! {
                for timeFrame in selectedTimeFrames! {
                    dayTimePairs.append(DayTimePair(day: day, timeFrame: timeFrame))
                }
            }
            
            nextPage()
        } else {
            // TODO: Show some error message!
        }
        
    }
    
    func nextPage() {
        
        event.times = selectedTimeFrames
        event.dayTimePairs = dayTimePairs
        
        let confirmVC = (storyboard?.instantiateViewController(withIdentifier: ConfirmViewController.storyboardID) as? ConfirmViewController)!
        confirmVC.event = event
        self.navigationController?.pushViewController(confirmVC, animated: true)
    }
    
    func updateNextButtonStatus() {
        
        anyStartTimeSelected = false
        for (_ , isSelected) in startTimesSelectionKey {
            
            if isSelected {
                anyStartTimeSelected = true
                break
            }
        }
        
        if anyStartTimeSelected {
            // TODO: Color Next Button
        } else {
            // TODO: Gray out Next Button
        }
    }
}

extension TimeSelectorViewController: UIPickerViewDataSource {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        durations.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        let (durationTitle, _, _) = durations[row]
        return durationTitle
    }
}

extension TimeSelectorViewController: UIPickerViewDelegate {
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let (durationTitle, hour, minute) = durations[row]
        selectedDuration = (hour, minute)
    }
}

// MARK: - UICollectionViewDataSource
extension TimeSelectorViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        startTimesSelectionKey.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let (startTime, isSelected) = startTimesSelectionKey[indexPath.row]

        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: StartTimeCell.reuseIdentifier, for: indexPath) as! StartTimeCell

        cell.time = startTime
        cell.timeSelected = isSelected
        
        // TODO: What if there are already selected start times??? (load duration and start times from event object)
        
        return cell
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension TimeSelectorViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        var (startTime, isSelected) = startTimesSelectionKey[indexPath.row]
        isSelected = !isSelected
        startTimesSelectionKey[indexPath.row] = (startTime, isSelected)
        startTimesCollectionView!.reloadData()
        
        updateNextButtonStatus()
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
        let height = 50
        
        return CGSize(width: width, height: height)
    }
}

