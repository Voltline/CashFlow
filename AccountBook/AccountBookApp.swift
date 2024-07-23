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
                    if UserDefaults.standard.double(forKey: "MonthBudget") == 0 {
                        UserDefaults.standard.setValue(3000, forKey: "MonthBudget")
                    }
                    if UserDefaults.standard.double(forKey: "YearBudget") == 0 {
                        UserDefaults.standard.setValue(100000, forKey: "YearBudget")
                    }
                    init_has_notification()
                    sleep(1)
                }
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
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
