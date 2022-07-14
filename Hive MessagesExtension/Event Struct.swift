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
    var times = [Time]()
    var daysAndTimes: [Day : [Time]] = [:]
    var duration: Duration? = nil
    
    mutating func buildURLComponents() -> URLComponents {
        
        var queryItems = [URLQueryItem]()
    
        queryItems.append(URLQueryItem(name: "title", value: title))
        
        if !locations.isEmpty {
            queryItems.append(contentsOf: locations[0].makeURLQueryItem())
        }
        
        queryItems.append(days[0].makeURLQueryItem())
        
        if !times.isEmpty {
            queryItems.append(times[0].makeURLQueryItem())
        }
        
        if duration != nil {
            queryItems.append(duration!.makeURLQueryItem())
        }
        
        print(queryItems)
        
        var URLComponents = URLComponents()
        URLComponents.queryItems = queryItems
        
        return URLComponents
    }
}

enum EventType: CaseIterable {
    case brunch
    case lunch
    case dinner
    case party
    case allDay
    case custom
    
    func getDurations() -> [Duration] {
        var min = 60
        var max = 240
        switch self {
        case .brunch:
            break
        case .lunch:
            break
        case .dinner:
            break
        case .party:
            max = 300
        case .allDay:
            return []
        case .custom:
            max = 360
        }
        
        return Duration.createDurations(min: min, max: max)
    }
    
    func getStartTimes() -> [Time] {
        let firstTime: Time
        let lastTime: Time
        switch self {
        case .brunch:
            firstTime = Time(hour: 8, minute: 0, period: .am)
            lastTime = Time(hour: 11, minute: 30, period: .am)
        case .lunch:
            firstTime = Time(hour: 11, minute: 0, period: .am)
            lastTime = Time(hour: 1, minute: 30, period: .pm)
        case .dinner:
            firstTime = Time(hour: 4, minute: 0, period: .pm)
            lastTime = Time(hour: 7, minute: 30, period: .pm)
        case .party:
            firstTime = Time(hour: 6, minute: 0, period: .pm)
            lastTime = Time(hour: 9, minute: 30, period: .pm)
        case .allDay:
            return []
        case .custom:
            firstTime = Time(hour: 6, minute: 0, period: .am)
            lastTime = Time(hour: 11, minute: 30, period: .pm)
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
    
    func label() -> String {
        switch self {
        case .brunch:
            return "Brunch"
        case .lunch:
            return "Lunch"
        case .dinner:
            return "Dinner"
        case .party:
            return "Party"
        case .allDay:
            return "All-Day"
        case .custom:
            return "Custom"
        }
    }
    
    func defaultTitle() -> String {
        switch self {
        case .brunch:
            return "Brunch"
        case .lunch:
            return "Lunch"
        case .dinner:
            return "Dinner"
        case .party:
            return "Party"
        case .allDay:
            return "All-Day"
        case .custom:
            return ""
        }
    }
}

struct Location {
    var title: String
    var place: GMSPlace?
    
    func makeURLQueryItem() -> [URLQueryItem] {
        var queryItems = [URLQueryItem]()
        queryItems.append(URLQueryItem(name: "locationTitle", value: title))
        if place != nil {
            queryItems.append(URLQueryItem(name: "locationID", value: place!.placeID))
        }
        return queryItems
    }
}

struct Day: Hashable {
    
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
    
    mutating func makeURLQueryItem() -> URLQueryItem {
        
        return URLQueryItem(name: "day", value: self.formatDate())
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
        
    func format(duration: Duration?) -> String{
        
        let formattedTime: String
        if duration == nil {
            formattedTime = String(hour) + ":" + String(format: "%02d", minute) + period.format()
        } else {
            let endTime = Time(referenceTime: self, minutesLater: duration!.minutes)
            
            formattedTime = String(self.hour) + ":" + String(format: "%02d", self.minute) + self.period.format() + "-" + String(endTime.hour) + ":" + String(format: "%02d", endTime.minute) + endTime.period.format()
        }
        
        return formattedTime
    }
    
    func makeURLQueryItem() -> URLQueryItem {
        return URLQueryItem(name: "time", value: self.format(duration: nil))
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
    let time: Time
    
    mutating func format(duration: Duration?) -> String {
        let formattedDayTimePair = day.formatDayOfWeek() + " " + day.formatDate() + " @ " + time.format(duration: duration)
        return formattedDayTimePair
    }
}

struct Duration {
    let minutes: Int
    
    func format() -> String {
        
        let formattedDuration: String
        let hours = Float(minutes) / 60.0
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
    
    func makeURLQueryItem() -> URLQueryItem {
        return URLQueryItem(name: "duration", value: String(self.minutes))
    }
}
