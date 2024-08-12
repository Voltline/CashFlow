//
//  CategoryProportionView.swift
//  AccountBook
//
//  Created by Voltline on 2024/7/3.
//

import SwiftUI
import Charts

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
        if #available(iOS 17.0, *) {
            if UserDefaults.standard.bool(forKey: "UseOldMainPage") {
                RoundedRectangle(cornerRadius: 30)
                    .fill(Color(hexString: "002B63"))
                    .stroke(Color.gray.opacity(0.5), lineWidth: 0.1) // 圆角边框
                    .background(RoundedRectangle(cornerRadius: 30).fill(Color(UIColor.systemBackground)))
                    .frame(width: width * 0.93, height: height * 0.6) // 设置框的大小
                    .overlay(
                    VStack {
                        HStack {
                            Image(systemName:"chart.pie")
                            Text("支出统计")
                            Spacer()
                            Text("")
                            HStack(spacing: 1) {
                                Image(systemName: "yensign")
                                    .font(.subheadline)
                                Text(String(format:"%.2f", real_total))
                            }
                            .frame(width: 55 + (total == 0 ? 0 : log10(total) * 8.96), height: 6)
                                .padding()
                                .background(Color.white.opacity(0.3))
                                .cornerRadius(18)
                        }
                        .bold()
                        .foregroundColor(Color.white)
                        .padding(.top, 6)
                        Divider()
                        HStack {
                            Chart(mergedExpenses) { expense in
                                SectorMark(
                                    angle: .value("Amount", expense.amount),
                                    innerRadius: .ratio(0.78),
                                    outerRadius: .inset(8),
                                    angularInset: 1
                                )
                                .cornerRadius(3)
                                .foregroundStyle(expense.color)
                            }
                            .padding()
                            // 图例
                            VStack {
                                Spacer()
                                VStack(alignment: .leading, spacing: 5) {
                                    ForEach(mergedExpenses) { expense in
                                        HStack {
                                            Rectangle()
                                                .fill(expense.color)
                                                .frame(width: 10, height: 10)
                                            if expense.category == "无" {
                                                Text("无")
                                                    .font(.caption)
                                            }
                                            else {
                                                Text("\(expense.category):" +  String(format: "%.0f", expense.ratio * 100) + "%")
                                                    .font(.caption)
                                            }
                                        }
                                        .bold()
                                        .foregroundStyle(Color.white)
                                    }
                                }
                                .padding()
                                .background(Color.white.opacity(0.3))
                                .cornerRadius(15)
                            }
                        }
                        Divider()
                        VStack {
                            HStack {
                                Image(systemName: "chart.line.uptrend.xyaxis")
                                Text("消费最多类别")
                                Spacer()
                            }
                            .foregroundColor(Color.white)
                            .bold()
                            .padding(.vertical, height * 0.009)
                            
                            VStack {
                                if mergedExpenses[0].category == "无" {
                                    Text("无记录")
                                        .font(.title2)
                                        .foregroundStyle(Color.white)
                                }
                                else {
                                    Text(mergedExpenses[0].category)
                                        .font(.title2)
                                        .foregroundStyle(Color.white)
                                }
                            }
                                .bold()
                                .frame(width: 63, height: 10)
                                .padding()
                                .background(Color.white.opacity(0.3))
                                .cornerRadius(15)
                        }

                    }
                        .padding(.horizontal, width * 0.06)
                        .padding(.vertical, height * 0.01)
                    )
            }
            else {
                NewCategoryProportionView(width: width, height: height)
            }
        }
        else {
            NewCategoryProportionView(width: width, height: height)
        }
    }
}

#Preview {
    CategoryProportionView(width: 400, height: 600)
}
