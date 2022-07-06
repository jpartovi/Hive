//
//  Time.swift
//  Hive MessagesExtension
//
//  Created by Jude Partovi on 6/23/22.
//

/*
import Foundation

struct TimeFrame {
    
    let timeOfDay: TimeOfDay
    var startTime: Time
    var endTime: Time
    
    func format(title: Bool, timeRange: Bool) -> String {
        
        //let formattedTimeFrame = timeOfDay.icon + " " + timeOfDay.title + ": " + String(startTime.hour) + ":" + String(format: "%02d", startTime.minute) + startTime.period + "-" + String(endTime.hour) + ":" + String(format: "%02d", endTime.minute) + endTime.period
        
        let formattedTimeFrame: String
        if title && timeRange {
            formattedTimeFrame = timeOfDay.title + ": " + String(startTime.hour) + ":" + String(format: "%02d", startTime.minute) + startTime.period + "-" + String(endTime.hour) + ":" + String(format: "%02d", endTime.minute) + endTime.period
        } else if title {
            formattedTimeFrame = timeOfDay.title
        } else if timeRange {
            formattedTimeFrame = String(startTime.hour) + ":" + String(format: "%02d", startTime.minute) + startTime.period + "-" + String(endTime.hour) + ":" + String(format: "%02d", endTime.minute) + endTime.period
        } else {
            formattedTimeFrame = ""
        }
        
        
        return formattedTimeFrame
    }
}

struct Time {
    
    let hour: Int
    let minute: Int
    let period: String // am or pm
    
    func format() -> String{
        let formattedTime = String(hour) + ":" + String(format: "%02d", minute) + period
        
        return formattedTime
    }
}

struct TimeOfDay {
    
    var title: String // ie. Morning, Afternoon, etc.
    var icon: String
}
*/
