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

let version = "1.2.52.0825"

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
    @State var editMode: EditMode = .inactive
    @State var selectedRecords: Set<Record> = []
    @State private var lockScreenTheme = UserDefaults.standard.integer(forKey: "LockScreenTheme")
    @State private var themes = [ColorfulPreset.aurora.colors, ColorfulPreset.appleIntelligence.colors, ColorfulPreset.neon.colors, ColorfulPreset.ocean.colors]
    
    var body: some View {
        withAnimation(.spring) {
            NavigationStack {
                if ((UserDefaults.standard.bool(forKey: "UseFaceID") && !isLocked) || !UserDefaults.standard.bool(forKey: "UseFaceID")) {
                    if selectionTab != 2 {
                        VStack {
                            if refreshTrigger {
                                CustomNavigationBar(size: 65, showAddRecordView: $showAddRecordView, userProfile: userProfile, refreshTrigger: $refreshTrigger, recordViewSp: $selectionTab, editMode: $editMode, selectedRecords: $selectedRecords)
                            }
                            else {
                                CustomNavigationBar(size: 65, showAddRecordView: $showAddRecordView, userProfile: userProfile, refreshTrigger: $refreshTrigger, recordViewSp: $selectionTab, editMode: $editMode, selectedRecords: $selectedRecords)
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
                        CustomTabView(selectedTab: $selectionTab, refreshTrigger: $refreshTrigger, editMode: $editMode, selectedRecords: $selectedRecords, lockScreenTheme: $lockScreenTheme)
                    }
                    else {
                        CustomTabView(selectedTab: $selectionTab, refreshTrigger: $refreshTrigger, editMode: $editMode, selectedRecords: $selectedRecords, lockScreenTheme: $lockScreenTheme)
                    }
                }
                else {
                    LockScreenView(isLocked: $isLocked)
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

struct PrimaryButton: View {
    var image: String?
    var showImage = true
    var text: String
    
    var body: some View {
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

struct CustomTabView: View {
    @Binding private var selectedTab: Int
    @Binding private var refreshTrigger: Bool 
    @Binding var editMode: EditMode
    @Binding var selectedRecords: Set<Record>
    @Binding var lockScreenTheme: Int
    init(selectedTab: Binding<Int>, refreshTrigger: Binding<Bool>, editMode: Binding<EditMode>, selectedRecords: Binding<Set<Record>>, lockScreenTheme: Binding<Int>) {
        self._selectedTab = selectedTab
        self._refreshTrigger = refreshTrigger
        self._editMode = editMode
        self._selectedRecords = selectedRecords
        self._lockScreenTheme = lockScreenTheme
        
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
            HomeView(refreshTrigger: $refreshTrigger)
                .tabItem {
                    VStack {
                        Image(systemName: "house")
                        Text("主页")
                    }
                }
                .tag(0)
            
            RecordListView(editMode: $editMode, selectedRecords: $selectedRecords)
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

