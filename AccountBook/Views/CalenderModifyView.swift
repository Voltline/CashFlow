//
//  CalenderModifyView.swift
//  CashFlow
//
//  Created by Voltline on 2024/10/20.
//

import AudioToolbox
import Foundation
import SwiftUI

struct CalenderModifyView: View {
    @Binding var selectedDate: Date
    @Binding var newDate: Date
    var action: () -> Void
    var body: some View {
        NavigationView {
            List {
                Section {
                    HStack {
                        Text("原始时间")
                        Spacer()
                        Text(dateFormatter.string(from: selectedDate))
                            .foregroundStyle(Color.gray.opacity(0.5))
                    }
                    HStack {
                        Text("调整后")
                        Spacer()
                        Text(dateFormatter.string(from: newDate))
                    }
                } header: {
                } footer: {
                }
        
                Section {
                    DatePicker(" ", selection: $newDate, displayedComponents: [.date, .hourAndMinute])
                        .datePickerStyle(GraphicalDatePickerStyle())
                    Button() {
                        AudioServicesPlaySystemSound(1519)
                        newDate = selectedDate
                    } label: {
                        Text("还原为调整前")
                            .foregroundStyle(Color.blue)
                    }
                    Button() {
                        AudioServicesPlaySystemSound(1519)
                        newDate = Date()
                    } label: {
                        Text("选择当前时间")
                            .foregroundStyle(Color.blue)
                    }
                } header: {
                } footer: {
                }
            }
                .navigationBarItems(leading: Button("返回") {
                    action()
                })
                .navigationBarItems(trailing: Button("调整") {
                    selectedDate = newDate
                    action()
                })
                .navigationBarTitle("修改日期与时间", displayMode: .inline)
        }
    }
    
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy年M月d日 HH:mm:ss"
        return formatter
    }
}

#Preview {
    var showCalenderSelect: Bool = false
    CalenderModifyView(selectedDate: .constant(Date()), newDate: .constant(Date())) {
        showCalenderSelect = false
    }
}
