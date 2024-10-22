//
//  AccountWidget.swift
//  AccountWidget
//
//  Created by Voltline on 2024/9/15.
//

import WidgetKit
import SwiftUI
import ActivityKit

struct AccountWidget: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: AccountAttributes.self) { context in
            AccountWidgetView(context: context)
        } dynamicIsland: { context in
            DynamicIsland {
                DynamicIslandExpandedRegion(.leading) {
                    Text("本月支出")
                        .bold()
                        .foregroundStyle(Color(hexString: "#7DB9DE"))
                        .padding(.horizontal, 7)
                    HStack(spacing: 2) {
                        Image(systemName: "yensign")
                            .font(.title3)
                        Text("\(String(format: "%.2f", context.state.MonthlyOutcome))")
                            .font(.title2)
                    }
                        .padding(.horizontal, 7)
                        .bold()
                        .foregroundStyle(Color(hexString: "#7DB9DE"))
                    Spacer()
                    Text("本月收入")
                        .bold()
                        .foregroundStyle(Color(hexString: "#24936E"))
                        .padding(.horizontal, 7)
                    HStack(spacing: 2) {
                        Image(systemName: "yensign")
                            .font(.title3)
                        Text("\(String(format: "%.2f", context.state.MonthlyIncome))")
                            .font(.title2)
                    }
                        .bold()
                        .foregroundStyle(Color(hexString: "#24936E"))
                        .padding(.horizontal, 7)
                }
                DynamicIslandExpandedRegion(.trailing) {
                    ZStack {
                        ProgressView(value: 1 - context.state.MonthlyOutcome/context.state.MonthlyBudget)
                            .progressViewStyle(.circular)
                            .tint(Color(hexString: "#39C5BB"))
                        if context.state.MonthlyOutcome > context.state.MonthlyBudget {
                            Text("超支")
                                .font(.title2)
                            .bold()
                            .foregroundStyle(Color.red)
                        }
                        else {
                            Text("\(String(format: "%.0f", (1 - context.state.MonthlyOutcome/context.state.MonthlyBudget) * 100))%")
                                .font(.title2)
                            .bold()
                            .foregroundStyle(Color(hexString: "#39C5BB"))
                        }
                    }

                }
            } compactLeading: {
                if context.state.MonthlyOutcome > context.state.MonthlyBudget {
                    ProgressView(value: 0)
                        .progressViewStyle(.circular)
                        .tint(Color.red)
                }
                else {
                    ProgressView(value: 1 - context.state.MonthlyOutcome/context.state.MonthlyBudget)
                        .progressViewStyle(.circular)
                        .tint(Color(hexString: "#39C5BB"))
                }
            } compactTrailing: {
                if context.state.MonthlyOutcome > context.state.MonthlyBudget {
                    Text("超支")
                        .bold()
                        .foregroundStyle(Color.red)
                }
                else {
                    Text("\(String(format: "%.0f", (1 - context.state.MonthlyOutcome/context.state.MonthlyBudget) * 100))%")
                    .bold()
                    .foregroundStyle(Color(hexString: "#39C5BB"))
                }
            } minimal: {
                if context.state.MonthlyOutcome > context.state.MonthlyBudget {
                    ProgressView(value: 0)
                        .progressViewStyle(.circular)
                        .tint(Color.red)
                }
                else {
                    if context.state.MonthlyOutcome > context.state.MonthlyBudget {
                        ProgressView(value: 0)
                            .progressViewStyle(.circular)
                            .tint(Color.red)
                    }
                    else {
                        ProgressView(value: 1 - context.state.MonthlyOutcome/context.state.MonthlyBudget)
                            .progressViewStyle(.circular)
                            .tint(Color(hexString: "#39C5BB"))
                    }
                }
            }
        }
    }
}

struct AccountWidgetView: View {
    let context: ActivityViewContext<AccountAttributes>
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 0) {
                VStack(alignment: .leading, spacing: 3) {
                    Text("本月支出")
                        .bold()
                        .foregroundStyle(Color(hexString: "#7DB9DE"))
                        .padding(.horizontal, 7)
                    HStack(spacing: 2) {
                        Image(systemName: "yensign")
                            .font(.title2)
                        Text("\(String(format: "%.2f", context.state.MonthlyOutcome))")
                            .font(.title)
                    }
                    .padding(.horizontal, 7)
                    .bold()
                    .foregroundStyle(Color(hexString: "#7DB9DE"))
                }
                Spacer()
                VStack(alignment: .leading, spacing: 3) {
                    Text("本月收入")
                        .bold()
                        .foregroundStyle(Color(hexString: "#24936E"))
                        .padding(.horizontal, 7)
                    HStack(spacing: 2) {
                        Image(systemName: "yensign")
                            .font(.title2)
                        Text("\(String(format: "%.2f", context.state.MonthlyIncome))")
                            .font(.title)
                    }
                    .bold()
                    .foregroundStyle(Color(hexString: "#24936E"))
                    .padding(.horizontal, 7)
                }
            }
            Spacer()
            ZStack {
                ProgressView(value: 1 - context.state.MonthlyOutcome/context.state.MonthlyBudget)
                    .progressViewStyle(.circular)
                    .tint(Color(hexString: "#39C5BB"))
                if context.state.MonthlyOutcome > context.state.MonthlyBudget {
                    Text("超支")
                        .font(.title2)
                    .bold()
                    .foregroundStyle(Color.red)
                }
                else {
                    Text("\(String(format: "%.0f", (1 - context.state.MonthlyOutcome/context.state.MonthlyBudget) * 100))%")
                        .font(.title2)
                    .bold() //#39C5BB
                    .foregroundStyle(Color(hexString: "#39C5BB"))
                }
            }
        }
        .padding()
    }
}

