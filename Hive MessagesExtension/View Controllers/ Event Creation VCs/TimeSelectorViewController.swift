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
    lazy var selectedTimeFrames = event.times
    var anyStartTimeSelected: Bool = false
    lazy var durations = event.type.getDurations()
    var selectedDuration: Duration? = nil
    
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
        
        let defaultDurationIndex = 2
        durationPicker.selectRow(defaultDurationIndex, inComponent: 0, animated: true)
        selectedDuration = durations[defaultDurationIndex]
        
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
            
            for (startTime, isSelected) in startTimesSelectionKey {
                if isSelected {
                    // TODO: Make TimeFrame object
                    selectedTimeFrames.append(TimeFrame(startTime: startTime, minutesLater: selectedDuration!.minutes))
                }
            }

            nextPage()
            
        } else {
            // TODO: Show some error message!
        }
        
    }
    
    func nextPage() {
        
        event.times = selectedTimeFrames
        
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
        let duration = durations[row]
        return duration.format()    }
}

extension TimeSelectorViewController: UIPickerViewDelegate {
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selectedDuration = durations[row]
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

