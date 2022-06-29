//
//  DateTimePairStruct.swift
//  Hive MessagesExtension
//
//  Created by Jude Partovi on 6/25/22.
//

import Foundation

struct DayTimePair {
    
    var timeFrame: TimeFrame
    var day: Day
    
    var isSelected: Bool
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
