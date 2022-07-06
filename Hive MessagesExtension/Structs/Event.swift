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
    let type: Type
    var locations: [Location]? = nil
    var days: [Day]? = nil
    var times: [TimeFrame]? = nil
    var dayTimePairs: [DayTimePair]? = nil
}

enum Type {
    case lunch
    
    func getStartTimes() -> [Time] {
        switch self {
        case .lunch:
            // TODO: Make a way to load start times with a for loop
            return [
                Time(hour: 11, minute: 0, period: .am),
                Time(hour: 11, minute: 30, period: .am),
                Time(hour: 12, minute: 0, period: .pm),
                Time(hour: 12, minute: 30, period: .pm),
                Time(hour: 1, minute: 0, period: .pm),
                Time(hour: 1, minute: 30, period: .pm)
            ]
        }
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
        
    func format() -> String {
            
        let formattedTimeFrame = startTime.format() + "-" + endTime.format()
            
        return formattedTimeFrame
    }

    init(startTime: Time, durationHour: Int, durationMinute: Int) {
        // TODO: This function creates a TimeFrame object from a start time and a duration
        self.startTime = startTime
        
        var endTimeHour = startTime.hour + durationHour
        let endTimeMinute: Int
        if startTime.minute + durationMinute == 60 {
            endTimeHour += 1
            endTimeMinute = 0
        } else {
            endTimeMinute = startTime.minute + durationMinute
        }
        
        let endTimePeriod: Period
        if endTimeHour >= 12 && startTime.hour != 12 {
            endTimePeriod = startTime.period.flip()
        } else {
            endTimePeriod = startTime.period
        }
        
        if endTimeHour > 12 {
            endTimeHour -= 12
        }
        
        self.endTime = Time(hour: endTimeHour, minute: endTimeMinute, period: endTimePeriod)
    }

}

struct Time {
        
    let hour: Int
    let minute: Int
    let period: Period
        
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
        let formattedDateTimePair = day.formatDate() + " @ " + timeFrame.format()
        return formattedDateTimePair
    }
}

// TODO: Duration struct???

