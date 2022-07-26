//
//  Day.swift
//  Hive MessagesExtension
//
//  Created by Jude Partovi on 7/20/22.
//

import Foundation

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
    
    lazy var queryStringFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        return dateFormatter
    }()
    
    lazy var dayOfWeekFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE"
        return dateFormatter
    }()
    
    lazy var stringFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEE, M/d"
        return dateFormatter
    }()
    
    mutating func formatDate(time: Time? = nil, duration: Duration? = nil) -> String {
        var formattedDate = stringFormatter.string(from: date)
        if time != nil {
            formattedDate += " @ " + (time?.format(duration: duration))!
        }
        return formattedDate
    }
    
    mutating func formatDayOfWeek() -> String {
        let formattedDayOfWeek = String(dayOfWeekFormatter.string(from: date).prefix(3))
        
        return formattedDayOfWeek
    }
    
    mutating func makeURLQueryItem() -> URLQueryItem {

        let dateString = queryStringFormatter.string(from: date)
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
