//
//  ContentView.swift
//  CashFlow
//
//  Created by Voltline on 2024/6/1.
//

import SwiftUI
import CoreData
import AudioToolbox
import LocalAuthentication
import UserNotifications
import MetalKit
import ColorfulX
import ActivityKit
import WhatsNewKit

let version = "1.2.1.1225"

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.scenePhase) var scenePhase
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Record.record_date, ascending: true)],
        animation: .default)
    private var records: FetchedResults<Record>
    @State private var isLocked = true
    @State private var whatsNew: WhatsNew?
    @State private var hasActivity: Bool = false
    @State private var refreshTrigger: Bool = false
    @State private var editMode: EditMode = .inactive
    @State private var showAddRecordView: Bool = false
    @State private var selectedRecords: Set<Record> = []
    @State private var activity: Activity<AccountAttributes>? = nil
    @State private var selectionTab = UserDefaults.standard.integer(forKey: "DefaultView")
    @StateObject private var categories = Categories()
    @StateObject private var userProfile = UserProfile()
    @AppStorage("UseFaceID") private var useFaceID: Bool = false
    @AppStorage("MonthBudget") private var MonthBudget: Double = 3000.0
    let context = LAContext()
    var Income: Double {
        getTodayIncome(records: records)
    }
    var Outcome: Double {
        getTodayOutcome(records: records)
    }
    var MonthlyIncome: Double {
        getThisMonthIncome(records: records)
    }
    var MonthlyOutcome: Double {
        getThisMonthOutcome(records: records)
    }
    
    var body: some View {
        NavigationStack {
            if (!context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil) || (useFaceID && !isLocked) || !useFaceID) {
                if selectionTab != 2 {
                    VStack {
                        if refreshTrigger {
                            CustomNavigationBar(size: 65, recordViewSp: $selectionTab, editMode: $editMode, refreshTrigger: $refreshTrigger, showAddRecordView: $showAddRecordView, selectedRecords: $selectedRecords, userProfile: userProfile)
                        }
                        else {
                            CustomNavigationBar(size: 65, recordViewSp: $selectionTab, editMode: $editMode, refreshTrigger: $refreshTrigger, showAddRecordView: $showAddRecordView, selectedRecords: $selectedRecords, userProfile: userProfile)
                        }
                        Divider()
                        NavigationLink(destination: AddRecordView(refreshTrigger: $refreshTrigger)
                            .environment(\.managedObjectContext, viewContext)
                            .environmentObject(categories),
                                       isActive: $showAddRecordView) {
                            EmptyView()
                        }.hidden()
                    }
                    CustomTabView(selectedTab: $selectionTab, refreshTrigger: $refreshTrigger, editMode: $editMode, selectedRecords: $selectedRecords, activity: $activity, hasActivity: $hasActivity)
                }
                else {
                    CustomTabView(selectedTab: $selectionTab, refreshTrigger: $refreshTrigger, editMode: $editMode, selectedRecords: $selectedRecords, activity: $activity, hasActivity: $hasActivity)
                }
            }
            else {
                LockScreenView(isLocked: $isLocked)
            }
        }
        .sheet(whatsNew: self.$whatsNew,
               layout: WhatsNew.Layout(
                contentSpacing: 70,
                contentPadding: .init(
                    top: 65,
                    leading: 10,
                    bottom: 0,
                    trailing: 30
                )
               )
        )
        .onAppear {
            if !hasActivity {
                let attributes = AccountAttributes()
                let state = AccountAttributes.ContentState(Outcome: Outcome, Income: Income, MonthlyIncome: MonthlyIncome, MonthlyBudget: MonthBudget, MonthlyOutcome: MonthlyOutcome)
                activity = try? Activity<AccountAttributes>.request(attributes: attributes, contentState: state, pushType: nil)
                hasActivity = true
            }
            if UserDefaults.standard.string(forKey: "Version") != version {
                UserDefaults.standard.set(version, forKey: "Version")
                whatsNew = versionWhatsNew
            }
        }
        .onChange(of: MonthBudget) { _ in
            let state = AccountAttributes.ContentState(Outcome: Outcome, Income: Income, MonthlyIncome: MonthlyIncome, MonthlyBudget: MonthBudget, MonthlyOutcome: MonthlyOutcome)
            Task {
                await activity?.update(using: state)
            }
        }
        .onChange(of: refreshTrigger) { _ in
            let state = AccountAttributes.ContentState(Outcome: Outcome, Income: Income, MonthlyIncome: MonthlyIncome, MonthlyBudget: MonthBudget, MonthlyOutcome: MonthlyOutcome)
            Task {
                await activity?.update(using: state)
            }
        }
        .onChange(of: scenePhase) { newPhase in
            if newPhase == .background {
                isLocked = true
            }
        }
    }
}

#Preview {
    ContentView()
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}

