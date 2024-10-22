//
//  BudgetView.swift
//  AccountBook
//
//  Created by Voltline on 2024/7/23.
//

import SwiftUI
import Charts
import CoreData
import SwiftUICharts
import ActivityKit

struct BudgetView: View {
    var width: Double
    var height: Double
    var month: Bool = true
    @State private var budget_text: String = ""
    @State private var showAlert = false
    @AppStorage("MonthBudget") private var MonthlyBudget = 3000.0
    @AppStorage("YearBudget") private var YearlyBudget = 100000.0
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
        calculateTotal()
    }
    
    var budgetData: [Double] {
        return [total[0].amount, total[1].amount]
    }
    
    var rectangleColor: Color {
        if month {
            return Color(hexString: "#36534D")
        }
        else {
            return Color(hexString: "#39334D")
        }
    }
    
    
    var body: some View {
        if #available(iOS 17.0, *) {
            if !UserDefaults.standard.bool(forKey: "UseLiteMainPage") {
                RoundedRectangle(cornerRadius: 30)
                    .fill(rectangleColor)
                    .stroke(Color.gray.opacity(0.5), lineWidth: 0.1) // 圆角边框
                    .background(RoundedRectangle(cornerRadius: 30).fill(Color(UIColor.systemBackground)))
                    .frame(width: width * 0.46, height: min(width, height) * 0.75) // 设置框的大小
                    .overlay(
                        VStack {
                            HStack {
                                Image(systemName:"chart.line.text.clipboard")
                                Text(description)
                                Spacer()
                            }
                            .bold()
                            .foregroundColor(Color.white)
                            .padding(.top, 6)
                            
                            if total[1].origin_amount >= 0 {
                                HStack {
                                    Text("剩余: " + String(format: "%.2f", total[1].origin_amount))
                                    Spacer()
                                }
                                .bold()
                                .font(.subheadline)
                                .foregroundColor(Color.green.opacity(0.9))
                            }
                            else {
                                HStack {
                                    Text("超支: " + String(format: "%.2f", -total[1].origin_amount))
                                    Spacer()
                                }
                                .font(.subheadline)
                                .foregroundColor(Color.red)
                            }
                            Divider()
                            BudgetChartView(total: total, month: month)
                            Divider()
                            VStack(alignment: .leading) {
                                HStack {
                                    if month {
                                        Text("支出: " + String(format: "%.2f", total[0].origin_amount))
                                            .foregroundStyle(Color(hexString: "#FFD683"))
                                    }
                                    else {
                                        Text("支出: " + String(format: "%.2f", total[0].origin_amount))
                                            .foregroundStyle(Color(hexString: "#FF8A21"))
                                    }
                                    Spacer()
                                }
                                HStack {
                                    if month {
                                        Text("预算: " + String(format: "%.2f", MonthlyBudget))
                                    } else {
                                        Text("预算: " + String(format: "%.2f", YearlyBudget))
                                    }
                                    Spacer()
                                }
                                .foregroundStyle(Color.cyan)
                            }
                            .font(.subheadline)
                        }
                            .bold()
                            .padding(.horizontal, width * 0.05)
                            .padding(.vertical, height * 0.016)
                    )
            }
            else {
                NewBudgetView(width: width, height: height, month: month)
            }
        }
        else {
            NewBudgetView(width: width, height: height, month: month)
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
    
    func calculateTotal() -> [BudgetTotal] {
        let totalAmount: Double
        if month {
            totalAmount = fetchRecords(context: viewContext)
            let rest = Double(MonthlyBudget) - totalAmount
            return [BudgetTotal(amount: rest > 0 ? totalAmount : 0, origin_amount: totalAmount, color: Color(hexString: "#FFD683").opacity(0.3)),
                    BudgetTotal(amount: rest > 0 ? rest : Double(MonthlyBudget), origin_amount: rest, color: rest > 0 ? Color(hexString: "#FFD683").opacity(0.9) : Color.red.opacity(0.9), over: rest < 0)]
        } else {
            totalAmount = fetchRecords(context: viewContext)
            let rest = Double(YearlyBudget) - totalAmount
            return [BudgetTotal(amount: rest > 0 ? totalAmount : 0, origin_amount: totalAmount, color: Color(hexString: "#FF8A21").opacity(0.3)),
                    BudgetTotal(amount: rest > 0 ? rest : Double(YearlyBudget), origin_amount: rest, color: rest > 0 ? Color(hexString: "#FF8A21").opacity(0.9) : Color.red.opacity(0.9), over: rest < 0)]
        }
    }
}

#Preview {
    GeometryReader { geometry in
        HStack(spacing: geometry.size.width * 0.03) {
            BudgetView(width: geometry.size.width, height: geometry.size.height, month: false)
            BudgetView(width: geometry.size.width, height: geometry.size.height)
        }
        .padding(.horizontal, geometry.size.width * 0.024)
    }
}
