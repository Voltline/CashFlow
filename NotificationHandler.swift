//
//  NotificationHandler.swift
//  AccountBook
//
//  Created by Voltline on 2024/6/30.
//

import UserNotifications

class NotificationHandler
{
    func sendNotification(title: String, body: String, uuid: String, timeInterval: Double = 5, isRepeat: Bool = false) {
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: timeInterval, repeats: isRepeat)
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = UNNotificationSound.default
        
        let request = UNNotificationRequest(identifier: uuid, content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request)
    }
    
    func cancelAllRepeatingNotifications() {
        let center = UNUserNotificationCenter.current()
        center.removeAllPendingNotificationRequests()
    }
}
