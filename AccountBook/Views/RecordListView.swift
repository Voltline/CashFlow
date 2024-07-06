//
//  RecordListView.swift
//  AccountBook
//
//  Created by Voltline on 2024/7/3.
//

import SwiftUI

struct RecordListView: View {
    @State private var choice: Int = UserDefaults.standard.integer(forKey: "RecordListViewMode")
    var body: some View {
        VStack(spacing: 0) {
            MultiSelectSlider(selectedIndex: $choice, options: ["日", "周", "月", "年"])
                .padding(.horizontal, 12)
                .padding(.vertical, 12)
            DateRecordListView(choice: $choice)
        }
        .background(Color(UIColor.secondarySystemBackground))
    }
}
