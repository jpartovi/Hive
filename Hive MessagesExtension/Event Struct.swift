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
    
    mutating func buildRSVPURL() -> URL {
        //For RSVP Invite
        
        var queryItems = [URLQueryItem]()
        
        queryItems.append(URLQueryItem(name: "messageType", value: "invite"))
    
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
        
        queryItems.append(URLQueryItem(name: "endEvent", value: ""))
        
        print(queryItems)
        
        var URLComponents = URLComponents()
        URLComponents.queryItems = queryItems
        
        return URLComponents.url!
    }
    
    mutating func buildVoteURL() -> URL {
        //For Voting
        
        var queryItems = [URLQueryItem]()
        
        queryItems.append(URLQueryItem(name: "messageType", value: "vote"))
    
        queryItems.append(URLQueryItem(name: "title", value: title))
        
        queryItems.append(type.makeURLQueryItem())
        
        for location in locations {
            queryItems.append(contentsOf: location.makeURLQueryItem())
        }
        
        for (day, dtimes) in daysAndTimes {
            var mutableDay = day
            queryItems.append(mutableDay.makeURLQueryItem())
            for time in dtimes {
                queryItems.append(time.makeURLQueryItem())
            }
        }
        
        if duration != nil {
            queryItems.append(duration!.makeURLQueryItem())
        }
        
        queryItems.append(URLQueryItem(name: "endEvent", value: ""))
        
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
        
        if components!.queryItems![0].name == "messageType" && components!.queryItems![0].value == "vote" {
            
            var title: String? = nil
            var type: EventType? = nil
            var locations: [Location] = []
            //var days: [Day] = []
            //var times: [Time] = []
            var daysAndTimes: [Day : [Time]] = [:]
            var curDay: Day? = nil
            var duration: Duration? = nil
            
            for (_, queryItem) in (components!.queryItems!.enumerated()){
                let name = queryItem.name
                let value = queryItem.value
                
                switch name {
                case "title":
                    title = value!
                case "type":
                    type = EventType(queryString: value!)
                case "locationTitle":
                    locations.append(Location(title: value!, place: nil, address: nil))
                case "locationAddress":
                    locations.append(Location(title: locations.removeLast().title, place: nil, address: value!))
                case "day":
                    curDay = Day(queryString: value!)
                    daysAndTimes[curDay!] = [Time]()
                case "time":
                    var curTimes = daysAndTimes[curDay!]!
                    curTimes.append(Time(queryString: value!))
                    daysAndTimes[curDay!] = curTimes
                case "duration":
                    if Int(value!) != 0 {
                        duration = Duration(minutes: Int(value!)!)
                    }
                case "endEvent":
                    break
                default:
                    print("Uncaught query name " + name)

                }
            }
            self.title = title!
            self.type = type!
            self.locations = locations
            self.days = Array(daysAndTimes.keys)
            self.days.sort {
                $0.date < $1.date
            }
            self.times = []
            self.daysAndTimes = daysAndTimes
            self.duration = duration
            
        } else {
        
            var title: String? = nil
            var type: EventType? = nil
            var location = Location(title: "", place: nil, address: nil)
            var day: Day? = nil
            var time: Time? = nil
            var duration: Duration? = nil
            
            
            
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
                        duration = Duration(minutes: Int(value!)!)
                    }
                case "endEvent":
                    break
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
        case .custom:
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
    var address: String?
    
    func makeURLQueryItem() -> [URLQueryItem] {
        var queryItems = [URLQueryItem]()
        queryItems.append(URLQueryItem(name: "locationTitle", value: title))
        if address != nil {
            queryItems.append(URLQueryItem(name: "locationAddress", value: address))
        }
        return queryItems
    }
    
    init(title: String, place: GMSPlace?, address: String?) {
        self.title = title
        self.place = place
        self.address = address
    }
    
    // TODO: This does NOT work - WHYYYYYY??
    static func getPlaceFromID (id: String) -> GMSPlace {
        
        let fields = GMSPlaceField(rawValue: UInt(GMSPlaceField.name.rawValue) | UInt(GMSPlaceField.addressComponents.rawValue) | UInt(GMSPlaceField.placeID.rawValue))
        let placesClient = GMSPlacesClient.shared()
        var placeFromId: GMSPlace?
        
        print("Trying")
        /*
        placesClient.fetchPlace(fromPlaceID: id, placeFields: fields, sessionToken: nil, callback: {
            (place: GMSPlace?, error: Error?) in
            print("======================")
            if let error = error {
                
                print("An error occurred: \(error.localizedDescription)")
                return
            }
            print(place)
            if let place = place {
                print(place.name)
                placeFromId = place
            } else {
                fatalError("Place couldn't be loaded")
            }
        })
        */
        
        placesClient.lookUpPlaceID(id, callback: { (place, error) -> Void in
            print("=================")
            if let error = error {
                    print("lookup place id query error: \(error.localizedDescription)")
                    return
            }

            if let place = place {
                print("Place name \(place.name)")
                print("Place address \(place.formattedAddress)")
                print("Place placeID \(place.placeID)")
                print("Place attributions \(place.attributions)")
                placeFromId = place
            } else {
                print("No place details for \(id)")
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

        let dateString = stringFormatter.string(from: date)
        print(dateString)
        
        return URLQueryItem(name: "day", value: dateString)
    }
    
    init(date: Date) {
        let cal = Calendar(identifier: .gregorian)
        self.date = cal.date(bySettingHour: 12, minute: 0, second: 0, of: date)!
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
        dateComponents.hour = 12
        dateComponents.minute = 0

        // Create date from components
        //let calendar = Calendar(identifier: .gregorian)
        self.date = calendar.date(from: dateComponents)!
    }
    
    func sameAs(date: Date) -> Bool {
        //let calendar = Calendar(identifier: .gregorian)
        return calendar.isDate(self.date, equalTo: date, toGranularity: .day)
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
