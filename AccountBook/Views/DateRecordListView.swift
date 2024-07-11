//
//  DateRecordListView.swift
//  AccountBook
//
//  Created by Voltline on 2024/7/6.
//

import SwiftUI
import AudioToolbox

struct DateRecordListView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.scenePhase) var scenePhase
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Record.record_date, ascending: false)],
        animation: .default)
    private var records: FetchedResults<Record>
    @StateObject private var categories = Categories()
    @Binding var choice: Int// 0 for day, 1 for week, 2 for month, 3 for year
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
    var mergedRecordsWeek: [weekYear: [Record]]  {
        var result = [weekYear: [Record]]()
        for record in records {
            let week = weekOfYear(for: record.record_date!)
            if let existing = result[week] {
                result[week]!.append(record)
            }
            else {
                result[week] = [record]
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
    
    @State private var sectionHeadersWeek: Set<weekYear> = []
    @State private var rotationAnglesWeek: [weekYear: Double] = [:]
    var body: some View {
        if choice != 1 {
            List {
                ForEach(mergedRecords.keys.sorted(by: { $0 > $1 }), id: \.self) { key in
                    Section(header:
                    VStack {
                        HStack(spacing: 8) {
                            if choice == 0 {
                                VStack(alignment: .leading) {
                                    Text(key)
                                    Text(dayOfWeek(from: key))
                                }
                                .bold()
                                .font(.subheadline)
                            }
                            else {
                                Text(key)
                                    .bold()
                                    .font(.subheadline)
                            }
                            Spacer()
                            VStack(alignment: .leading) {
                                Text("支出: " + String(format: "%.2f", getRecordSum(key).1))
                                    .foregroundColor(Color.red.opacity(0.6))
                                Text("收入: " + String(format: "%.2f", getRecordSum(key).0))
                                    .foregroundColor(Color.green.opacity(0.8))
                            }
                            .bold()
                            .font(.subheadline)
                            Button() {
                                withAnimation(.easeInOut(duration: 0.15)) {
                                    toggleKey(key)
                                    AudioServicesPlaySystemSound(1519)
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
            .onChange(of: choice) {
                if choice != 1 {
                    sectionHeaders = Set(mergedRecords.keys)
                    rotationAngles = sectionHeaders.reduce(into: [:]) { $0[$1] = 0 }
                }
                else {
                    sectionHeadersWeek = Set(mergedRecordsWeek.keys)
                    rotationAnglesWeek = sectionHeadersWeek.reduce(into: [:]) { $0[$1] = 0 }
                }
            }
            .onAppear {
                sectionHeaders = Set(mergedRecords.keys)
                rotationAngles = sectionHeaders.reduce(into: [:]) { $0[$1] = 0 }
                sectionHeadersWeek = Set(mergedRecordsWeek.keys)
                rotationAnglesWeek = sectionHeadersWeek.reduce(into: [:]) { $0[$1] = 0 }
            }
        }
        else {
            List {
                ForEach(mergedRecordsWeek.keys.sorted(by: { $0 > $1 }), id: \.self) { key in
                    Section(header:
                    VStack {
                        HStack(spacing: 10) {
                            VStack(alignment: .leading) {
                                Text(String(key.year) + "第\(key.week)周")
                                Text(datesForWeekOfYear(key) ?? "01.01-01.07")
                            }
                            .font(.subheadline)
                            .bold()
                            Spacer()
                            VStack(alignment: .leading) {
                                Text("支出: " + String(format: "%.2f", getRecordSum(key).1))
                                    .foregroundColor(Color.red.opacity(0.6))
                                Text("收入: " + String(format: "%.2f", getRecordSum(key).0))
                                    .foregroundColor(Color.green.opacity(0.8))
                            }
                            .bold()
                            .font(.subheadline)
                            Button() {
                                withAnimation(.easeInOut(duration: 0.15)) {
                                    toggleKey(key)
                                }
                            } label: {
                                Image(systemName: "chevron.up")
                                    .rotationEffect(.degrees(rotationAnglesWeek[key] ?? 0))
                            }
                        }
                    }.padding(.bottom, 6)
                    ) {
                        if sectionHeadersWeek.contains(key) {
                            ForEach(mergedRecordsWeek[key]!, id: \.self) { record in
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
            .onChange(of: choice) {
                if choice != 1 {
                    sectionHeaders = Set(mergedRecords.keys)
                    rotationAngles = sectionHeaders.reduce(into: [:]) { $0[$1] = 0 }
                }
                else {
                    sectionHeadersWeek = Set(mergedRecordsWeek.keys)
                    rotationAnglesWeek = sectionHeadersWeek.reduce(into: [:]) { $0[$1] = 0 }
                }
            }
            .onAppear {
                sectionHeadersWeek = Set(mergedRecordsWeek.keys)
                rotationAnglesWeek = sectionHeadersWeek.reduce(into: [:]) { $0[$1] = 0 }
                sectionHeadersWeek = Set(mergedRecordsWeek.keys)
                rotationAnglesWeek = sectionHeadersWeek.reduce(into: [:]) { $0[$1] = 0 }
            }
        }
    }
    
    private func getRecordSum(_ key: String) -> (income: Double, outcome: Double) {
        var income: Double = 0, outcome: Double = 0
        let records = mergedRecords[key] ?? []
        for i in records {
            if i.positive {
                income += i.number
            }
            else {
                outcome += i.number
            }
        }
        return (income, outcome)
    }
    
    private func getRecordSum(_ key: weekYear) -> (income: Double, outcome: Double) {
        var income: Double = 0, outcome: Double = 0
        let records = mergedRecordsWeek[key] ?? []
        for i in records {
            if i.positive {
                income += i.number
            }
            else {
                outcome += i.number
            }
        }
        return (income, outcome)
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
    
    private func toggleKey(_ key: weekYear) {
        if sectionHeadersWeek.contains(key) {
            sectionHeadersWeek.remove(key)
            rotationAnglesWeek[key] = (rotationAnglesWeek[key] ?? 0) + 180
        } else {
            sectionHeadersWeek.insert(key)
            rotationAnglesWeek[key] = (rotationAnglesWeek[key] ?? 0) - 180
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
        switch choice {
        case 0:
            df.dateFormat = "yyyy.MM.dd"
        case 2:
            df.dateFormat = "yyyy.MM"
        case 3:
            df.dateFormat = "yyyy"
        default:
            df.dateFormat = "yyyy.MM.dd"
        }
        return df.string(from: date)
   }
}

#Preview {
    @State var choice = 1
    DateRecordListView(choice: $choice)
}
