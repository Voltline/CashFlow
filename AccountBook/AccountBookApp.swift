//
//  AccountBookApp.swift
//  AccountBook
//
//  Created by Voltline on 2024/6/1.
//

import SwiftUI
import LocalAuthentication

@main
struct AccountBookApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .onAppear() {
                    init_use_faceid()
                    sleep(1)
                }
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
    private func init_use_faceid() {
        let context = LAContext()
        var error: NSError?
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            UserDefaults.standard.setValue(true, forKey: "UseFaceID")
        }
        else {
            UserDefaults.standard.setValue(true, forKey: "UseFaceID")
        }
    }
}
