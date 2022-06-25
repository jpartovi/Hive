//
//  Time.swift
//  Hive MessagesExtension
//
//  Created by Jude Partovi on 6/23/22.
//

import Foundation

struct TimeFrame {
    
    let timeOfDay: TimeOfDay
    var startTime: Time
    var endTime: Time
    
    func format() -> String {
        
        //let formattedTimeFrame = timeOfDay.icon + " " + timeOfDay.title + ": " + String(startTime.hour) + ":" + String(format: "%02d", startTime.minute) + startTime.period + "-" + String(endTime.hour) + ":" + String(format: "%02d", endTime.minute) + endTime.period
        
        let formattedTimeFrame = timeOfDay.title + ": " + String(startTime.hour) + ":" + String(format: "%02d", startTime.minute) + startTime.period + "-" + String(endTime.hour) + ":" + String(format: "%02d", endTime.minute) + endTime.period
        
        return formattedTimeFrame
    }
}

struct Time {
    
    let hour: Int
    let minute: Int
    let period: String
}

struct TimeOfDay {
    
    var title: String
    var icon: String
}

struct DateTimePair {
    
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
    
    var timeFrame: TimeFrame
    var date: Date
    
    mutating func formatDate() -> String {
        let formattedDate = monthFormatter.string(from: date) + "/" + dateFormatter.string(from: date)
        return formattedDate
    }
    
    var isSelected: Bool
}
