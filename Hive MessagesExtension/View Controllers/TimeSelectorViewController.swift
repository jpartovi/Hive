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
