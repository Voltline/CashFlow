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

let version = "1.2.48.0814"

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
    
    @State private var points: [SIMD2<Float>] = [
        [0.0, 0.0], [0.5, 0.0], [1.0, 0.0],
        [0.0, 0.5], [0.9, 0.3], [1.0, 0.5],
        [0.0, 1.0], [0.5, 1.0], [1.0, 1.0]
    ]
    @State private var colors: [Color] = [
        .black, .black.opacity(0.92), .black.opacity(0.9),
        .blue, .blue, .blue,
        .green, .green, .green
    ]
    @State private var angle: Double = 0.0
    
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
                        CustomTabView(selectedTab: $selectionTab, refreshTrigger: $refreshTrigger, editMode: $editMode, selectedRecords: $selectedRecords)
                    }
                    else {
                        CustomTabView(selectedTab: $selectionTab, refreshTrigger: $refreshTrigger, editMode: $editMode, selectedRecords: $selectedRecords)
                    }
                }
                else {
                    if #available(iOS 18.0, *) {
                        GeometryReader { geometry in
                            VStack(alignment: .center, spacing: geometry.size.height * 0.32) {
                                HStack {
                                    Spacer()
                                    VStack(alignment: .center, spacing: geometry.size.height * 0.03) {
                                        CircularImageView(imageName: userProfile.icon, size: min(geometry.size.width, geometry.size.height) * 0.38)
                                        Text(userProfile.username)
                                            .font(.title)
                                            .bold()
                                            .foregroundStyle(Color.white)
                                    }
                                    Spacer()
                                }
                                
                                switch (getBiometryType()) {
                                case .faceID:
                                    PrimaryButton(image: "faceid", text: "使用Face ID验证")
                                        .onTapGesture {
                                            authenticate()
                                        }
                                case .touchID:
                                    PrimaryButton(image: "touchid", text: "使用Touch ID验证")
                                        .onTapGesture {
                                            authenticate()
                                        }
                                case .opticID:
                                    PrimaryButton(image: "opticid", text: "使用Optic ID验证")
                                        .onTapGesture {
                                            authenticate()
                                        }
                                default:
                                    PrimaryButton(image: "faceid", text: "使用FaceID登录")
                                        .onTapGesture {
                                            authenticate()
                                        }
                                }
                            }
                            .padding(.vertical, geometry.size.height * 0.15)
                            .onTapGesture {
                                authenticate()
                            }
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(MeshGradient(width: 3, height: 3, points: points, colors: colors)
                            .edgesIgnoringSafeArea(.all))
                        .onAppear {
                            if UserDefaults.standard.bool(forKey: "UseDynamicLockScreen") {
                                startCircularMotionAnimation()
                            }
                        }
                    }
                    else {
                        GeometryReader { geometry in
                            VStack(alignment: .center, spacing: geometry.size.height * 0.32) {
                                HStack {
                                    Spacer()
                                    VStack(alignment: .center, spacing: geometry.size.height * 0.03) {
                                        CircularImageView(imageName: userProfile.icon, size: min(geometry.size.width, geometry.size.height) * 0.38)
                                        Text(userProfile.username)
                                            .font(.title)
                                            .bold()
                                            .foregroundStyle(Color.white)
                                    }
                                    Spacer()
                                }
                                
                                switch (getBiometryType()) {
                                case .faceID:
                                    PrimaryButton(image: "faceid", text: "使用Face ID验证")
                                        .onTapGesture {
                                            authenticate()
                                        }
                                case .touchID:
                                    PrimaryButton(image: "touchid", text: "使用Touch ID验证")
                                        .onTapGesture {
                                            authenticate()
                                        }
                                case .opticID:
                                    PrimaryButton(image: "opticid", text: "使用Optic ID验证")
                                        .onTapGesture {
                                            authenticate()
                                        }
                                default:
                                    PrimaryButton(image: "faceid", text: "使用FaceID登录")
                                        .onTapGesture {
                                            authenticate()
                                        }
                                }
                            }
                            .padding(.vertical, geometry.size.height * 0.15)
                            .onTapGesture {
                                authenticate()
                            }
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(LinearGradient(colors: [.blue, .purple], startPoint: .topLeading, endPoint: .bottomTrailing))
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
    
    private func getBiometryType() -> LABiometryType {
         let context = LAContext()
         let canEvaluatePolicy = context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil)
         return context.biometryType
    }
    
    private func startCircularMotionAnimation() {
        Timer.scheduledTimer(withTimeInterval: 0.023, repeats: true) { _ in
            angle += 0.03
            withAnimation(.easeInOut(duration: 0.0)) {
                let radius: Double = 0.2 // 半径
                let centerX: Double = 0.5
                let centerY: Double = 0.4
                
                let newX = centerX + radius * 1.6 * cos(angle)
                let newY = centerY + radius * sin(angle)
                
                points[4] = [Float(newX), Float(newY)]
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
    init(selectedTab: Binding<Int>, refreshTrigger: Binding<Bool>, editMode: Binding<EditMode>, selectedRecords: Binding<Set<Record>>) {
        self._selectedTab = selectedTab
        self._refreshTrigger = refreshTrigger
        self._editMode = editMode
        self._selectedRecords = selectedRecords
        
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

#Preview {
    ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}

