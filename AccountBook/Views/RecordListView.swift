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
        sortDescriptors: [NSSortDescriptor(keyPath: \Record.record_date, ascending: false)],
        animation: .default)
    private var records: FetchedResults<Record>
    @State private var showAddRecordView: Bool = false
    @State private var refreshTrigger: Bool = false
    @StateObject private var categories = Categories()
    @StateObject private var userProfile = UserProfile()
    var mergedRecords: [String: [Record]] {
        var result = [String: [Record]]()
        for record in records {
            let date = dateformat(record.record_date!)
            if let existing = result[date] {
                result[date]!.append(record)
            }
            else {
                result[date] = [record]
            }
        }
        for each in result {
            each.value.sorted(by: {
                $0.record_date! > $1.record_date!
            })
        }
        return result
    }
    @State private var sectionHeaders: Set<String> = []
    @State private var rotationAngles: [String: Double] = [:]
    
    var body: some View {
        List {
            ForEach(mergedRecords.keys.sorted(by: { $0 > $1 }), id: \.self) { key in
                Section(header:
                VStack {
                    HStack {
                        Text(key)
                            .font(.subheadline)
                            .bold()
                        Spacer()
                        Button() {
                            withAnimation(.easeInOut(duration: 0.15)) {
                                toggleKey(key)
                            }
                        } label: {
                            Image(systemName: "chevron.up")
                                .rotationEffect(.degrees(rotationAngles[key] ?? 0))
                        }
                    }
                }.padding(.bottom, 6)
                ) {
                    if sectionHeaders.contains(key) {
                        ForEach(mergedRecords[key]!, id: \.self) { record in
                            NavigationLink {
                                ModifyRecordView(record: record)
                                    .environment(\.managedObjectContext, viewContext)
                                    .environmentObject(categories);
                            } label: {
                                ItemView(record: record)
                            }
                            .transition(.move(edge: .top).combined(with: .opacity))
                            .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                                Button(role: .destructive) {
                                    deleteItems(offsets: IndexSet(integer: records.firstIndex(of: record)!))
                                } label: {
                                    Label("Delete", systemImage: "trash.fill")
                                }
                            }
                        }
                    }
                }
            }
        }
        
        .onAppear {
            sectionHeaders = Set(mergedRecords.keys)
            rotationAngles = sectionHeaders.reduce(into: [:]) { $0[$1] = 0 }
        }
    }
    private func toggleKey(_ key: String) {
        if sectionHeaders.contains(key) {
            sectionHeaders.remove(key)
            rotationAngles[key] = (rotationAngles[key] ?? 0) + 180
        } else {
            sectionHeaders.insert(key)
            rotationAngles[key] = (rotationAngles[key] ?? 0) - 180
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
    
    private func dateformat(_ date: Date) -> String {
        let df = DateFormatter()
        df.dateFormat = "yyyy-MM-dd"
        return df.string(from: date)
   }
}
