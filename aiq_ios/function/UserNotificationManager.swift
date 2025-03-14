
// UserNotificationManager.swift
// BluetoothService
//
// Created by 우리시스템 MAC on 2020/04/28
//  Copyright © 2020 Facebook. All rights reserved.
//

import UserNotifications

struct Notification {
    var id: String
    var title: String
    var message: String
    var icon: BluetoothServiceIconType?
}

class UserNotificationManager {
    static let shared = UserNotificationManager()
  
    let notifyOpenDoor = BooleanToggleForTimeout(timeout: 300.0)
    let notifyParking = BooleanToggleForTimeout(timeout: 300.0)
  
    public init() {}
  
    var notifications = ThreadSafeQueue<Notification>()
  
    func requestPermission() {
        UNUserNotificationCenter
            .current()
            .requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
                if granted == true, error == nil {
                    // We have permission!
                    print("UserNotification granted")
                } else {
                    print("User reject UserNotification")
                }
            }
    }
  
    func addNotification(id: String, title: String, message: String, icon: BluetoothServiceIconType) {
        if !UserDataSingleton.shared.notification { return }
        if id == "Onepass" {
            if notifyOpenDoor.isFlagActive {
                return
            }
            notifyOpenDoor.activateFlag()
        }
        if id == "Parking" {
            if notifyParking.isFlagActive {
                return
            }
            notifyParking.activateFlag()
        }
    
        notifications.enqueue(Notification(id: "TheSharpAiQHome-\(id)", title: title, message: message, icon: icon))
    }
  
    func schedule() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            switch settings.authorizationStatus {
                case .notDetermined:
                    self.requestPermission()
                case .authorized, .provisional:
                    self.scheduleNotifications()
                default:
                    break
            }
        }
    }
  
    func scheduleNotifications() {
        while let notification = notifications.dequeue() {
            let content = UNMutableNotificationContent()
            content.title = notification.title
            content.body = notification.message
            content.sound = UNNotificationSound.default
            if let iconName = notification.icon?.rawValue {
                if let iconUrl = Bundle.main.url(forResource: iconName, withExtension: "png") {
                    let attachment = try! UNNotificationAttachment(identifier: iconName, url: iconUrl, options: .none)
                    content.attachments = [attachment]
                } else {
                    print("UserNotification icon load fail.\(iconName)")
                }
            }
      
            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
            let request = UNNotificationRequest(identifier: notification.id, content: content, trigger: trigger)
      
            UNUserNotificationCenter.current().add(request) { error in
                guard error == nil else {
                    return
                }
                print("Scheduling notification with id: \(notification.id)")
            }
        }
    }
  
    func resetNotifyFlag() {
        notifyOpenDoor.cancelTimer()
        notifyParking.cancelTimer()
    }
}
