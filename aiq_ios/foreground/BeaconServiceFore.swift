import UserNotifications

enum BeaconServiceFore {
    static func StartingService() {
        let username = UserDefaults.standard.string(forKey: "username") ?? ""
        let dong = UserDefaults.standard.string(forKey: "dong") ?? ""
        let ho = UserDefaults.standard.string(forKey: "ho") ?? ""

        let content = UNMutableNotificationContent()
        content.title = "알림"
        content.body = "주차위치 서비스가 동작중에 있습니다."
        content.sound = UNNotificationSound.default

        // 1초 후 알림 트리거
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)

        let request = UNNotificationRequest(identifier: "beaconServiceNotification", content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("알림 스케줄 에러: \(error.localizedDescription)")
            } else {
                print("알림이 스케줄되었습니다.")
            }
        }
    }

    static func ParkingComplete() {
        let username = UserDefaults.standard.string(forKey: "username") ?? ""
        let dong = UserDefaults.standard.string(forKey: "dong") ?? ""
        let ho = UserDefaults.standard.string(forKey: "ho") ?? ""

        let content = UNMutableNotificationContent()
        content.title = "알림"
        content.body = username + "입주민님 주차를 완료하였습니다 주차위치를 확인해주세요."
        content.sound = UNNotificationSound.default

        // 1초 후 알림 트리거
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)

        let request = UNNotificationRequest(identifier: "beaconServiceNotification", content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("알림 스케줄 에러: \(error.localizedDescription)")
            } else {
                print("알림이 스케줄되었습니다.")
            }
        }
    }

    static func AppStarting() {
        let username = UserDefaults.standard.string(forKey: "username") ?? ""
        let dong = UserDefaults.standard.string(forKey: "dong") ?? ""
        let ho = UserDefaults.standard.string(forKey: "ho") ?? ""

        let content = UNMutableNotificationContent()
        content.title = "알림"
        content.body = username + "입주민님 앱이 실행되었습니다."
        content.sound = UNNotificationSound.default

        // 1초 후 알림 트리거
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)

        let request = UNNotificationRequest(identifier: "beaconServiceNotification", content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("알림 스케줄 에러: \(error.localizedDescription)")
            } else {
                print("알림이 스케줄되었습니다.")
            }
        }
    }
}
