//
//  ContentView.swift
//  AccountBook
//
//  Created by Voltline on 2024/6/1.
//

import SwiftUI
import CoreData
import AudioToolbox

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Record.record_date, ascending: true)],
        animation: .default)
    private var records: FetchedResults<Record>
    @State private var showAddRecordView: Bool = false
    @StateObject private var categories = Categories()

    var body: some View {
        NavigationStack {
            VStack {
                CustomNavigationBar(username: "用户", icon: "icon_default", size: 65, showAddRecordView: $showAddRecordView)
                    List {
                        ForEach(records) { record in
                            NavigationLink {
                                ModifyRecordView(record: record)
                                    .environment(\.managedObjectContext, viewContext)
                                    .environmentObject(categories);
                            } label: {
                                ItemView(record: record)
                            }
                        }
                        .onDelete(perform: deleteItems)
                    }
                NavigationLink(destination: AddRecordView()
                    .environment(\.managedObjectContext, viewContext)
                    .environmentObject(categories),
                               isActive: $showAddRecordView) {
                    EmptyView()
                }.hidden()
                
            }
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

private let itemFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .short
    formatter.timeStyle = .medium
    return formatter
}()

#Preview {
    ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
