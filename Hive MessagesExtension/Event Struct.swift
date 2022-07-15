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
    var type: EventType
    var locations = [Location]()
    var days = [Day]()
    var times = [Time]()
    var daysAndTimes: [Day : [Time]] = [:]
    var duration: Duration? = nil
    
    mutating func buildURL() -> URL {
        
        var queryItems = [URLQueryItem]()
    
        queryItems.append(URLQueryItem(name: "title", value: title))
        
        queryItems.append(type.makeURLQueryItem())
        
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
        
        return URLComponents.url!
    }
    
    init(title: String, type: EventType, locations: [Location] = [], days: [Day] = [], times: [Time] = [], daysAndTimes: [Day : [Time]] = [:], duration: Duration? = nil) {
        self.title = title
        self.type = type
        self.locations = locations
        self.days = days
        self.times = times
        self.daysAndTimes = daysAndTimes
        self.duration = duration
    }
    
    init(url: URL) {
        let components = URLComponents(url: url,
                resolvingAgainstBaseURL: false)
        
        var title: String? = nil
        var type: EventType? = nil
        var location = Location(title: "", place: nil)
        var day: Day? = nil
        var time: Time? = nil
        let duration: Duration? = nil
        
        
        
        for (_, queryItem) in (components!.queryItems!.enumerated()){
            let name = queryItem.name
            let value = queryItem.value
            
            switch name {
            case "title":
                title = value!
            case "type":
                type = EventType(queryString: value!)
            case "locationTitle":
                location.title = value!
            case "locationId":
                location.place = Location.getPlaceFromID(id: value!)
            case "day":
                day = Day(queryString: value!)
            case "time":
                time = Time(queryString: value!)
            case "duration":
                if Int(value!) != 0 {
                    self.duration = Duration(minutes: Int(value!)!)
                }
            default:
                print("Uncaught query name " + name)
            }
        }
        self.title = title!
        self.type = type!
        self.locations = [location]
        self.days = [day!]
        if time == nil {
            self.times = [Time]()
        } else {
            self.times = [time!]
        }
        self.daysAndTimes = [:]
        self.duration = duration
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
        case "custom":
            self = .custom
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
            type = "all-Day"
        case .custom:
            type = "custom"
        }
        return URLQueryItem(name: "type", value: type)
    }
}

struct Location {
    var title: String
    var place: GMSPlace?
    
    func makeURLQueryItem() -> [URLQueryItem] {
        var queryItems = [URLQueryItem]()
        queryItems.append(URLQueryItem(name: "locationTitle", value: title))
        if place != nil {
            queryItems.append(URLQueryItem(name: "locationId", value: place!.placeID))
        }
        return queryItems
    }
    
    init(title: String, place: GMSPlace?) {
        self.title = title
        self.place = place
    }
    
    static func getPlaceFromID (id: String) -> GMSPlace {
        
        let fields = GMSPlaceField()
        let placesClient = GMSPlacesClient()
        var placeFromId: GMSPlace?
        placesClient.fetchPlace(fromPlaceID: id, placeFields: fields, sessionToken: nil, callback: {
            (place: GMSPlace?, error: Error?) in
            if let error = error {
                
                print("An error occurred: \(error.localizedDescription)")
                return
            }
            if let place = place {
                placeFromId = place
            } else {
                fatalError("Place couldn't be loaded")
            }
        })
        
        return placeFromId!
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
    
    lazy var stringFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
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
        /*
        let calendar = Calendar(identifier: .gregorian)
        let dateComponents = calendar.dateComponents(
            [.calendar, .timeZone,
             .era, .quarter,
             .year, .month, .day,
             .hour, .minute, .second, .nanosecond,
             .weekday, .weekdayOrdinal,
             .weekOfMonth, .weekOfYear, .yearForWeekOfYear],
            from: date)
        let year = yearFormatter.string(from: date)
        let month = monthFormatter
        let date = dateComponents.date?.timeIntervalSinceReferenceDate
        let
        let timeZone: String = dateComponents.timeZone!.identifier
        */
        let dateString = stringFormatter.string(from: date)
        print(dateString)
        
        return URLQueryItem(name: "day", value: dateString)
    }
    
    init(date: Date) {
        self.date = date
    }
    
    init(queryString: String) {
        
        let year = Int(queryString.substring(to: 4))!
        let month = Int(queryString.substring(with: 5..<7))
        let date = Int(queryString.substring(with: 8..<10))
        
        // Specify date components
        var dateComponents = DateComponents()
        dateComponents.year = year
        dateComponents.month = month
        dateComponents.day = date
        //dateComponents.timeZone = //TimeZone(abbreviation: "JST") // Japan Standard Time
        dateComponents.hour = 12
        dateComponents.minute = 0

        // Create date from components
        let calendar = Calendar(identifier: .gregorian)
        self.date = calendar.date(from: dateComponents)!
        print(date)
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
