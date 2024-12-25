//
//  AppShortcuts.swift
//  AccountBook
//
//  Created by 张艺怀 on 2024/12/25.
//

import AppIntents

struct AccountShortcuts: AppShortcutsProvider {
    static var appShortcuts: [AppShortcut] {
        AppShortcut(
            intent: AddRecordIntent(),
            phrases: [
                "用\(.applicationName)记一笔帐",
                "记一笔帐"
            ],
            systemImageName: "plus.circle"
        )
    }
}
