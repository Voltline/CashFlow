//
//  MoneyUtils.swift
//  AccountBook
//
//  Created by Voltline on 2024/10/22.
//

import Foundation
import CoreData
import SwiftUI

func getTodayIncome(records: FetchedResults<Record>) -> Double {
    let calendar = Calendar.current
    let currentDate = Date()
    
    var total: Double = 0
    for record in records {
        if let recordDate = record.record_date, calendar.isDate(recordDate, inSameDayAs: currentDate) && record.record_type == "收入" {
            total += record.number
        }
    }
    return total
}

func getTodayOutcome(records: FetchedResults<Record>) -> Double {
    let calendar = Calendar.current
    let currentDate = Date()
    
    var total: Double = 0
    for record in records {
        if let recordDate = record.record_date, calendar.isDate(recordDate, inSameDayAs: currentDate) && record.record_type != "收入" {
            total += record.number
        }
    }
    return total
}

func getThisMonthIncome(records: FetchedResults<Record>) -> Double {
    let calendar = Calendar.current
    let currentDate = Date()
    
    let startDate: Date
    let endDate: Date
    
    let currentMonth = calendar.component(.month, from: currentDate)
    let currentYear = calendar.component(.year, from: currentDate)
    startDate = calendar.date(from: DateComponents(year: currentYear, month: currentMonth, day: 1))!
    endDate = calendar.date(byAdding: .month, value: 1, to: startDate)!

    var total: Double = 0
    for record in records {
        if let recordDate = record.record_date, recordDate >= startDate && recordDate < endDate, record.record_type == "收入" {
            total += record.number
        }
    }
    return total
}

func getThisMonthOutcome(records: FetchedResults<Record>) -> Double {
    let calendar = Calendar.current
    let currentDate = Date()
    
    let startDate: Date
    let endDate: Date
    
    let currentMonth = calendar.component(.month, from: currentDate)
    let currentYear = calendar.component(.year, from: currentDate)
    startDate = calendar.date(from: DateComponents(year: currentYear, month: currentMonth, day: 1))!
    endDate = calendar.date(byAdding: .month, value: 1, to: startDate)!

    var total: Double = 0
    for record in records {
        if let recordDate = record.record_date, recordDate >= startDate && recordDate < endDate, record.record_type != "收入" {
            total += record.number
        }
    }
    return total
}

func getMergedExpenses(records: FetchedResults<Record>) -> [Expense] {
    var result = [String: Expense]()
    var total: Double = 0
    for expense in records {
        let category = expense.record_type ?? "其他"
        if category == "收入" {
            continue
        }
        let amount = expense.number
        let color = colors[category]!
        total += amount
        if let existing = result[category] {
            result[category] = Expense(id: existing.id, category: category, amount: existing.amount + amount, color: color)
        }
        else {
            result[category] = Expense(category: category, amount: amount, color: color)
        }
    }
    var ret = Array(result.values).sorted(by: {
        $0.amount > $1.amount
    })
    if ret.isEmpty {
        return [Expense(category: "无", amount: 1, color: Color.gray, ratio: 1)]
    }
    else {
        for i in 0..<ret.count {
            ret[i].ratio = ret[i].amount / total
        }
    }
    return ret
}

func getTotalOutcome(_ withDecimal: Bool, records: FetchedResults<Record>) -> Double {
    var total: Double = 0
    for expense in records {
        let category = expense.record_type ?? "其他"
        if category == "收入" {
            continue
        }
        let amount = expense.number
        total += amount
    }
    if withDecimal {
        return total
    }
    else {
        return Double(Int(total))
    }
}
