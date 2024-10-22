//
//  WeekUtils.swift
//  AccountBook
//
//  Created by Voltline on 2024/7/6.
//

import Foundation

struct weekYear: Hashable, Comparable {
    var week: Int
    var year: Int
    init(_ week: Int, _ year: Int) {
        self.week = week
        self.year = year
    }
    
    static func == (lhs: weekYear, rhs: weekYear) -> Bool {
        return lhs.week == rhs.week && lhs.year == rhs.year
    }
    
    static func < (lhs: weekYear, rhs: weekYear) -> Bool {
        if lhs.year != rhs.year {
            return lhs.year < rhs.year
        }
        else {
            return lhs.week < rhs.week
        }
    }
    
    static func > (lhs: weekYear, rhs: weekYear) -> Bool {
        if lhs.year != rhs.year {
            return lhs.year > rhs.year
        }
        else {
            return lhs.week > rhs.week
        }
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(year)
        hasher.combine(week)
    }
}

func datesForWeekOfYear(_ weekOfYear: weekYear) -> String? {
    var calendar = Calendar.current
    calendar.firstWeekday = 2 // Monday
    calendar.minimumDaysInFirstWeek = 4 // ISO 8601 standard
    
    var components = DateComponents()
    components.weekOfYear = weekOfYear.week
    components.yearForWeekOfYear = weekOfYear.year
    components.weekday = calendar.firstWeekday // Monday
    
    guard let startDate = calendar.date(from: components) else {
        return nil
    }
    
    guard let endDate = calendar.date(byAdding: .day, value: 6, to: startDate) else {
        return nil
    }
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "MM.dd"
    return "\(dateFormatter.string(from: startDate))-\(dateFormatter.string(from: endDate))"
}

func weekOfYear(for date: Date) -> weekYear {
    var calendar = Calendar.current
    calendar.firstWeekday = 2 // Monday
    calendar.minimumDaysInFirstWeek = 4 // ISO 8601 standard
    
    let components = calendar.dateComponents([.weekOfYear, .yearForWeekOfYear], from: date)
    return weekYear(components.weekOfYear ?? 0, components.yearForWeekOfYear ?? 0)
}

func dayOfWeek(from date: String) -> String {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd"
    let fdate = dateFormatter.date(from: date)
    dateFormatter.dateFormat = "EEEE" // EEEE stands for the full name of the day

    let dayInWeek = dateFormatter.string(from: fdate!)
    return dayInWeek
}

let itemFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .short
    formatter.timeStyle = .medium
    return formatter
}()
