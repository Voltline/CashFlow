//
//  AppIntents.swift
//  AccountBook
//
//  Created by 张艺怀 on 2024/12/25.
//

import AppIntents

struct AddRecordIntent: AppIntent {
    static let title: LocalizedStringResource = "记一笔帐"
    static var openAppWhenRun: Bool = true
    
    func perform() async throws -> some IntentResult {
        DispatchQueue.main.async {
            NotificationCenter.default.post(name: .navigateToAddRecord, object: nil)
        }
        return .result()
    }
}

extension Notification.Name {
    static let navigateToAddRecord = Notification.Name("navigateToAddRecord")
}
