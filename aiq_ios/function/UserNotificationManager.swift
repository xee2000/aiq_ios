
// UserNotificationManager.swift
// BluetoothService
//
// Created by 우리시스템 MAC on 2020/04/28
//  Copyright © 2020 Facebook. All rights reserved.
//

import UserNotifications

struct Notification {
    var type: UserNotificationType
    var title: String
    var message: String
    var icon: BluetoothServiceIconType?
}

class UserNotificationManager {
    let TAG: String = "UserNotificationManager --"
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
  
    func addNotification(type: UserNotificationType, title: String, message: String, icon: BluetoothServiceIconType) {
        if type == .Onepass {
            if notifyOpenDoor.isFlagActive || !UserDataSingleton.shared.onepassNotification {
                return
            }
            notifyOpenDoor.activateFlag()
        } else if type == .Parking {
            if notifyParking.isFlagActive || !UserDataSingleton.shared.onepassNotification {
                return
            }
            notifyParking.activateFlag()
        }
      
        notifications.enqueue(Notification(type: type, title: title, message: message, icon: icon))
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
            let notifyId = "TheSharpAiQHome-\(notification.type.rawValue)"
        
            let content = UNMutableNotificationContent()
            content.title = notification.title
            content.body = notification.message
            if notification.type != .Doorphone {
                content.sound = UNNotificationSound.default
            }
        
            if let iconName = notification.icon?.rawValue {
                if let iconUrl = Bundle.main.url(forResource: iconName, withExtension: "png") {
                    let attachment = try! UNNotificationAttachment(identifier: iconName, url: iconUrl, options: .none)
                    content.attachments = [attachment]
                } else {
                    DebugLog.log(TAG, items: "UserNotification icon load fail.\(iconName)")
                }
            }
        
            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
            let request = UNNotificationRequest(identifier: notifyId, content: content, trigger: trigger)
        
            UNUserNotificationCenter.current().add(request) { error in
                guard error == nil else {
                    return
                }
                DebugLog.log(self.TAG, items: "Scheduling notification with id: \(notifyId)")
            }
        
            if notification.type == .Doorphone {
                // 안면인식 도어폰의 스마트 인증 완료 알림의 경우 일정 시간((2초)이 지난 후 취소
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    UNUserNotificationCenter.current().removeDeliveredNotifications(withIdentifiers: [notifyId])
                }
            }
        }
    }
  
    func resetNotifyFlag() {
        notifyOpenDoor.cancelTimer()
        notifyParking.cancelTimer()
    }
}
