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
    var width: Double
    var height: Double
    //@State var value: String
    
    let buttons: [[String]] = [
        ["1", "2", "3"],
        ["4", "5", "6"],
        ["7", "8", "9"],
        [".", "0", "⌫"]
    ]
    
    var body: some View {
        VStack(spacing: 10) {
            ForEach(buttons, id: \.self) { row in
                HStack(spacing: 10) {
                    ForEach(row, id: \.self) { button in
                        Button(action: {
                            self.buttonTapped(button)
                            AudioServicesPlaySystemSound(1519)
                        }) {
                            Text(button)
                                .font(.system(size: height * 0.72))
                                .frame(width: width, height: height)
                                .background(Color.gray.opacity(0.2))
                                .cornerRadius(10)
                        }
                    }
                }
            }
        }
        .padding()
    }
    
    private func buttonTapped(_ button: String) {
        switch button {
        case "⌫":
            if !value.isEmpty {
                if value.count == 1 {
                    value = "0"
                }
                else {
                    value.removeLast()
                }
            }
        case ".":
            if !value.contains(".") {
                value += button
            }
        default:
            if value.count <= 8 {
                if value.contains(".") {
                    let va = value.split(separator: ".")
                    if va.count < 2 || (va.count == 2 && va[1].count < 2) {
                        value += button
                    }
                }
                else {
                    if value == "0" {
                        value = button
                    }
                    else if value == "0.0" {
                        value = "0." + button
                    }
                    else {
                        value += button
                    }
                }
            }
        }
    }
}
/*
#Preview {
    CustomNumberPad(value:)
}
*/
