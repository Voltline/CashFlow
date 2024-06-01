//
//  AccountBookApp.swift
//  AccountBook
//
//  Created by 张艺怀 on 2024/6/1.
//

import SwiftUI

@main
struct AccountBookApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
