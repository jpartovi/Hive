//
//  EventType.swift
//  Hive MessagesExtension
//
//  Created by Jude Partovi on 7/20/22.
//

import Foundation

enum EventType: CaseIterable {
    case brunch
    case lunch
    case dinner
    case party
    case allDay
    case other
    
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
        case .other:
            max = 360
        }
        
        return Duration.createDurations(min: min, max: max)
    }
    
    func getDefaultDuration() -> Duration {
        var duration = Duration(minutes: 90)
        switch self {
        case .brunch:
            break
        case .lunch:
            break
        case .dinner:
            break
        case .party:
            duration = Duration.init(minutes: 180)
        case .allDay:
            fatalError("EventType 'All-Day' has no default duration.")
        case .other:
            Duration(minutes: 60)
        }
        return duration
    }
    
    init(queryString: String) {
        switch queryString {
        case "brunch":
            self = .brunch
        case "lunch":
            self = .lunch
        case "dinner":
            self = .dinner
        case "party":
            self = .party
        case "all-day":
            self = .allDay
        case "other":
            self = .other
        default:
            fatalError("Unrecognized EventType key")
        }
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
            lastTime = Time(hour: 10, minute: 30, period: .pm)
        case .allDay:
            return []
        case .other:
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
        case .other:
            return "Other"
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
        case .other:
            return ""
        }
    }
    
    func makeURLQueryItem() -> URLQueryItem {
        let type: String
        switch self {
        case .brunch:
            type = "brunch"
        case .lunch:
            type = "lunch"
        case .dinner:
            type = "dinner"
        case .party:
            type = "party"
        case .allDay:
            type = "all-day"
        case .other:
            type = "other"
        }
        return URLQueryItem(name: "eventType", value: type)
    }
}
