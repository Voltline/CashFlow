//
//  HomeView.swift
//  AccountBook
//
//  Created by Voltline on 2024/7/3.
//

import SwiftUI
import Charts
import ActivityKit

struct HomeView: View {
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Record.record_type, ascending: true)],
        animation: .default)
    private var records: FetchedResults<Record>
    @Binding var refreshTrigger: Bool
    @Binding var activity: Activity<AccountAttributes>?
    @Binding var hasActivity: Bool
    @State private var showAlert: Bool = false
    
    var Income: Double {
        let calendar = Calendar.current
        let currentDate = Date()
        
        let startDate: Date
        let endDate: Date
        
        let currentMonth = calendar.component(.month, from: currentDate)
        let currentYear = calendar.component(.year, from: currentDate)
        startDate = calendar.date(from: DateComponents(year: currentYear, month: currentMonth, day: 1))!
        endDate = calendar.date(byAdding: .month, value: 1, to: startDate)!
        
        var total: Double = 0
        for record in records {
            if let recordDate = record.record_date, recordDate >= startDate && recordDate < endDate {
                if record.record_type == "收入" {
                    total += record.number
                }
            }
        }
        return total
    }
    
    var Outcome: Double {
        let calendar = Calendar.current
        let currentDate = Date()
        
        let startDate: Date
        let endDate: Date
        
        let currentMonth = calendar.component(.month, from: currentDate)
        let currentYear = calendar.component(.year, from: currentDate)
        startDate = calendar.date(from: DateComponents(year: currentYear, month: currentMonth, day: 1))!
        endDate = calendar.date(byAdding: .month, value: 1, to: startDate)!
        
        var total: Double = 0
        for record in records {
            if let recordDate = record.record_date, recordDate >= startDate && recordDate < endDate {
                if record.record_type != "收入" {
                    total += record.number
                }
            }
        }
        return total
    }
    var body: some View {
        NavigationStack {
            ZStack {
                Color(UIColor.secondarySystemBackground)
                                    .edgesIgnoringSafeArea(.all)
                GeometryReader { geometry in
                    VStack(spacing: 20) {
                        ScrollView {
                            HStack {
                                Text("")
                                    .font(.largeTitle)
                                    .bold()
                                Spacer()
                            }
                            .padding(.horizontal, geometry.size.width * 0.032)
                            HStack(spacing: geometry.size.width * 0.015) {
                                if refreshTrigger {
                                    BudgetView(width: geometry.size.width, height: geometry.size.height, month: false)
                                    BudgetView(width: geometry.size.width, height: geometry.size.height)
                                }
                                else {
                                    BudgetView(width: geometry.size.width, height: geometry.size.height, month: false)
                                    BudgetView(width: geometry.size.width, height: geometry.size.height)
                                }
                            }
                            if UIDevice.current.userInterfaceIdiom == .phone && showAlert {
                            }
                            else {
                                CategoryProportionView(width: geometry.size.width, height: geometry.size.height)
                                    .padding(.top, geometry.size.height * 0.01)
                            }
                        }
                    }
                    .padding(.vertical, geometry.size.height * 0.01)
                }
            }
        }
    }
}

#Preview {
    @State var refreshTrigger = false
    @State var activity: Activity<AccountAttributes>? = nil
    @State var hasActivity: Bool = false
    HomeView(refreshTrigger: $refreshTrigger, activity: $activity, hasActivity: $hasActivity)
}
