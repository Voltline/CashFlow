//
//  UserProfile.swift
//  AccountBook
//
//  Created by Voltline on 2024/6/6.
//

import Foundation
import SwiftUI
import Combine

class UserProfile: ObservableObject {
    @Published var username: String
    @Published var icon: String
    @Published var uuid: UUID

    init() {
        self.username = UserDefaults.standard.string(forKey: "username") ?? "用户"
        self.icon = UserDefaults.standard.string(forKey: "icon") ?? "icon_default"
        self.uuid = UUID()
    }

    func updateUsername(_ newUsername: String) {
        self.username = newUsername
        UserDefaults.standard.set(newUsername, forKey: "username")
        self.uuid = UUID()
    }

    func updateIcon(_ newIcon: String) {
        self.icon = newIcon
        UserDefaults.standard.set(newIcon, forKey: "icon")
        self.uuid = UUID()
    }

    func loadProfileImage() -> UIImage? {
        let filename = getDocumentsDirectory().appendingPathComponent("profile.png")
        if let data = try? Data(contentsOf: filename) {
            return UIImage(data: data)
        }
        return nil
    }

    private func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
}
