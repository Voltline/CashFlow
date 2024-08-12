//
//  NewBudgetView.swift
//  AccountBook
//
//  Created by Voltline on 2024/8/12.
//

import SwiftUI
import Charts
import CoreData
import SwiftUICharts

struct NewBudgetView: View {
    var width: Double
    var height: Double
    var month: Bool = true
    @State private var budget_text: String = ""
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Record.record_type, ascending: true)],
        animation: .default)
    private var records: FetchedResults<Record>
    
    var description: String {
        if month {
            return "月度预算"
        }
        else {
            return "年度预算"
        }
    }
    
    var total: [BudgetTotal] {
        let total: Double
        if month {
            total = fetchRecords(context: viewContext)
            let rest = Double(UserDefaults.standard.integer(forKey: "MonthBudget")) - total
            return [BudgetTotal(amount: rest > 0 ? total : 0, origin_amount: total, color: Color.green.opacity(0.3)),
                    BudgetTotal(amount: rest > 0 ? rest : Double(UserDefaults.standard.integer(forKey: "MonthBudget")), origin_amount: rest, color: rest > 0 ? Color.green.opacity(0.75) : Color.red.opacity(0.75), over: rest < 0)]
        } else {
            total = fetchRecords(context: viewContext)
            let rest = Double(UserDefaults.standard.integer(forKey: "YearBudget")) - total
            return [BudgetTotal(amount: rest > 0 ? total : 0, origin_amount: total, color: Color.green.opacity(0.3)),
                    BudgetTotal(amount: rest > 0 ? rest : Double(UserDefaults.standard.integer(forKey: "YearBudget")), origin_amount: rest, color: rest > 0 ? Color.green.opacity(0.75) : Color.red.opacity(0.75), over: rest < 0)]
        }
    }
    
    var budgetData: [Double] {
        return [total[0].amount, total[1].amount]
    }
    
    var body: some View {
        if month {
            PieChartView(data: budgetData, title: description, legend: "预算: " + String(format: "%.0f", UserDefaults.standard.double(forKey: "MonthBudget")) + "\n" +
                         "支出: " + String(format: "%.2f", total[0].origin_amount), style: ChartStyle(
                backgroundColor: Color(hexString: "#36534D"), //3B5147, 313D34
                accentColor: Color(hexString: "#FFD683"),
                secondGradientColor: Color(hexString: "#FFCA04"),
                textColor: Color.white,
                legendTextColor: Color(hexString: "#D2E5E1"),
                dropShadowColor: Color.gray.opacity(0.4)))
        } else {
            PieChartView(data: budgetData, title: description, legend: "预算: " + String(format: "%.0f", UserDefaults.standard.double(forKey: "YearBudget")) + "\n" +
                         "支出: " + String(format: "%.2f", total[0].origin_amount), style: ChartStyle(
                backgroundColor: Color(hexString: "#39334D"),
                accentColor: Color(hexString: "#FF8A21"),
                secondGradientColor: Colors.GradientPurple,
                textColor: Color.white,
                legendTextColor: Color(hexString: "#D2E5E1"),
                dropShadowColor: Color.gray.opacity(0.3))
            )
        }
    }
    
    func fetchRecords(context: NSManagedObjectContext) -> Double {
        let calendar = Calendar.current
        let currentDate = Date()
        
        let startDate: Date
        let endDate: Date
        
        if month {
            let currentMonth = calendar.component(.month, from: currentDate)
            let currentYear = calendar.component(.year, from: currentDate)
            startDate = calendar.date(from: DateComponents(year: currentYear, month: currentMonth, day: 1))!
            endDate = calendar.date(byAdding: .month, value: 1, to: startDate)!
        }
        else {
            let currentYear = calendar.component(.year, from: currentDate)
            startDate = calendar.date(from: DateComponents(year: currentYear, month: 1, day: 1))!
            endDate = calendar.date(from: DateComponents(year: currentYear + 1, month: 1, day: 1))!
        }
        
        var total: Double = 0
        for record in records {
            if let recordDate = record.record_date, recordDate >= startDate && recordDate < endDate, record.record_type != "收入" {
                total += record.number
            }
        }
        return total
    }
}

#Preview {
    GeometryReader { geometry in
        HStack(spacing: geometry.size.width * 0.03) {
            NewBudgetView(width: geometry.size.width, height: geometry.size.height, month: false)
            NewBudgetView(width: geometry.size.width, height: geometry.size.height)
        }
        .padding(.horizontal, geometry.size.width * 0.024)
    }
}
