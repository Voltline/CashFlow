//
//  RecordListView.swift
//  AccountBook
//
//  Created by Voltline on 2024/7/3.
//

import SwiftUI

struct RecordListView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.scenePhase) var scenePhase
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Record.record_date, ascending: true)],
        animation: .default)
    private var records: FetchedResults<Record>
    @State private var showAddRecordView: Bool = false
    @State private var refreshTrigger: Bool = false
    @StateObject private var categories = Categories()
    @StateObject private var userProfile = UserProfile()
    var body: some View {
        List {
            ForEach(records) { record in
                NavigationLink {
                    ModifyRecordView(record: record)
                        .environment(\.managedObjectContext, viewContext)
                        .environmentObject(categories);
                } label: {
                    ItemView(record: record)
                }
                .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                    Button(role: .destructive) {
                        deleteItems(offsets: IndexSet(integer: records.firstIndex(of: record)!))
                    } label: {
                        Label("Delete", systemImage: "trash.fill")
                    }
                }
            }
            //.onDelete(perform: deleteItems)
        }
    }
    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            offsets.map { records[$0] }.forEach(viewContext.delete)

            do {
                try viewContext.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }
}
