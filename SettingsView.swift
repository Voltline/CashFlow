//
//  SettingsView.swift
//  AccountBook
//
//  Created by Voltline on 2024/7/3.
//

import SwiftUI

struct SettingsView: View {
    @State private var useNotification: Bool = UserDefaults.standard.bool(forKey: "UseNotification")
    @State private var notifyHour = UserDefaults.standard.integer(forKey: "NotificationHour")
    @State private var notifyMins = UserDefaults.standard.integer(forKey: "NotificationMins")
    @State private var notificationTime = Date()
    var body: some View {
        NavigationStack {
            GeometryReader { geometry in
                Divider()
                VStack(spacing: 15) {
                    HStack {
                        Text("定时通知")
                            .font(.title2)
                        Spacer()
                        Toggle("", isOn: $useNotification)
                            .onChange(of: useNotification) { newValue in
                                ToggleUseNotification(to: newValue)
                            }
                    }
                    .padding(.horizontal, geometry.size.width * 0.05)
                    DatePicker(
                        "选择推送时间",
                        selection: $notificationTime,
                        displayedComponents: [.hourAndMinute]
                    )
                    .padding(.horizontal, geometry.size.width * 0.05)
                    .onChange(of: notificationTime) { new in
                        let useNotification = UserDefaults.standard.bool(forKey: "UseNotification")
                        let hasNotification = UserDefaults.standard.bool(forKey: "HasNotification")
                        if useNotification && hasNotification {
                            setNotificationTime()
                        }
                    }
                    .onAppear() {
                        notificationTime = createDateFromString(dateString: "\(notifyHour):\(notifyMins)")
                    }
                    Button(action: RemoveAllNotifications) {
                        Text("移除所有提醒")
                            .bold()
                            .foregroundColor(Color.red)
                    }
                    Divider()
                    Spacer()
                    withAnimation(.easeOut(duration: 0.2)) {
                        Link(destination: URL(string: "https://github.com/Voltline/CashFlow")!) {
                            VStack {
                                Text("CashFlow基于MIT协议开源")
                            }
                            .font(.footnote)
                        }
                    }
                }
                .padding(.vertical, geometry.size.height * 0.04)
            }
        }
    }
    
    private func createDateFormatter() -> DateFormatter {
        let dateformatter = DateFormatter()
        dateformatter.dateFormat = "HH:mm"
        return dateformatter
    }
    
    private func getHoursAndMinsFromDate(from: Date) -> (Int, Int) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH"
        let hour = Int(dateFormatter.string(from: from))
        dateFormatter.dateFormat = "mm"
        let mins = Int(dateFormatter.string(from: from))
        return (hour ?? 16, mins ?? 0)
    }
    
    private func createDateFromString(dateString: String) -> Date {
        let dateFormatter = createDateFormatter()
        return dateFormatter.date(from: dateString) ?? Date()
    }
    
    private func createStringFromDate(date: Date) -> String {
        let dateFormatter = createDateFormatter()
        return dateFormatter.string(from: date)
    }
    
    private func setNotificationTime() {
        let notify = NotificationHandler()
        notify.cancelAllNotifications()
        let time = getHoursAndMinsFromDate(from: notificationTime)
        UserDefaults.standard.setValue(time.0, forKey: "NotificationHour")
        UserDefaults.standard.setValue(time.1, forKey: "NotificationMins")
        notify.scheduleDailyNotification(title: "该记账咯", body: "快来记录一下今天的开销吧", hour: time.0, minute: time.1)
    }
    
    private func NotificationForAllow() {
        let time = createStringFromDate(date: notificationTime)
        let notify = NotificationHandler()
        notify.sendNotification(title: "记账提醒开启", body: "CashFlow会每天\(time)提醒您哦", uuid: UUID().uuidString, timeInterval: 5)
    }
    
    private func RemoveAllNotifications() {
        let notify = NotificationHandler()
        notify.cancelAllNotifications()
        UserDefaults.standard.setValue(false, forKey: "UseNotification")
        useNotification = false
    }
    
    private func ToggleUseNotification(to newValue: Bool) {
        UserDefaults.standard.setValue(newValue, forKey: "UseNotification")
        // print("点击Toggle按钮")
        if !newValue {
            self.RemoveAllNotifications()
        }
        let useNotification = UserDefaults.standard.bool(forKey: "UseNotification")
        let hasNotification = UserDefaults.standard.bool(forKey: "HasNotification")
        if useNotification && hasNotification {
            NotificationForAllow()
            setNotificationTime()
        }
    }
}

#Preview {
    SettingsView()
}
