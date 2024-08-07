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

let version = "1.2.39.0809"

struct ContentView: View {
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
    @State private var isLocked = true
    @State private var selectionTab = UserDefaults.standard.integer(forKey: "DefaultView")
    var body: some View {
        withAnimation(.spring) {
            NavigationStack {
                if (UserDefaults.standard.bool(forKey: "UseFaceID") && !isLocked) || !UserDefaults.standard.bool(forKey: "UseFaceID") {
                    if selectionTab != 2 {
                        VStack {
                            if refreshTrigger {
                                CustomNavigationBar(size: 65, showAddRecordView: $showAddRecordView, userProfile: userProfile, refreshTrigger: $refreshTrigger)
                            }
                            else {
                                CustomNavigationBar(size: 65, showAddRecordView: $showAddRecordView, userProfile: userProfile, refreshTrigger: $refreshTrigger)
                            }
                            Divider()
                            NavigationLink(destination: AddRecordView()
                                .environment(\.managedObjectContext, viewContext)
                                .environmentObject(categories),
                                           isActive: $showAddRecordView) {
                                EmptyView()
                            }.hidden()
                        }
                        .onChange(of: scenePhase) { newPhase in
                            if newPhase == .background {
                                isLocked = true
                            }
                        }
                        CustomTabView(selectedTab: $selectionTab, refreshTrigger: $refreshTrigger)
                    }
                    else {
                        CustomTabView(selectedTab: $selectionTab, refreshTrigger: $refreshTrigger)
                    }
                }
                else {
                    GeometryReader { geometry in
                        VStack(alignment: .center, spacing: geometry.size.height * 0.32) {
                            HStack {
                                Spacer()
                                VStack(alignment: .center, spacing: geometry.size.height * 0.03) {
                                    CircularImageView(imageName: userProfile.icon, size: min(geometry.size.width, geometry.size.height) * 0.28)
                                    Text(userProfile.username)
                                        .font(.title)
                                }
                                Spacer()
                            }
                            VStack(alignment: .center, spacing: geometry.size.height * 0.02) {
                                Image(systemName: "faceid")
                                    .resizable()
                                    .frame(width: min(geometry.size.width, geometry.size.height) * 0.098, height: min(geometry.size.width, geometry.size.height) * 0.098)
                                    .foregroundColor(/*@START_MENU_TOKEN@*/.blue/*@END_MENU_TOKEN@*/)
                                Text("点击验证")
                                    .font(.title3)
                            }
                        }
                        .padding(.vertical, geometry.size.height * 0.15)
                        .onTapGesture {
                            authenticate()
                        }
                    }
                }
            }
            .onAppear {
                if UserDefaults.standard.bool(forKey: "UseFaceID") {
                    authenticate()
                }
            }
        }
    }
    
    private func authenticate() {
        let context = LAContext()
        var error: NSError?
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            let reason = "CashFlow需要解锁才能使用"
            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) { success, authenticationError in
                DispatchQueue.main.async {
                    if success {
                        self.isLocked = false
                    }
                    else {
                        self.isLocked = true
                    }
                }
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


struct CustomTabView: View {
    @Binding private var selectedTab: Int
    @Binding private var refreshTrigger: Bool
    init(selectedTab: Binding<Int>, refreshTrigger: Binding<Bool>) {
        self._selectedTab = selectedTab
        self._refreshTrigger = refreshTrigger
        
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
        withAnimation(.spring) {
            TabView(selection: $selectedTab) {
                HomeView(refreshTrigger: $refreshTrigger)
                    .tabItem {
                        VStack {
                            Image(systemName: "house")
                            Text("主页")
                        }
                    }
                    .tag(0)
                
                RecordListView()
                    .tabItem {
                        VStack {
                            Image(systemName: "book")
                            Text("记录")
                        }
                    }
                    .tag(1)
                
                SettingsView(refreshTrigger: $refreshTrigger)
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
}

#Preview {
    ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}

