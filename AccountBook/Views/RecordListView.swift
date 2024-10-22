//
//  RecordListView.swift
//  AccountBook
//
//  Created by Voltline on 2024/7/3.
//

import SwiftUI
import AudioToolbox

struct RecordListView: View {
    @Environment(\.colorScheme) var colorScheme
    @AppStorage("RecordListViewMode") private var choice = 1
    @Binding var editMode: EditMode
    @Binding var selectedRecords: Set<Record>
    @Binding var refreshTrigger: Bool
    var body: some View {
        VStack(spacing: 0) {
            Picker("", selection: $choice) {
                Text("日").tag(0)
                Text("周").tag(1)
                Text("月").tag(2)
                Text("年").tag(3)
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding()
            .onChange(of: choice) { newChoice in
                AudioServicesPlaySystemSound(1520)
            }
            DateRecordListView(choice: $choice, refreshTrigger: $refreshTrigger, selectedRecords: $selectedRecords, editMode: $editMode)
        }
        .background(colorScheme == .dark ? Color(UIColor.systemBackground) : Color(UIColor.secondarySystemBackground))
    }
}

#Preview {
    RecordListView(editMode: .constant(.inactive), selectedRecords: .constant([]), refreshTrigger: .constant(false))
}
