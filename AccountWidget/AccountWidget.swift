//
//  AccountWidget.swift
//  AccountWidget
//
//  Created by Voltline on 2024/9/15.
//

import WidgetKit
import SwiftUI
import ActivityKit

extension Color {
    init(hex: String, opacity: Double) {
        let scanner = Scanner(string: hex)
        _ = scanner.scanString("#") // 跳过'#'字符
        
        var rgbValue: UInt64 = 0
        scanner.scanHexInt64(&rgbValue)
        
        let r = Double((rgbValue & 0xFF0000) >> 16) / 255.0
        let g = Double((rgbValue & 0xFF00) >> 8) / 255.0
        let b = Double(rgbValue & 0xFF) / 255.0
        
        self.init(red: r, green: g, blue: b, opacity: opacity)
    }
    
    init(hexString: String) {
        let hex = hexString.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int = UInt64()
        Scanner(string: hex).scanHexInt64(&int)
        let r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (r, g, b) = ((int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (r, g, b) = (int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (r, g, b) = (int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (r, g, b) = (0, 0, 0)
        }
        self.init(red: Double(r) / 255, green: Double(g) / 255, blue: Double(b) / 255)
    }
}


struct AccountWidget: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: AccountAttributes.self) { context in
            AccountWidgetView(context: context)
        } dynamicIsland: { context in
            DynamicIsland {
                DynamicIslandExpandedRegion(.leading) {
                    Text("支出")
                        .bold()
                        .foregroundStyle(Color(hexString: "#7DB9DE"))
                        .padding(.horizontal, 7)
                    HStack(spacing: 2) {
                        Image(systemName: "yensign")
                            .font(.title3)
                        Text("\(String(format: "%.2f", context.state.Outcome))")
                            .font(.title2)
                    }
                        .padding(.horizontal, 7)
                        .bold()
                        .foregroundStyle(Color(hexString: "#7DB9DE"))
                    Spacer()
                    Text("收入")
                        .bold()
                        .foregroundStyle(Color(hexString: "#24936E"))
                        .padding(.horizontal, 7)
                    HStack(spacing: 2) {
                        Image(systemName: "yensign")
                            .font(.title3)
                        Text("\(String(format: "%.2f", context.state.Income))")
                            .font(.title2)
                    }
                        .bold()
                        .foregroundStyle(Color(hexString: "#24936E"))
                        .padding(.horizontal, 7)
                }
                DynamicIslandExpandedRegion(.trailing) {
                    ZStack {
                        ProgressView(value: 1 - context.state.Outcome/context.state.MonthlyBudget)
                            .progressViewStyle(.circular)
                            .tint(Color(hexString: "#39C5BB"))
                        Text("\(String(format: "%.0f", (1 - context.state.Outcome/context.state.MonthlyBudget) * 100))%")
                            .font(.title2)
                        .bold() //#39C5BB
                        .foregroundStyle(Color(hexString: "#39C5BB"))
                    }

                }
            } compactLeading: {
                if context.state.Outcome > context.state.MonthlyBudget {
                    ProgressView(value: 0)
                        .progressViewStyle(.circular)
                        .tint(Color.red)
                }
                else {
                    ProgressView(value: 1 - context.state.Outcome/context.state.MonthlyBudget)
                        .progressViewStyle(.circular)
                        .tint(Color(hexString: "#39C5BB"))
                }
            } compactTrailing: {
                if context.state.Outcome > context.state.MonthlyBudget {
                    Text("超支")
                        .bold()
                        .foregroundStyle(Color.red)
                }
                else {
                    Text("\(String(format: "%.0f", (1 - context.state.Outcome/context.state.MonthlyBudget) * 100))%")
                    .bold() //#39C5BB
                    .foregroundStyle(Color(hexString: "#39C5BB"))
                }
            } minimal: {
                if context.state.Outcome > context.state.MonthlyBudget {
                    ProgressView(value: 0)
                        .progressViewStyle(.circular)
                        .tint(Color.red)
                }
                else {
                    if context.state.Outcome > context.state.MonthlyBudget {
                        ProgressView(value: 0)
                            .progressViewStyle(.circular)
                            .tint(Color.red)
                    }
                    else {
                        ProgressView(value: 1 - context.state.Outcome/context.state.MonthlyBudget)
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
                    Text("支出")
                        .bold()
                        .foregroundStyle(Color(hexString: "#7DB9DE"))
                        .padding(.horizontal, 7)
                    HStack(spacing: 2) {
                        Image(systemName: "yensign")
                            .font(.title2)
                        Text("\(String(format: "%.2f", context.state.Outcome))")
                            .font(.title)
                    }
                    .padding(.horizontal, 7)
                    .bold()
                    .foregroundStyle(Color(hexString: "#7DB9DE"))
                }
                Spacer()
                VStack(alignment: .leading, spacing: 3) {
                    Text("收入")
                        .bold()
                        .foregroundStyle(Color(hexString: "#24936E"))
                        .padding(.horizontal, 7)
                    HStack(spacing: 2) {
                        Image(systemName: "yensign")
                            .font(.title2)
                        Text("\(String(format: "%.2f", context.state.Income))")
                            .font(.title)
                    }
                    .bold()
                    .foregroundStyle(Color(hexString: "#24936E"))
                    .padding(.horizontal, 7)
                }
            }
            Spacer()
            ZStack {
                ProgressView(value: 1 - context.state.Outcome/context.state.MonthlyBudget)
                    .progressViewStyle(.circular)
                    .tint(Color(hexString: "#39C5BB"))
                if context.state.Outcome > context.state.MonthlyBudget {
                    Text("超支")
                        .font(.title2)
                    .bold()
                    .foregroundStyle(Color.red)
                }
                else {
                    Text("\(String(format: "%.0f", (1 - context.state.Outcome/context.state.MonthlyBudget) * 100))%")
                        .font(.title2)
                    .bold() //#39C5BB
                    .foregroundStyle(Color(hexString: "#39C5BB"))
                }
            }
        }
        .padding()
    }
}

