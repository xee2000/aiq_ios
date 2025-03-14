import SwiftUI
import UserNotifications

@main
struct aiq_iosApp: App {
    // NotificationDelegate 인스턴스를 저장하는 프로퍼티 추가
    let notificationDelegate = NotificationDelegate()

    init() {
        // 저장된 notificationDelegate를 delegate로 설정
        UNUserNotificationCenter.current().delegate = notificationDelegate
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

class NotificationDelegate: NSObject, UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void)
    {
        completionHandler([.banner, .sound])
    }
}
