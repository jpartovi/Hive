//
//  Event.swift
//  Hive MessagesExtension
//
//  Created by Jude Partovi on 7/3/22.
//
import Foundation
import Messages

struct Event {
    var title: String
    var type: EventType
    var locations = [Location]()
    var days = [Day]()
    var times = [Time]()
    var daysAndTimes: [Day : [Time]] = [:]
    var duration: Duration? = nil
    
    mutating func buildRSVPURL(ID: String) -> URL {
        //For RSVP Invite
        
        var queryItems = [URLQueryItem]()
        
        queryItems.append(URLQueryItem(name: "messageType", value: "invite"))
        
        queryItems.append(URLQueryItem(name: "hostID", value: ID))
        
        queryItems.append(URLQueryItem(name: "displayType", value: "initial"))
    
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
        
        var URLComponents = URLComponents()
        URLComponents.queryItems = queryItems
        
        print(queryItems[1])
        
        return URLComponents.url!
    }
    
    mutating func buildVoteURL() -> URL {
        //For Voting
        
        var queryItems = [URLQueryItem]()
        
        queryItems.append(URLQueryItem(name: "messageType", value: "vote"))
        
        queryItems.append(URLQueryItem(name: "hostID", value: MessagesAppViewController.userID))
        
        queryItems.append(URLQueryItem(name: "displayType", value: "initial"))
    
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
                case "eventType":
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
            var locations = [Location]()//Location(title: "", place: nil, address: nil)
            var day: Day? = nil
            var time: Time? = nil
            var duration: Duration? = nil
            
            
            
            for (_, queryItem) in (components!.queryItems!.enumerated()){
                let name = queryItem.name
                let value = queryItem.value
                
                switch name {
                case "title":
                    title = value!
                case "eventType":
                    type = EventType(queryString: value!)
                case "locationTitle":
                    locations.append(Location(title: value!, place: nil, address: nil))
                case "locationAddress":
                    locations.append(Location(title: locations.removeLast().title, place: nil, address: value!))
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
            self.locations = locations
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
    
    mutating func createMessage(type: MessageType, url: URL) {
        
        // Load current conversation
        guard let conversation = MessagesAppViewController.conversation else { fatalError("Received nil conversation") }
        
        // Load current session or create new session
        let session = conversation.selectedMessage?.session ?? MSSession()
        
        let image: UIImage
        var imageTitle: String = ""
        var imageSubtitle: String = ""
        var caption: String = ""
        var subcaption: String = ""
        var trailingCaption: String = ""
        var trailingSubcaption: String = ""
        let summaryText: String = "Message sent with Bzzy"
        
        switch type {
        case .invite:
            image = UIImage(named: "BzzyMessageHeader")!
            caption = "Invite to " + self.title
            if self.times.isEmpty {
                subcaption = self.days[0].formatDate()
            } else {
                subcaption = self.days[0].formatDate(time: self.times[0], duration: self.duration)
            }
        case .poll:
            image = UIImage(named: "BzzyMessageHeader")!
            caption = "Poll for " + self.title
            if self.days.count == 1 {
                if self.times.isEmpty {
                    subcaption = self.days[0].formatDate()
                } else if self.times.count == 1{
                    subcaption = self.days[0].formatDate(time: self.times[0], duration: self.duration)
                }
            }
        case .voted:
            image = UIImage(named: "VotedMessageHeader")!
            caption = "Poll for " + self.title
            if self.days.count == 1 {
                if self.times.isEmpty {
                    subcaption = self.days[0].formatDate()
                } else if self.times.count == 1{
                    subcaption = self.days[0].formatDate(time: self.times[0], duration: self.duration)
                }
            }
        case .canCome:
            image = UIImage(named: "CanMessageHeader")!
            caption = "Invite to " + self.title
            if self.times.isEmpty {
                subcaption = self.days[0].formatDate()
            } else {
                subcaption = self.days[0].formatDate(time: self.times[0], duration: self.duration)
            }
        case .cantCome:
            image = UIImage(named: "CantMessageHeader")!
            caption = "Invite to " + self.title
            if self.times.isEmpty {
                subcaption = self.days[0].formatDate()
            } else {
                subcaption = self.days[0].formatDate(time: self.times[0], duration: self.duration)
            }
        }
        
        let alternateMessageLayout = MSMessageTemplateLayout()
        
        alternateMessageLayout.caption = caption
        alternateMessageLayout.image = image
        alternateMessageLayout.imageTitle = imageTitle
        alternateMessageLayout.imageSubtitle = imageSubtitle
        alternateMessageLayout.trailingCaption = trailingCaption
        alternateMessageLayout.subcaption = subcaption
        alternateMessageLayout.trailingSubcaption = trailingSubcaption

        let liveMessageLayout = MSMessageLiveLayout(alternateLayout: alternateMessageLayout)
        
        

        // Construct message
        let message = MSMessage(session: session)
        message.layout = liveMessageLayout
        message.summaryText = summaryText
        message.url = url
        
        // Add message to conversation
        conversation.insert(message) {error in
            // empty for now
        }
    }
}

enum MessageType {
    case invite
    case poll
    case voted
    case canCome
    case cantCome
}
