//
//  Time.swift
//  Hive MessagesExtension
//
//  Created by Jude Partovi on 7/20/22.
//

import Foundation

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
    
    init(queryString: String) {
        self.hour = Int(queryString.substring(to: 2))!
        self.minute = Int(queryString.substring(with: 3..<5))!
        self.period = Period(string: queryString.substring(with: 6..<8))
    }
    
    func sameAs(time: Time) -> Bool{
        if self.hour == time.hour && self.minute == time.minute && self.period == time.period {
            return true
        } else {
            return false
        }
    }
        
    func format(duration: Duration?) -> String{
        
        var formattedTime: String
        if duration == nil {
            formattedTime = String(hour)
            if minute != 0 {
                formattedTime += ":" + String(format: "%02d", minute)
            }
            formattedTime += period.format()
            
        } else {
            let endTime = Time(referenceTime: self, minutesLater: duration!.minutes)
            
            formattedTime = self.format(duration: nil) + "-" + endTime.format(duration: nil)
        }
        
        return formattedTime
    }
    
    func makeURLQueryItem() -> URLQueryItem {
        
        let timeString = String(format: "%02d", hour) + ":" + String(format: "%02d", minute) + "." + period.format()
        return URLQueryItem(name: "time", value: timeString)
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
    
    init(string: String) {
        switch string {
        case "am":
            self = .am
        case "pm":
            self = .pm
        default:
            fatalError("Unrecognized Period String")
        }
    }
}
