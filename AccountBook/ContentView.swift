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
    @State private var useLocked = UserDefaults.standard.bool(forKey: "UseFaceID")
    @State private var selectionTab = 0
    var body: some View {
        withAnimation(.spring) {
            NavigationStack {
                if (useLocked && !isLocked) || !useLocked {
                    VStack {
                        if selectionTab != 2 {
                            if refreshTrigger {
                                CustomNavigationBar(size: 65, showAddRecordView: $showAddRecordView, userProfile: userProfile, refreshTrigger: $refreshTrigger)
                            }
                            else {
                                CustomNavigationBar(size: 65, showAddRecordView: $showAddRecordView, userProfile: userProfile, refreshTrigger: $refreshTrigger)
                            }
                        }
                        else {
                            SettingBar()
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
                    
                    TabView(selection: $selectionTab) {
                        HomeView()
                            .tabItem {
                                Image(systemName: "house.fill")
                                Text("主页")
                            }
                            .tag(0)
                        RecordListView()
                            .tabItem {
                                Image(systemName: "books.vertical")
                                Text("记录")
                            }
                            .tag(1)
                        SettingsView()
                            .tabItem {
                                Image(systemName: "gear")
                                Text("设置")
                            }
                            .tag(2)
                    }
                }
                else {
                    GeometryReader { geometry in
                        VStack {
                            CircularImageView(imageName: userProfile.icon, size: geometry.size.width * 0.32)
                                .padding(.top, geometry.size.height * 0.15)
                            Text(userProfile.username)
                                .font(.title)
                                .padding(.top, geometry.size.height * 0.03)
                            Spacer(minLength: geometry.size.height * 0.3)
                            HStack {
                                Spacer()
                                Image(systemName: "faceid")
                                    .resizable()
                                    .frame(width: geometry.size.height * 0.07, height: geometry.size.height * 0.07)
                                    .foregroundColor(/*@START_MENU_TOKEN@*/.blue/*@END_MENU_TOKEN@*/)
                                Spacer()
                            }
                            Text("使用 FaceID 验证")
                                .font(.system(size: geometry.size.width * 0.045))
                                .padding(.top, geometry.size.height * 0.02)
                            Spacer()
                        }
                        .onTapGesture {
                            authenticate()
                        }
                    }
                }
            }
            .onAppear {
                authenticate()
            }
        }
    }
    
    private func authenticate() {
        let context = LAContext()
        var error: NSError?
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            UserDefaults.standard.setValue(true, forKey: "UseFaceID")
            useLocked = true
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
        else {
            UserDefaults.standard.setValue(false, forKey: "UseFaceID")
            useLocked = false
            // 无生物识别
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

