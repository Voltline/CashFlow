//
//  SummaryView.swift
//  AccountBook
//
//  Created by Voltline on 2024/9/17.
//

import SwiftUI
import CoreData

struct SummaryView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.scenePhase) var scenePhase
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Record.record_date, ascending: true)],
        animation: .default)
    private var records: FetchedResults<Record>
    var body: some View {
        NavigationStack {
            Text("Hello")
        }
    }
}

#Preview {
    SummaryView()
}
