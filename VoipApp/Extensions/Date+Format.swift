//
//  Date+Format.swift
//  VoipApp
//
//  Created by Luis  Costa on 08/05/2019.
//  Copyright © 2019 Luis  Costa. All rights reserved.
//

import Foundation

extension NSDate {
    func formatWithTodayHourStyle() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm"
        return "Today, " + dateFormatter.string(from: self as Date)
    }
    
    func formatWithAppStyle() -> String {
        let calendar = Calendar.current
        
        if calendar.isDateInToday(self as Date) {
            return formatWithTodayHourStyle()
        }
        
        return calendar.isDateInToday(self as Date) ?
        formatWithTodayHourStyle() : formatAsWeekDayStyle() ?? ""
    }
    
    func formatAsWeekDayStyle() -> String? {
        let weekdays = [
            "Sunday",
            "Monday",
            "Tuesday",
            "Wednesday",
            "Thursday",
            "Friday",
            "Saturday"
        ]
        
        let component = Calendar.current.component(.weekday, from: self as Date)
        return weekdays[component - 1]
    }
}

