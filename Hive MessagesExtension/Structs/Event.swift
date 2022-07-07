//
//  Event.swift
//  Hive MessagesExtension
//
//  Created by Jude Partovi on 7/3/22.
//

import Foundation
import UIKit
import GooglePlaces

struct Event {
    var title: String
    let type: EventType
    var locations = [Location]()
    var days = [Day]()
    var times = [TimeFrame]()
    var dayTimePairs = [DayTimePair]()
}

enum EventType {
    case lunch
    
    func getDurations() -> [Duration] {
        var min = 60
        var max = 240
        switch self {
        case .lunch:
            break // default durations
        }
        
        return Duration.createDurations(min: min, max: max)
    }
    
    func getStartTimes() -> [Time] {
        let firstTime: Time
        let lastTime: Time
        switch self {
        case .lunch:
            firstTime = Time(hour: 11, minute: 0, period: .am)
            lastTime = Time(hour: 1, minute: 30, period: .pm)
        }
        
        var startTimes = [Time]()
        var time = firstTime
        while true {
            startTimes.append(time)
            if time.sameAs(time: lastTime) {
                break
            }
            time = Time(referenceTime: time, minutesLater: 30)
        }
        
        return startTimes
    }
    
    func defaultTitle() -> String {
        switch self {
        case .lunch:
            return "Lunch"
        }
    }
}

struct Location {
    let title: String
    let place: GMSPlace
}

struct Day {
    
    var date: Date
    
    lazy var dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "d"
        return dateFormatter
    }()
    
    lazy var monthFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "M"
        return dateFormatter
    }()
    
    lazy var dayOfWeekFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE"
        return dateFormatter
    }()
    
    mutating func formatDate() -> String {
        let formattedDate = monthFormatter.string(from: date) + "/" + dateFormatter.string(from: date)
        return formattedDate
    }
    
    mutating func formatDayOfWeek() -> String {
        let formattedDayOfWeek = String(dayOfWeekFormatter.string(from: date).prefix(3))
        
        return formattedDayOfWeek
    }
}

struct TimeFrame {
    
    var startTime: Time
    var endTime: Time
    
    init(startTime: Time, endTime: Time) {
        self.startTime = startTime
        self.endTime = endTime
    }
    
    init(startTime: Time, minutesLater: Int) {
        
        self.startTime = startTime
        self.endTime = Time(referenceTime: startTime, minutesLater: minutesLater)
    }
        
    func format() -> String {
            
        let formattedTimeFrame = startTime.format() + "-" + endTime.format()
            
        return formattedTimeFrame
    }
}

struct Time {
        
    var hour: Int
    let minute: Int
    let period: Period
    
    init(referenceTime: Time, minutesLater: Int) {
        // TODO: This function creates a TimeFrame object from a start time and a duration
        
        let hoursLater = Int((Float(minutesLater) / 60.0).rounded(.down))
        
        self.hour = referenceTime.hour + hoursLater
        if referenceTime.minute + (minutesLater % 60) == 60 {
            self.hour += 1
            self.minute = 0
        } else {
            self.minute = referenceTime.minute + (minutesLater % 60)
        }
        
        if self.hour >= 12 && referenceTime.hour != 12 {
            self.period = referenceTime.period.flip()
        } else {
            self.period = referenceTime.period
        }
        
        if self.hour > 12 {
            self.hour -= 12
        }
    }
    
    init(hour: Int, minute: Int, period: Period) {
        self.hour = hour
        self.minute = minute
        self.period = period
    }
    
    func sameAs(time: Time) -> Bool{
        if self.hour == time.hour && self.minute == time.minute && self.period == time.period {
            return true
        } else {
            return false
        }
    }
        
    func format() -> String{
        let formattedTime = String(hour) + ":" + String(format: "%02d", minute) + period.format()
            
        return formattedTime
    }
}

enum Period {
    case am
    case pm
    
    func format() -> String {
        switch self {
        case .am:
            return "am"
        case .pm:
            return "pm"

        }
    }
    
    func flip() -> Period {
        switch self {
        case .am:
            return .pm
        case .pm:
            return .am
        }
    }
}

struct DayTimePair {
    
    var day: Day
    let timeFrame: TimeFrame
    
    mutating func format() -> String {
        let formattedDateTimePair = day.formatDayOfWeek() + " " + day.formatDate() + " @ " + timeFrame.format()
        return formattedDateTimePair
    }
}

struct Duration {
    let minutes: Int
    
    func format() -> String {
        
        let formattedDuration: String
        let hours = Float(minutes) / 60.0
        print(hours)
        if hours < 1 {
            formattedDuration = String(minutes) + " Minutes"
        } else if hours == 1 {
            formattedDuration = "1 Hour"
        } else {
            formattedDuration = String(hours.clean) + " Hours"
        }
        
        return formattedDuration
    }
    
    static func createDurations(min: Int, max: Int, length: Int = 30) -> [Duration] {
        
        var durations = [Duration]()
        for minutes in stride(from: min, through: max, by: length) {
            durations.append(Duration(minutes: minutes))
        }
        
        return durations
    }
}

extension Float {
    var clean: String {
       return self.truncatingRemainder(dividingBy: 1) == 0 ? String(format: "%.0f", self) : String(self)
    }
}

