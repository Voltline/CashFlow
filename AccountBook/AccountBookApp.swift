//
//  AccountBookApp.swift
//  AccountBook
//
//  Created by Voltline on 2024/6/1.
//

import SwiftUI
import LocalAuthentication
import UserNotifications

@main
struct AccountBookApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .onAppear() {
                    init_use_faceid()
                    init_has_notification()
                    sleep(1)
                }
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
    
    private func init_use_faceid() {
        let context = LAContext()
        var error: NSError?
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            UserDefaults.standard.setValue(false, forKey: "UseFaceID")
        }
        else {
            UserDefaults.standard.setValue(true, forKey: "UseFaceID")
        }
    }
    
    private func init_has_notification() {
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if let error = error {
                print("Authorization error: \(error.localizedDescription)")
            } else if granted {
                UserDefaults.standard.setValue(true, forKey: "HasNotification")
            } else {
                UserDefaults.standard.setValue(false, forKey: "HasNotification")
            }
        }
        
    }
}
