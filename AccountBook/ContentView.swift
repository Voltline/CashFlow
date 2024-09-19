//
//  ContentView.swift
//  AccountBook
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

let version = "1.2.55.0920"

struct ContentView: View {
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
    @State private var isLocked = true
    @State private var selectionTab = UserDefaults.standard.integer(forKey: "DefaultView")
    @State var editMode: EditMode = .inactive
    @State var selectedRecords: Set<Record> = []
    @State private var lockScreenTheme = UserDefaults.standard.integer(forKey: "LockScreenTheme")
    @State private var themes = [ColorfulPreset.aurora.colors, ColorfulPreset.appleIntelligence.colors, ColorfulPreset.neon.colors, ColorfulPreset.ocean.colors]
    @State var activity: Activity<AccountAttributes>? = nil
    @State var hasActivity: Bool = false
    let context = LAContext()
    var Income: Double {
        let calendar = Calendar.current
        let currentDate = Date()
        
        var total: Double = 0
        for record in records {
            if let recordDate = record.record_date, calendar.isDate(recordDate, inSameDayAs: currentDate) && record.record_type == "收入" {
                total += record.number
            }
        }
        return total
    }
    
    var Outcome: Double {
        let calendar = Calendar.current
        let currentDate = Date()
        
        var total: Double = 0
        for record in records {
            if let recordDate = record.record_date, calendar.isDate(recordDate, inSameDayAs: currentDate) && record.record_type != "收入" {
                total += record.number
            }
        }
        return total
    }
    
    @State
    var versionWhatsNew: WhatsNew? = WhatsNew(
        title: "CashFlow的新功能",
        features: [
            .init(
                image: .init(systemName: "calendar", foregroundColor: .cyan),
                title: "修改账目时间",
                subtitle: "您可在增加或修改账目时快捷地修改对应的记账日期与时间。"
            ),
            .init(
                image: .init(systemName: "app.badge", foregroundColor: .red.opacity(0.9)),
                title: "全新通知形式",
                subtitle: "全新的实时活动与灵动岛通知使得您可以便捷地查看当日开销与收入。"
            ),
            .init(image: .init(systemName: "chart.bar.doc.horizontal", foregroundColor: .orange),
                  title: "每周财务报告",
                  subtitle: "未来的几个版本中，将会上线更加关注您每周财务状况的财务报告。"
             ),
            .init(image: .init(systemName: "paintpalette", foregroundColor: .green.opacity(0.8)),
                  title: "视觉元素更新",
                  subtitle: "部分文本与视觉元素均进行了调整，以更好传达视觉效果"
             ),
        ],
        primaryAction: .init(
            title: "好的"
        )
    )
    
    @State private var whatsNew: WhatsNew?
    
    var body: some View {
        withAnimation(.spring) {
            NavigationStack {
                if (!context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil) || (UserDefaults.standard.bool(forKey: "UseFaceID") && !isLocked) || !UserDefaults.standard.bool(forKey: "UseFaceID")) {
                    if selectionTab != 2 {
                        VStack {
                            if refreshTrigger {
                                CustomNavigationBar(size: 65, showAddRecordView: $showAddRecordView, userProfile: userProfile, refreshTrigger: $refreshTrigger, recordViewSp: $selectionTab, editMode: $editMode, selectedRecords: $selectedRecords)
                            }
                            else {
                                CustomNavigationBar(size: 65, showAddRecordView: $showAddRecordView, userProfile: userProfile, refreshTrigger: $refreshTrigger, recordViewSp: $selectionTab, editMode: $editMode, selectedRecords: $selectedRecords)
                            }
                            Divider()
                            NavigationLink(destination: AddRecordView(refreshTrigger: $refreshTrigger)
                                .environment(\.managedObjectContext, viewContext)
                                .environmentObject(categories),
                                           isActive: $showAddRecordView) {
                                EmptyView()
                            }.hidden()
                        }
                        CustomTabView(selectedTab: $selectionTab, refreshTrigger: $refreshTrigger, editMode: $editMode, selectedRecords: $selectedRecords, lockScreenTheme: $lockScreenTheme, activity: $activity, hasActivity: $hasActivity)
                    }
                    else {
                        CustomTabView(selectedTab: $selectionTab, refreshTrigger: $refreshTrigger, editMode: $editMode, selectedRecords: $selectedRecords, lockScreenTheme: $lockScreenTheme, activity: $activity, hasActivity: $hasActivity)
                    }
                }
                else {
                    LockScreenView(isLocked: $isLocked)
                }
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
                let state = AccountAttributes.ContentState(Outcome: Outcome, Income: Income, MonthlyBudget: UserDefaults.standard.double(forKey: "MonthBudget"))
                
                activity = try? Activity<AccountAttributes>.request(attributes: attributes, contentState: state, pushType: nil)
                hasActivity = true
            }
            if UserDefaults.standard.string(forKey: "Version") != version {
                UserDefaults.standard.set(version, forKey: "Version")
                whatsNew = versionWhatsNew
            }
        }
        .onChange(of: refreshTrigger) { _ in
            let state = AccountAttributes.ContentState(Outcome: Outcome, Income: Income, MonthlyBudget: UserDefaults.standard.double(forKey: "MonthBudget"))
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

private let itemFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .short
    formatter.timeStyle = .medium
    return formatter
}()

struct PrimaryButton: View {
    var image: String?
    var showImage = true
    var text: String
    @State private var backgroundState: ColorScheme = .dark
    @State var useBlurEffect = UserDefaults.standard.bool(forKey: "LockScreenUseBlurEffect")
    
