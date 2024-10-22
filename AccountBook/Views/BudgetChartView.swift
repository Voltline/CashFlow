//
//  BudgetChartView.swift
//  AccountBook
//
//  Created by Voltline on 2024/10/22.
//

import SwiftUI
import Charts

struct BudgetChartView: View {
    @State var total: [BudgetTotal]
    @State var month: Bool
    @AppStorage("MonthBudget") private var MonthlyBudget = 3000.0
    @AppStorage("YearBudget") private var YearlyBudget = 100000.0
    var body: some View {
        ZStack {
            if #available(iOS 17.0, *) {
                Chart(total) { expense in
                    SectorMark(
                        angle: .value("Amount", expense.amount),
                        innerRadius: .ratio(0.78),
                        outerRadius: .inset(8),
                        angularInset: 1
                    )
                    .foregroundStyle(expense.color)
                    .cornerRadius(3)
                }
                if total[1].over {
                    Text("已超支")
                        .font(.headline)
                        .foregroundStyle(Color.red)
                }
                else {
                    if month {
                        Text(String(format: "%.0f", total[1].origin_amount * 100 / MonthlyBudget) + "%")
                            .font(.headline)
                            .bold()
                            .foregroundStyle(Color.white)
                    }
                    else {
                        Text(String(format: "%.0f", total[1].origin_amount * 100 / YearlyBudget) + "%")
                            .font(.headline)
                            .bold()
                            .foregroundStyle(Color.white)
                    }
                }
            }
        }
    }
}

#Preview {
    let total: [BudgetTotal] = [BudgetTotal(amount: 100, origin_amount: 100, color: Color.red), BudgetTotal(amount: 0, origin_amount: 100, color: Color.red)]
    VStack {
        BudgetChartView(total: total, month: true)
            .background(Color.secondary)
    }
}
