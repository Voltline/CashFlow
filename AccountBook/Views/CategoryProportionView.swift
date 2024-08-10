//
//  CategoryProportionView.swift
//  AccountBook
//
//  Created by Voltline on 2024/7/3.
//

import SwiftUI
import Charts
import SwiftUICharts

struct Expense: Identifiable {
    var id = UUID()
    var category: String
    var amount: Double
    var color: Color
    var ratio: Double = 0
    
    var formattedAmount: String {
        String(format: "%.2f", amount)
    }
}

struct CategoryProportionView: View {
    let colors = ["食物": Color.blue, "娱乐": Color.cyan, "日常": Color.orange, "学习": Color.green, "交通": Color.indigo, "购物": Color.red, "话费": Color.brown, "医药": Color.pink, "服装": Color.mint, "商务": Color.yellow, "其他": Color.purple]
    var width: Double
    var height: Double
    @State var formSize = ChartForm.extraLarge
    @Environment(\.colorScheme) var colorScheme
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Record.record_type, ascending: true)],
        animation: .default)
    private var records: FetchedResults<Record>
    var mergedExpenses: [Expense] {
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
    
    var mergedExpensesAll: [(String, Double)] {
        if mergedExpenses[0].category == "无" {
            return []
        }
        var ans: [(String, Double)] = []
        for each in mergedExpenses {
            ans.append((each.category, each.amount))
        }
        return ans
    }
    var total: Double {
        var total: Double = 0
        for expense in records {
            let category = expense.record_type ?? "其他"
            if category == "收入" {
                continue
            }
            let amount = expense.number
            total += amount
        }
        return Double(Int(total))
    }
    
    var real_total: Double {
        var total: Double = 0
        for expense in records {
            let category = expense.record_type ?? "其他"
            if category == "收入" {
                continue
            }
            let amount = expense.number
            total += amount
        }
        return total
    }
    
    var body: some View {
        if mergedExpensesAll.isEmpty {
            ZStack {
                BarChartView(data: ChartData(values: mergedExpensesAll), title: "支出统计", style: ChartStyle(
                    backgroundColor: Color.white,
                    accentColor: Color(hexString: "#84A094"), //84A094 , 698378
                    secondGradientColor: Color(hexString: "#50675D"),
                    textColor: Color.black,
                    legendTextColor:Color.gray,
                    dropShadowColor: Color.gray.opacity(0.4)),
                             form: ChartForm.extraLarge
                )
                Text("无记录")
            }
        }
        else {
            BarChartView(data: ChartData(values: mergedExpensesAll), title: "支出统计",
                         legend: "合计: " + String(format:"%.2f", real_total),
                         style: ChartStyle(
                            backgroundColor: Color.white,
                            accentColor: Color(hexString: "#84A094"), //84A094 , 698378
                            secondGradientColor: Color(hexString: "#50675D"),
                            textColor: Color.black,
                            legendTextColor:Color.gray,
                            dropShadowColor: Color.gray.opacity(0.4)),
                         form: ChartForm.extraLarge,
                         valueSpecifier: "%.2f")
        }
    }
}

#Preview {
    CategoryProportionView(width: 380, height: 200)
}