    var body: some View {
        if useBlurEffect {
            ZStack {
                // 胶囊形状背景
                RoundedRectangle(cornerRadius: 30)
                    .frame(width: 200, height: 50)
                    .background(.thinMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 30))
                // HStack内容
                HStack {
                    if showImage {
                        Image(systemName: image ?? "person.fill")
                    }
                    Text(text)
                }
                .foregroundStyle(Color.white)
                .padding()
                .padding(.horizontal)
            }
            .environment(\.colorScheme, backgroundState)
            .background(Color.clear)
            .padding(.horizontal) // 可选的整体布局调整
        }
        else {
            HStack {
                if showImage {
                    Image(systemName: image ?? "person.fill")
                }
                Text(text)
            }
            .padding()
            .padding(.horizontal)
            .background(.white)
            .cornerRadius(30)
            .shadow(radius: 10)
        }
    }
}

struct CustomTabView: View {
    @Binding private var selectedTab: Int
    @Binding private var refreshTrigger: Bool 
    @Binding var editMode: EditMode
    @Binding var selectedRecords: Set<Record>
    @Binding var lockScreenTheme: Int
    @Binding var activity: Activity<AccountAttributes>?
    @Binding var hasActivity: Bool
    init(selectedTab: Binding<Int>, refreshTrigger: Binding<Bool>, editMode: Binding<EditMode>, selectedRecords: Binding<Set<Record>>, lockScreenTheme: Binding<Int>, activity: Binding<Activity<AccountAttributes>?>, hasActivity: Binding<Bool>) {
        self._selectedTab = selectedTab
        self._refreshTrigger = refreshTrigger
        self._editMode = editMode
        self._selectedRecords = selectedRecords
        self._lockScreenTheme = lockScreenTheme
        self._activity = activity
        self._hasActivity = hasActivity
        
        // Customize the TabBar appearance
        let tabBarAppearance = UITabBarAppearance()
        tabBarAppearance.configureWithOpaqueBackground()
        tabBarAppearance.backgroundColor = UIColor.secondarySystemBackground
        UITabBar.appearance().standardAppearance = tabBarAppearance
        UITabBar.appearance().scrollEdgeAppearance = tabBarAppearance
        
        // Customize the position of the tab bar items
        let itemAppearance = UITabBarItemAppearance()
        itemAppearance.normal.titlePositionAdjustment = UIOffset(horizontal: 0, vertical: 3)
        itemAppearance.selected.titlePositionAdjustment = UIOffset(horizontal: 0, vertical: 3)
        
        tabBarAppearance.stackedLayoutAppearance = itemAppearance
        tabBarAppearance.inlineLayoutAppearance = itemAppearance
        tabBarAppearance.compactInlineLayoutAppearance = itemAppearance
    }

    var body: some View {
        TabView(selection: $selectedTab) {
            HomeView(refreshTrigger: $refreshTrigger, activity: $activity, hasActivity: $hasActivity)
                .tabItem {
                    VStack {
                        Image(systemName: "house")
                        Text("主页")
                    }
                }
                .tag(0)
            
            RecordListView(editMode: $editMode, selectedRecords: $selectedRecords, refreshTrigger: $refreshTrigger)
                .tabItem {
                    VStack {
                        Image(systemName: "book")
                        Text("记录")
                    }
                }
                .tag(1)
            
            SettingsView(refreshTrigger: $refreshTrigger, lockScreenTheme: $lockScreenTheme)
                .tabItem {
                    VStack {
                        Image(systemName: "gearshape")
                        Text("设置")
                    }
                }
                .tag(2)
        }
    }
}

#Preview {
    ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}

