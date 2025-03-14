import CoreBluetooth
import CoreLocation
import Foundation
import UserNotifications

class PermissionManager: NSObject, ObservableObject, CLLocationManagerDelegate, CBCentralManagerDelegate {
    private var locationManager: CLLocationManager?
    private var centralManager: CBCentralManager?

    override init() {
        super.init()
        // 위치 관리자 설정 (백그라운드에서도 동작하도록)
        locationManager = CLLocationManager()
        locationManager?.delegate = self
        locationManager?.allowsBackgroundLocationUpdates = true
        locationManager?.pausesLocationUpdatesAutomatically = false

        // 블루투스 관리자 설정 (초기화 시 권한 요청)
        centralManager = CBCentralManager(delegate: self, queue: nil, options: [CBCentralManagerOptionShowPowerAlertKey: true])
    }

    // 권한 요청 함수: 위치, 블루투스, 알림 권한 모두 요청
    func requestPermissions() {
        // 위치 권한 확인 및 요청 (이미 결정되지 않았다면)
        var locationStatus = CLLocationManager.authorizationStatus()
        if locationStatus == .notDetermined {
            print("Requesting location permission")
            locationManager?.requestWhenInUseAuthorization()
        } else {
            print("Location permission already determined: \(locationStatus.rawValue)")
        }

        // 블루투스 상태 확인 (요청은 CBCentralManager 초기화 시 시스템이 처리)
        if let central = centralManager {
            switch central.state {
            case .poweredOn:
                print("Bluetooth is already powered on")
            case .poweredOff, .unauthorized, .unsupported, .resetting, .unknown:
                print("Bluetooth is not enabled or not authorized. Current state: \(central.state)")
            @unknown default:
                print("Bluetooth state is unknown")
            }
        }

        // 알림 권한 요청
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if granted {
                print("Notification permission granted.")
            } else {
                print("Notification permission denied.")
            }
            if let error = error {
                print("Error requesting notification permission: \(error.localizedDescription)")
            }
        }
    }

    // MARK: - CBCentralManagerDelegate

    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch central.state {
        case .poweredOn:
            print("Bluetooth is powered on")
        case .poweredOff:
            print("Bluetooth is powered off")
        case .unsupported:
            print("Bluetooth is unsupported")
        case .unauthorized:
            print("Bluetooth is unauthorized")
        case .resetting:
            print("Bluetooth is resetting")
        case .unknown:
            print("Bluetooth state is unknown")
        @unknown default:
            print("A new state of Bluetooth is available")
        }
    }

    // MARK: - CLLocationManagerDelegate

    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        print("Location authorization status changed to: \(status.rawValue)")
    }
}
