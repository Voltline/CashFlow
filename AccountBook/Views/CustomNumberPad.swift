//
//  CustomNumberPad.swift
//  AccountBook
//
//  Created by Voltline on 2024/6/3.
//

import SwiftUI
import AudioToolbox

struct CustomNumberPad: View {
    @Binding var value: String

    let buttons: [[String]] = [
        ["1", "2", "3"],
        ["4", "5", "6"],
        ["7", "8", "9"],
        [".", "0", "⌫"]
    ]

    var body: some View {
        GeometryReader { geometry in
            VStack(alignment: .leading, spacing: 15) {
                ForEach(buttons, id: \.self) { row in
                    HStack(spacing: geometry.size.width * 0.02) {
                        ForEach(row, id: \.self) { button in
                            Button(action: {
                                self.buttonTapped(button)
                                AudioServicesPlaySystemSound(1519)
                            }) {
                                Text(button)
                                    .font(.largeTitle)
                                    .fontWeight(.semibold)
                                    .frame(
                                        width: geometry.size.width * 0.92 / 3,  // 三个按钮的宽度平分屏幕
                                        height: geometry.size.height / 5  // 将高度均分为五部分（4行按钮 + 总间距）
                                    )
                                    .background(Color.gray.opacity(0.2))
                                    .cornerRadius(20)
                            }
                        }
                    }
                    .padding(.horizontal, geometry.size.width * 0.02)
                }
            }
            //.frame(maxHeight: .infinity)
            //.padding(.horizontal)
            //.padding()
        }
    }

    private func buttonTapped(_ button: String) {
        switch button {
        case "⌫":
            if !value.isEmpty {
                if value.count == 1 {
                    value = "0"
                } else {
                    value.removeLast()
                }
            }
        case ".":
            if !value.contains(".") {
                value += button
            }
        default:
            if value.count <= 10 {
                if value.contains(".") {
                    let va = value.split(separator: ".")
                    if va.count < 2 || (va.count == 2 && va[1].count < 2) {
                        value += button
                    }
                } else {
                    if value == "0" {
                        value = button
                    } else if value == "0.0" {
                        value = "0." + button
                    } else {
                        value += button
                    }
                }
            }
        }
    }
}
