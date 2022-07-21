//
//  Duration.swift
//  Hive MessagesExtension
//
//  Created by Jude Partovi on 7/20/22.
//

import Foundation

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
