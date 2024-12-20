//
//  LockScreenView.swift
//  AccountBook
//
//  Created by Voltline on 2024/8/25.
//

import SwiftUI
import LocalAuthentication
import MetalKit
import ColorfulX

struct LockScreenView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.scenePhase) var scenePhase
    @Binding var isLocked: Bool
    @State private var themes = all_themes
    @State private var hasFaceIDRecognition = false
    @State private var selectedRecords: Set<Record> = []
    @StateObject private var screenMonitor = ScreenLockMonitor()
    @StateObject private var userProfile = UserProfile()
    @AppStorage("LockScreenTheme") private var lockScreenTheme = 0
    var body: some View {
        GeometryReader { geometry in
            VStack(alignment: .center, spacing: geometry.size.height * 0.32) {
                HStack {
                    Spacer()
                    VStack(alignment: .center, spacing: geometry.size.height * 0.03) {
                        CircularImageView(imageName: userProfile.icon, size: min(geometry.size.width, geometry.size.height) * 0.38, hasShadow: false)
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
            .padding(.vertical, geometry.size.height * 0.165)
            .onTapGesture {
                authenticate()
            }
        }
        .onAppear() {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                // 确保屏幕未锁定才进行生物识别
                if !screenMonitor.isScreenLocked {
                    hasFaceIDRecognition = true
                }
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)) { _ in
            hasFaceIDRecognition = true
        }
        .onChange(of: hasFaceIDRecognition) { _ in
            if hasFaceIDRecognition {
                authenticate()
                hasFaceIDRecognition = false
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(ColorfulView(color: $themes[lockScreenTheme])
            .edgesIgnoringSafeArea(.all))
    }
    
    private func getBiometryType() -> LABiometryType {
         let context = LAContext()
         let _ = context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil)
         return context.biometryType
    }
    
    private func authenticate() {
        let context = LAContext()
        var error: NSError?
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            let reason = "CashFlow使用生物识别保护您的数据"
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

#Preview {
    LockScreenView(isLocked: .constant(true))
}
