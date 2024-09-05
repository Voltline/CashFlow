//
//  ScreenMonitor.swift
//  AccountBook
//
//  Created by Voltline on 2024/9/5.
//

import SwiftUI
import Combine

class ScreenLockMonitor: ObservableObject {
    // 发布锁屏状态的变化
    @Published var isScreenLocked: Bool = false
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        // 监听设备锁屏通知
        NotificationCenter.default.publisher(for: UIApplication.protectedDataWillBecomeUnavailableNotification)
            .sink { _ in
                self.isScreenLocked = true
            }
            .store(in: &cancellables)
        
        // 监听设备解锁通知
        NotificationCenter.default.publisher(for: UIApplication.protectedDataDidBecomeAvailableNotification)
            .sink { _ in
                self.isScreenLocked = false
            }
            .store(in: &cancellables)
    }
    
    // 提供外部调用的锁屏状态检测函数
    func checkScreenLockStatus() -> Bool {
        return isScreenLocked
    }
}
