import CoreBluetooth
import CoreLocation
import CoreMotion
import Foundation

class BeaconService: NSObject, ObservableObject, CLLocationManagerDelegate, CBCentralManagerDelegate, CBPeripheralDelegate {
    let TAG: String = "PSJ_BluetoothService --"
    let AIQBEACON: String = "AiQBeacon"

    var CVA: Double = 0

    // 현재 CVA값
    var NextValue: Double = 0

    // 이전 CVA값
    var PreValue: Double = 0

    // 기본 디폴트 PreValue - NextValue 절대값
    let DefaltAbsValue: Double = 0.2

    // accelomtor 실제 값
    var data_x = 0.0
    var data_y = 0.0
    var data_z = 0.0

    var data_x2 = 0.0
    var data_y2 = 0.0
    var data_z2 = 0.0

    // Gyro 실제 값
    var data_roll = 0.0
    var data_pitch = 0.0
    var data_yaw = 0.0

    // Gyro 값 생길때마다 최대 2까지 증가시킬 것
    var gycount: Int = 0

    // KalmanFilter Gyro 값
    var kal_Roll: Double = 0.0
    var kal_Pitch: Double = 0.0
    var kal_Yaw: Double = 0.0

    var LIMIT_MAX: Double = 0.5
    var LIMIT_MIN: Double = -0.5

    var accel_count: Int = 0
    var gyro_count: Int = 0

    // 절대값을 구하기 위한 현재 Sensor Value
    var CurrentRoll: Double = 0
    var CurrentPitch: Double = 0
    var CurrentYaw: Double = 0

    var RollResultCount: Int = 0
    var PitchResultCount: Int = 0
    var YawResultCount: Int = 0

    var PreRollCount: Int = 0
    var PrePitchCount: Int = 0
    var PreYawCount: Int = 0

    var Pre_1_Check: Bool = false
    var Pre_2_Check: Bool = false
    var Pre_3_Check: Bool = false
    var Current_Check: Bool = false

    // Timer Count
    var counter = 0
    var AccelBeaconGet = 0
    var endCheckCount = 0
    var startCheckCount = 0
    var accelCount = 0
    var startTime: String = ""

    // Timer
    var gyroFetchTimer = Timer()
    var accelFetchTimer = Timer()
    var mainTimer = Timer()
    var endBeaconTimer = Timer()
    var startBeaconTimer = Timer()
    // var accelTimer = Timer()
//    var networkManager: NetworkManager?

    // 2025.01.09 by 이정호 부장
    var timer00: Timer? = nil
    var timer30: Timer? = nil
    // 2025.01.09 by 이정호 부장

    // 0325 추가 jhlee//
    var tenminuteTimer = Timer()
    // 0325 추가마무리 jhlee//

    var i: Int = 0
    var a: Int = 0
    var gyroSaveCount: Int = 0

    // SensorSeq
    var SensorSeq = 0
    var BeaconSeq = 0

    // MapVC data
    var carNumberData: String = ""
    var mapIdData: String = ""
    var lastParkingTimeData: String = ""
    var areaData: String = ""
    var xData: Double = 0
    var yData: Double = 0

    var parkingTime: String = ""

    // SignInVC data
    var userId: String = ""
    var dong: String = ""
    var ho: String = ""

    var ResultCount = 0
    var Result = ""

    // 출입 & 출차 CheckPermission
    var AccelBeaconPermission: Bool = false
    var StartBeaconCheck: Bool = false
    var gyroSaveFlag: Bool = false
    var counterFlag: Bool = false
    var sensorFlag: Bool = false
    var networkPerMission: Bool = false
    var useFlag: Bool = true
    var sendDataPermission: Bool = false
    var endBeaconTimerCheck: Bool = false
    var startBeaconTimerCheck: Bool = false
    var carDraftCheck: Bool = false // Gyro Condition Complete
    var carDraftStartCheck: Bool = true // Gyro Condition Start
    var carDraftRssiCheck: Bool = false // Gyro Condition Rssi
    var startServiceFlag_W: Bool = true

    var ROLLCOUNT: Int = 0
    var PICTHCOUNT: Int = 0
    var YAWCOUNT: Int = 0

    // accele 5로 나눌것
    var acceleDivision = 0

    var accelcount = 0

    // Minor 값중에 32768 넘는애들
    var ModifiMinor = 0

    var Result_location = 0

    // 날짜 및 시간
    let date = Date()
    let dateFormatter = DateFormatter()

    let motion = CMMotionManager()

    // Beacon Permission
    var beaconMajor1: Bool = false // 로비
    var beaconMajor2: Bool = false // 아파트 정문
    var beaconMajor3: Bool = false // 엘레베이터
    var beaconMajor6: Bool = false // 주차장 진입로

    var gyroRollArray: [Double] = []
    var gyroPitchArray: [Double] = []
    var gyroYawArray: [Double] = []

    var sensorXArray: [Double] = []
    var sensorYArray: [Double] = []
    var sensorZArray: [Double] = []
    // Array List
    var stopList = [Int]()

    var beaconEndMajor: Int = 0

    // 생성자들
    let b: Beacon = .init()
    let s: Sensor = .init()
    let g: Gyro = .init()
    let acb: AccelBeacon = .init()
    let acbc: AccelBeaconChange = .init()
    let accelDataC: AccelData = .init()
    let networkManager: NetworkManager = .init()
    let queue = QueueData()
    let Accel = AccelResultData()

    // Sensor data 수집하는데 나중에 서버로 보내는 작업을 할 때 어떤 사용자가 사용했는지 식별하기 위해서 전화번호가 필요함
    var collectSensor: CollectSensor!

    // KalmanFilter 자동차 움직임을 측정하기 위한 필터
    var KalRoll = KalFilter()
    var KalPitch = KalFilter()
    var KalYaw = KalFilter()

    // Queue 생성자 (Accel queue 초기화)
    var RollQ = QueueData.Queue<Double>()
    var PitchQ = QueueData.Queue<Double>()
    var YawQ = QueueData.Queue<Double>()

    var StopQ = QueueData.Queue<Int>()
    var AccelQ = QueueData.Queue<String>()

    var locationManager: CLLocationManager!

    // Add by Sun,Kim 2022.11.14
    // BluetoothService Usage
    var beaconUUID: UUID!
    var beaconRegion: CLBeaconRegion!
    var beaconServiceUsageType = [BluetoothServiceUsageType]()

    // For Beacon Test
    var isRunScan: Bool = false
    var isSendBeaconToJS: Bool = false
    var isRestartCheck: Bool = false
    var latestRunTime: Date = .init()

    // For DoorPhone Smart Certification ----------------------------------------------------------
    var centralManager: CBCentralManager!
    // 현재 연경을 시도하고 있는 BLE Peripheral
    var pendingPeripheral: CBPeripheral?
    // 연결에 성공한 기기
    var connectedPeripheral: CBPeripheral?
    // 데이터를 보내기 위한 characteristic
    weak var writeCharacteristic: CBCharacteristic?
    // 데이터를 주변기기에 보내는 type을 설정. withResponse는 데이터를 보내면 이에 대한 답장이 오는 경우. withoutResponse는 반대로 데이터를 보내도 답장이 오지 않는 경우.
    private var writeType: CBCharacteristicWriteType = .withoutResponse
    // Bluetooth 기기와 성공적으로 연결되었고, 통신이 가능한 상태라면 return true
    var bluetoothIsReady: Bool {
        return centralManager.state == .poweredOn && connectedPeripheral != nil && writeCharacteristic != nil
    }

    // 컨넥션한 도어폰의 Protocol
    var doorphoneProtocol: DoorphoneProtocol?
    // 안면인식 도어폰의 Bluetooth UUID
    let BLE_DOORPHONE_BLUETOOTH_UID = CBUUID(string: "0000F1AE-0000-1000-8000-00805F9B34FB")
    let BLE_DOORPHONE_SERVICE_UUID = CBUUID(string: "ED2B4E3A-2820-492F-9507-DF165285E831")
    let BLE_READ_CHARACTERISTIC_UUID = CBUUID(string: "ED2B4E3C-2820-492F-9507-DF165285E831")
    let BLE_WRITE_CHARACTERISTIC_UUID = CBUUID(string: "ED2B4E3B-2820-492F-9507-DF165285E831")

    override init() {
        super.init()
        collectSensor = CollectSensor(phoneInfo: "1234")
    }

    @objc
    func StartBluetoothService() {
        DispatchQueue.main.async {
            if self.isRunScan {
                self.CancelBluetoothService()
            }
//            RestApi.shared.Loading()
//            self.networkManager = NetworkManager()
            // 0325 jhlee 사용자가 접속한 단지의 UUID를 가져오기 위한 코드 추가
            let storedUUIDString = UserDefaults.standard.string(forKey: "UUID") ?? ""
            // 0325 jhlee 사용자가 접속한 단지의 UUID를 가져오기 위한 코드 추가
            self.setupUserData()

            self.beaconUUID = UUID(uuidString: storedUUIDString) ?? self.beaconUUID
            if #available(iOS 13.0, *) {
                let beaconIdentityConstraint = CLBeaconIdentityConstraint(uuid: self.beaconUUID)
                self.beaconRegion = .init(beaconIdentityConstraint: beaconIdentityConstraint, identifier: self.AIQBEACON)
                self.beaconRegion = CLBeaconRegion(uuid: self.beaconUUID, identifier: self.AIQBEACON)
            } else {
                self.beaconRegion = CLBeaconRegion(proximityUUID: self.beaconUUID, identifier: self.AIQBEACON)
            }

            self.locationManager = CLLocationManager() // LocationManager 초기화
            self.locationManager.delegate = self // delegate 넣어줌

            self.locationManager.requestAlwaysAuthorization() // 위치 권한 받아옴.
            self.locationManager.requestWhenInUseAuthorization() // 백그라운드에서 위치를 체크할 것인지에 대한 권한.
            self.locationManager.desiredAccuracy = kCLLocationAccuracyKilometer // 위치 정확도를 낮추어 배터리 사용량을 줄임.

            self.locationManager.startUpdatingLocation() // 위치 Update 시작
            self.beaconRegion.notifyEntryStateOnDisplay = true
            self.beaconRegion.notifyOnEntry = true
            self.beaconRegion.notifyOnExit = true

            // 백그라운드에서 위치를 체크할 것인지에 대한 여부. 필요없으면 false로 처리하자
            self.locationManager.allowsBackgroundLocationUpdates = true

            // 해당 옵션을 false로 설정하지 않으면 15분 후 위치 업데이트가 종료됨!!!
            self.locationManager.pausesLocationUpdatesAutomatically = false

            self.locationManager.startMonitoring(for: self.beaconRegion)
            if #available(iOS 13.0, *) {
                let beaconIdentityConstraint = CLBeaconIdentityConstraint(uuid: self.beaconUUID)
                self.locationManager.startRangingBeacons(satisfying: beaconIdentityConstraint)
            } else {
                self.locationManager.startRangingBeacons(in: self.beaconRegion)
            }

            // FOR DoorPhone Smart Certification --------------------------------------------------
            if self.beaconServiceUsageType.contains(.BLE_DOORPHONE) {
                self.centralManager = CBCentralManager(delegate: self, queue: nil, options: [CBCentralManagerOptionRestoreIdentifierKey: "com.poscoict.thesharpiotapp"])
                // Sleep 50ms
                Thread.sleep(forTimeInterval: 0.05)

                if [.poweredOn, .unknown].contains(self.centralManager.state) {
                    self.centralManager.scanForPeripherals(withServices: [self.BLE_DOORPHONE_BLUETOOTH_UID], options: [CBCentralManagerScanOptionAllowDuplicatesKey: true])
                    DebugLog.log(self.TAG, items: "-------- started ble scanForPeripherals")

                    let peripherals = self.centralManager.retrieveConnectedPeripherals(withServices: [self.BLE_DOORPHONE_BLUETOOTH_UID])
                    for peripheral in peripherals {
                        self.centralManager.cancelPeripheralConnection(peripheral)
                        DebugLog.log(self.TAG, items: "-------- disconnected retrieved peripheral \(String(describing: peripheral.name))")
                    }
                } else {
                    DebugLog.log(self.TAG, items: "-------- started fail scanForPeripherals(Bluetooth not ON), \(self.centralManager.state)")
                }
            }

            // Notification
            if UserDataSingleton.shared.onepassNotification {
                let userNotificationManager = UserNotificationManager.shared
                var serviceName = ""

                if self.beaconServiceUsageType.contains(.BLE_ONPASS), self.beaconServiceUsageType.contains(.BLE_PARKING), self.beaconServiceUsageType.contains(.BLE_DOORPHONE) {
                    serviceName = "공동현관 자동 문열림/스마트 주차 위치 인식/도어폰 스마트 인증"
                } else if self.beaconServiceUsageType.contains(.BLE_ONPASS), self.beaconServiceUsageType.contains(.BLE_PARKING) {
                    serviceName = "공동현관 자동 문열림/스마트 주차 위치 인식"
                } else if self.beaconServiceUsageType.contains(.BLE_PARKING), self.beaconServiceUsageType.contains(.BLE_DOORPHONE) {
                    serviceName = "주차 위치 인식/도어폰 스마트 인증"
                } else if self.beaconServiceUsageType.contains(.BLE_ONPASS), self.beaconServiceUsageType.contains(.BLE_DOORPHONE) {
                    serviceName = "공동현관 자동 문열림/도어폰 스마트 인증"
                } else if self.beaconServiceUsageType.contains(.BLE_ONPASS) {
                    serviceName = "공동현관 자동 문열림"
                } else if self.beaconServiceUsageType.contains(.BLE_PARKING) {
                    serviceName = "스마트 주차 위치"
                } else if self.beaconServiceUsageType.contains(.BLE_DOORPHONE) {
                    serviceName = "도어폰 스마트 인증"
                }
                if serviceName == "" {
                    userNotificationManager.addNotification(type: .Init, title: "[더샵AiQ홈]", message: "비콘 서비스 타입 오류 입니다.", icon: .ic_parking)
                } else {
                    userNotificationManager.addNotification(type: .Init, title: "[더샵AiQ홈]\(serviceName)", message: "\(serviceName)을 시작합니다.\n앱이 자동으로 시작된 경우 알림을 터치하여 주세요!", icon: .ic_parking)
                }
                userNotificationManager.schedule()
            }

            // Service Live Notify
            if UserDataSingleton.shared.serviceLiveNotify {
                self.startTimer00()
                self.startTimer30()
            }

            self.isRunScan = true
            self.latestRunTime = Date()
            DebugLog.log(self.TAG, items: "***********(beacon service start)*************")
        }
    }

    @objc func CancelBluetoothService() {
        DispatchQueue.main.async {
            if self.beaconRegion != nil {
                if #available(iOS 13.0, *) {
                    let beaconIdentityConstraint = CLBeaconIdentityConstraint(uuid: self.beaconUUID)
                    self.locationManager.stopRangingBeacons(satisfying: beaconIdentityConstraint)
                } else {
                    self.locationManager.stopRangingBeacons(in: self.beaconRegion)
                }

                self.locationManager.showsBackgroundLocationIndicator = false
                self.locationManager.stopMonitoring(for: self.beaconRegion)
                self.beaconRegion = nil
            }
            self.locationManager = nil

            self.gyroFetchTimer.invalidate()
            self.accelFetchTimer.invalidate()

            if self.beaconServiceUsageType.contains(.BLE_DOORPHONE) {
                self.resetCentral()
                self.centralManager?.stopScan()
                print("\(Date()) \(self.TAG) -------- stoped ble scan")
            }
        }

        if UserDataSingleton.shared.serviceLiveNotify {
            timer00?.invalidate()
            timer00 = nil
            DebugLog.log(TAG, items: "----------------- 24 Hour ServiceLiveNotify STOP!!")
            timer30?.invalidate()
            timer30 = nil
            DebugLog.log(TAG, items: "----------------- 30 Minute ServiceLiveNotify STOP!!")
        }

        isRunScan = false
        DebugLog.log(TAG, items: "***********(beacon service end)*************")
        //    }
    }

    func RestartBeaconMonitoring(_ forced: Bool) {
        if !isRunScan || beaconRegion == nil || locationManager == nil {
            DebugLog.log(TAG, items: "-------- return fail: initialized variable not corrected")
            return
        }
        // 마지막 실행 시간 이후 1시간이 지나지 않았을 경우 다시 시작하지 않음
        if !forced {
            let current = Date()
            let minutes = (current.timeIntervalSince1970 - latestRunTime.timeIntervalSince1970) / 60
            if minutes < 60 {
                DebugLog.log(TAG, items: "-------- restartMonitoring fail: less than an hour has passed since the last run \(minutes)")
                return
            }
        }

        DispatchQueue.main.async {
            // Stop Current Scan Monitoring
            if self.beaconRegion != nil {
                if #available(iOS 13.0, *) {
                    let beaconIdentityConstraint = CLBeaconIdentityConstraint(uuid: self.beaconUUID)
                    self.locationManager.stopRangingBeacons(satisfying: beaconIdentityConstraint)
                } else {
                    self.locationManager.stopRangingBeacons(in: self.beaconRegion)
                }

                self.locationManager.showsBackgroundLocationIndicator = false
                self.locationManager.stopMonitoring(for: self.beaconRegion)
            }

            if self.beaconServiceUsageType.contains(.BLE_DOORPHONE) {
                self.centralManager.stopScan()
            }

            DebugLog.log(self.TAG, items: "***********(beacon monitoring stop)*************")

            // Sleep 50ms
            Thread.sleep(forTimeInterval: 0.05)

            // Start Scan Monitoring
            let storedUUIDString = UserDefaults.standard.string(forKey: "UUID") ?? ""
            self.beaconUUID = UUID(uuidString: storedUUIDString) ?? self.beaconUUID
            if #available(iOS 13.0, *) {
                let beaconIdentityConstraint = CLBeaconIdentityConstraint(uuid: self.beaconUUID)
                self.beaconRegion = .init(beaconIdentityConstraint: beaconIdentityConstraint, identifier: self.AIQBEACON)
                self.beaconRegion = CLBeaconRegion(uuid: self.beaconUUID, identifier: self.AIQBEACON)
            } else {
                self.beaconRegion = CLBeaconRegion(proximityUUID: self.beaconUUID, identifier: self.AIQBEACON)
            }

            self.locationManager.startMonitoring(for: self.beaconRegion)
            if #available(iOS 13.0, *) {
                let beaconIdentityConstraint = CLBeaconIdentityConstraint(uuid: self.beaconUUID)
                self.locationManager.startRangingBeacons(satisfying: beaconIdentityConstraint)
            } else {
                self.locationManager.startRangingBeacons(in: self.beaconRegion)
            }

            // FOR DoorPhone Smart Certification --------------------------------------------------
            if self.beaconServiceUsageType.contains(.BLE_DOORPHONE) {
                if [.poweredOn, .unknown].contains(self.centralManager.state) {
                    self.centralManager.scanForPeripherals(withServices: [self.BLE_DOORPHONE_BLUETOOTH_UID], options: [CBCentralManagerScanOptionAllowDuplicatesKey: true])
                }
            }
            DebugLog.log(self.TAG, items: "***********(beacon monitoring restart)*************")
        }

        latestRunTime = Date()
    }

    func ChangeAuthorization(_ accessToken: String) {
        DebugLog.log(TAG, items: "ChangeAuthorization() - Change AccessToken: \(accessToken)")
        UserDataSingleton.shared.authorization = accessToken
    }

    // 0325 jhlee 단독앱인경우 해당 함수가 의미가 없다 판단되어 주석처리 진행
//    func IsRunningSevice(_ resolve: RCTPromiseResolveBlock, rejecter reject: RCTPromiseRejectBlock) {
//        if locationManager == nil {
//            resolve(["result", false])
//            return
//        }
//
//        let aiqBeacon = locationManager.monitoredRegions.filter {
//            $0.identifier == self.AIQBEACON
//        }
//        //        DebugLog.log(TAG, items: "IsRunningService: \(isRunScan), \(aiqBeacon.count)")
//        resolve(["result": isRunScan && aiqBeacon.count > 0])
//    }

//    @objc(IsRunningService:rejecter:)
//    func IsRunningSevice(_ resolve: RCTPromiseResolveBlock, rejecter reject: RCTPromiseRejectBlock) {
//      if locationManager == nil {
//        resolve(["result", false])
//        return
//      }
//
//      let aiqBeacon = locationManager.monitoredRegions.filter {
//        $0.identifier == self.AIQBEACON
//      }
//      DebugLog.log(self.TAG, items: "IsRunningService: \(isRunScan), \(aiqBeacon.count)")
//      resolve(["result": isRunScan && aiqBeacon.count > 0])
//    }

    // -------------------------------------------------------------------------------------
//    @objc(SendDetectBeaconToJS:)
//    func SendDetectBeaconToJS(_ value: Bool) {
//      DebugLog.log(self.TAG, items: "SendDetectBeaconToJS: \(value)")
//      isSendBeaconToJS = value
//    }
//
//    // --------------------------------------------------------------------------------------
//    @objc(OnepassNotification:)
//    func OnepassNotification(_ value: Bool) {
//      DebugLog.log(self.TAG, items: "OnepassNotification: \(value)")
//      UserDataSingleton.shared.onepassNotification = value
//    }
//
//    // --------------------------------------------------------------------------------------
//    @objc(BleDoorphoneNotification:)
//    func BleDoorphoneNotification(_ value: Bool) {
//      DebugLog.log(self.TAG, items: "BleDoorphoneNotification: \(value)")
//      UserDataSingleton.shared.bleDoorphoneNotification = value
//    }
    // 0325 jhlee 단독앱인경우 해당 함수가 의미가 없다 판단되어 주석처리 진행

    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        DebugLog.log(TAG, items: "didChangeAuthorization -> \(status)")
        //  if status == .authorizedAlways || status == .authorizedWhenInUse {
        //    DebugLog.log(self.TAG, items: "didChangeAuthorization -> .authorizedAlways")
        //    RestartBeaconMonitoring(true)
        //  } else {
        //    DebugLog.log(self.TAG, items: "didChangeAuthorization -> \(status)")
        //  }
    }

    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        // RestApi.sendErrorData(body: ["message": "didEnterRegion \(self.beaconUUID.uuidString)"])
//        print("\(Date()) \(TAG) didEnterRegion -> \(region.identifier)")
        if beaconRegion != nil {
            if #available(iOS 13.0, *) {
                let beaconIdentityConstraint = CLBeaconIdentityConstraint(uuid: self.beaconUUID)
                manager.stopRangingBeacons(satisfying: beaconIdentityConstraint)
                manager.startRangingBeacons(satisfying: beaconIdentityConstraint)

            } else {
                manager.stopRangingBeacons(in: beaconRegion)
                manager.startRangingBeacons(in: beaconRegion)
            }
            manager.showsBackgroundLocationIndicator = true
            DebugLog.log(TAG, items: "start ranging beacons...")
        }
    }

    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        // RestApi.sendErrorData(body: ["message": "didExitRegion"])
        DebugLog.log(TAG, items: "didExitRegion -> \(region.identifier)")
        if beaconRegion != nil {
            if #available(iOS 13.0, *) {
                let beaconIdentityConstraint = CLBeaconIdentityConstraint(uuid: self.beaconUUID)
                manager.stopRangingBeacons(satisfying: beaconIdentityConstraint)
            } else {
                manager.stopRangingBeacons(in: beaconRegion)
            }
            manager.showsBackgroundLocationIndicator = false
            DebugLog.log(TAG, items: "stop ranging beacons...")
            accelFetchTimer.invalidate()
            gyroFetchTimer.invalidate()

            // NotifyFlag들을 Reset함.
            UserNotificationManager.shared.resetNotifyFlag()
            collectSensor.sendGyroApi(count: 4444, completion: { _, _ in })
            // ParkingComplete ....
            serviceComplete()
            resetData()
        }
    }

    func locationManager(_ manager: CLLocationManager, didStartMonitoringFor region: CLRegion) {
        DebugLog.log(TAG, items: "didStartMonitoringFor, region: \(region.identifier)")
    }

    func locationManager(_ manager: CLLocationManager, didDetermineState state: CLRegionState, for region: CLRegion) {
        if state == .inside {
            DebugLog.log(TAG, items: "didDetermineState -> .inside, region: \(region.identifier)")
            if beaconRegion != nil {
                if #available(iOS 13.0, *) {
                    let beaconIdentityConstraint = CLBeaconIdentityConstraint(uuid: self.beaconUUID)
                    manager.stopRangingBeacons(satisfying: beaconIdentityConstraint)
                    manager.startRangingBeacons(satisfying: beaconIdentityConstraint)
                } else {
                    manager.stopRangingBeacons(in: beaconRegion)
                    manager.startRangingBeacons(in: beaconRegion)
                }
            }

            manager.showsBackgroundLocationIndicator = true
        } else if state == .outside {
            // RestApi.sendErrorData(body: ["message": "didDetermineState -> .outside, region: \(region.identifier)"])
            DebugLog.log(TAG, items: "didDetermineState -> .outside, region: \(region.identifier)")
            if beaconRegion != nil {
                if #available(iOS 13.0, *) {
                    let beaconIdentityConstraint = CLBeaconIdentityConstraint(uuid: self.beaconUUID)
                    manager.stopRangingBeacons(satisfying: beaconIdentityConstraint)
                } else {
                    manager.stopRangingBeacons(in: beaconRegion)
                }

                manager.showsBackgroundLocationIndicator = false
                gyroFetchTimer.invalidate()
                accelFetchTimer.invalidate()
                // NotifyFlag들을 Reset함.
                UserNotificationManager.shared.resetNotifyFlag()
            }
        } else if state == .unknown {
            DebugLog.log(TAG, items: "locationManager() - Now unknown of Region")
        }
    }

    func locationManager(_ manager: CLLocationManager, didRangeBeacons beacons: [CLBeacon], in region: CLBeaconRegion) {
//        RestApi.sendErrorData(body: ["message": "didRangeBeacons \(beacons.count)"])
        if beacons.count <= 0 {
            return
        }
        // 시작하는 서비스에 주치위치 인식 서비스가 포함되어 있을 경우 Timer 실행
        if beaconServiceUsageType.contains(.BLE_PARKING) {
            // 이동 주차 예상
            // if beacons.count >= 30 && carDraftCheck == true && carDraftStartCheck == true && carDraftRssiCheck == true && startServiceFlag_W == true {
            if beacons.count >= 1, startServiceFlag_W == true {
                startServiceFlag_W = false
                // carDraftCheck = false
                startSecond()
                // } else if carDraftCheck == true && carDraftStartCheck == false {
                //   carDraftCheck = false
            }
        }

        for i in 0 ..< beacons.count {
            // Beacon Data =====================================================
            var uuid: String!
            if #available(iOS 13.0, *) {
                uuid = beacons[i].uuid.uuidString
            } else {
                uuid = beacons[i].proximityUUID.uuidString
            }
            let major = Int(truncating: beacons[i].major)
            let minor = Int(truncating: beacons[i].minor)
            let rssi = beacons[i].rssi
            let distance = beacons[i].accuracy
            DebugLog.log(TAG, items: "Detect Beacon \(uuid ?? "unknown") \(String(format: "%04X", major)) \(String(format: "%04X", minor)) \(rssi) \(beacons[i].proximity) \(distance)")

            if rssi > -80 || rssi != 0 {
                carDraftRssiCheck = true
            } else {
                carDraftRssiCheck = false
            }

            // Check rssi (rssi가 0 인 경우는 비콘 범위 밖으로 나옴)
            if rssi == 0 {
                continue
            }

            // ---------------------------------------------------------------------------------
            func appFunctionAccel() {
                if AccelBeaconPermission == true && carDraftRssiCheck == true {
                    if minor > 32768 {
                        ModifiMinor = minor - 32768
                    } else {
                        ModifiMinor = minor
                    }

                    // hex 바꿀수 있는 데이터 형식으로 변환
                    var hexString = String(format: "%02X", ModifiMinor)

                    if hexString.count < 4 {
                        for _ in 0 ..< 4 - hexString.count {
                            let zeroString = "0"

                            hexString = zeroString + hexString
                        }
                    }

                    if acb.AccelBeaconDic["\(hexString)"] == nil {
                        let accelData = AccelData()
                        accelData.id = "\(hexString)"
                        accelData.rssi = "\(rssi)"
                        accelData.delay = "\(counter)"
                        accelData.count = "1"
                        updateDelayList(&accelData.delayList, newEntry: "\(rssi)_\(counter)")
                        // 0109 jhlee 수정진행 delayList추가
                        accelData.delayList.append("\(rssi)_\(counter)")
                        // 0109 jhlee 수정끝 delayList추가

                        acb.AccelBeaconDic["\(hexString)"] = accelData
                    } else {
                        var accelData = AccelData()

                        accelData = acb.AccelBeaconDic["\(hexString)"] as! AccelData

                        let value = Int(accelData.count)! + 1

                        if Int(accelData.rssi)! > beacons[i].rssi {
                            accelData.count = "\(value)"
                            updateDelayList(&accelData.delayList, newEntry: "\(accelData.rssi)_\(accelData.delay)")

                        } else {
                            // 그렇지 않을경우 rssi, delay, count만 업데이트
                            accelData.rssi = "\(beacons[i].rssi)"
                            accelData.delay = "\(counter)"
                            accelData.count = "\(value)"
                            updateDelayList(&accelData.delayList, newEntry: "\(accelData.rssi)_\(accelData.delay)")
                        }
                        acb.AccelBeaconDic["\(hexString)"] = accelData
                    }
                }
            }

            // ---------------------------------------------------------------------------------
            func updateDelayList(_ list: inout [String], newEntry: String) {
                let components = newEntry.split(separator: "_", maxSplits: 1)
                guard components.count == 2,
                      let newRssi = Double(components[0]),
                      let newDelay = Double(components[1])
                else {
                    list.append(newEntry)
                    list.sort { $0 < $1 } // 기본 문자열 비교 정렬
                    return
                }

                if let index = list.firstIndex(where: { entry in
                    // 기존 항목의 delay가 같은지 비교
                    let parts = entry.split(separator: "_", maxSplits: 1)
                    if parts.count == 2, let delay = Double(parts[1]) {
                        return delay == newDelay
                    }
                    return false
                }) {
                    // 동일 delay가 있으면 rssi를 비교 (더 높은 신호일 때만 교체)
                    let parts = list[index].split(separator: "_", maxSplits: 1)
                    if parts.count == 2, let storedRssi = Double(parts[0]), newRssi > storedRssi {
                        list[index] = newEntry
                    }
                } else {
                    // 동일 delay가 없으면 새 항목 추가
                    list.append(newEntry)
                }

                // delay 기준 오름차순 정렬 (delay가 Double 형식인 경우)
                list.sort { entry1, entry2 in
                    let parts1 = entry1.split(separator: "_", maxSplits: 1)
                    let parts2 = entry2.split(separator: "_", maxSplits: 1)
                    if let delay1 = Double(parts1[1]), let delay2 = Double(parts2[1]) {
                        return delay1 < delay2
                    }
                    return entry1 < entry2
                }
            }
            // 2025.02.21 수정 끝

            // ---------------------------------------------------------------------------------
            func appFunctionBeacon() {
                // 0인 값 제거하기 위해 추가
                if beacons[i].rssi == 0 {
                    return
                }

                // 주차가 된 상태(초록불 -> 빨간불)
                if minor > 32768 {
                    ModifiMinor = minor - 32768

                    // hex 바꿀수 있는 데이터 형식으로 변환
                    var hexString = String(format: "%02X", ModifiMinor)

                    if hexString.count < 4 {
                        for _ in 0 ..< 4 - hexString.count {
                            let zeroString = "0"

                            hexString = zeroString + hexString
                        }
                    }

                    BeaconSeq += 1

                    b.addBeaconDic(seq: "\(BeaconSeq)", id: "\(hexString)", state: "\(major)", rssi: "\(rssi)", delay: "\(counter)")
                    collectSensor.addBeacon(b: b)
                }
            }

            switch major {
            case 1:
                if beaconServiceUsageType.contains(.BLE_PARKING) {
                    // 기존의 outparking 판단이 잘못되어 있다고 판단하여 위치 조정 실시
                    // outparking 시 서버로 따로 API 통신 실시하지 않고 데이터 리셋만 진행
                    if beaconMajor3 == true, beaconMajor1 == false {
                        print("\(Date()) \(TAG) -------------outParking-------------")
                        resetData()
                    }

                    if endBeaconTimerCheck == true {
                        stopList.append(major)
                    }

                    if counterFlag == true {
//                        print("\(Date()) \(TAG) locationManager() - 전체 타이머 상태 1 : \(counterFlag) | \(startTime)")
                        if beaconMajor1 == false, beaconMajor3 == false {
                            RestApi.sendParkingGateInformation(major: major, minor: minor)

                            DebugLog.log(TAG, items: "locationManager() -일반주차 완료 1 majorNumber : \(major) / beacon권한 beaconMajor1 = \(beaconMajor1) : beaconMajor3 = \(beaconMajor3)")

                            // 6번, 2번 비컨이 없는 현장들이 존재하여 1, 3, 4, 5번 비컨들만으로 주차 위치 서버스를 제공해야 됨
                            // 6번에서 파싱하던 데이터들을 1번 비컨으로 변경
                            collectSensor.paringDate = "non-paring"
                            collectSensor.addParingState()

                            beaconMajor1 = true
                        }
                    }
                    if counterFlag == false {
                        DebugLog.log(TAG, items: "locationManager() - 전체 타이머 상태 2 : \(counterFlag) | \(startTime)")
                        if beaconMajor1 == false, beaconMajor3 == true {
                            collectSensor.sendGyroApi(count: major, completion: { _, _ in })

                            DebugLog.log(TAG, items: "locationManager() - 이동주차 시작 2 Beacon : \(major) / 권한 beaconMajor1 = \(beaconMajor1) : beaconMajor3 = \(beaconMajor3)")

                            beaconMajor1 = true
                            beaconMajor3 = false
                            startBeaconTimerCheck = true

                            // Android에서 Paring 상태에선 비컨을 잘 못받기 때문에 상태 확인하는 것인데 IOS에서는 사용 안해서 [non]으로 고정시켜서 보냄
                            collectSensor.paringDate = "non-paring"
                            collectSensor.inputDate = "move_" + startTime
                            collectSensor.addParingState()

                            // accelTimer.invalidate()
                            startBeaconTimer.invalidate()

                            // accelTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(accelTimerFunction), userInfo: nil, repeats: true)
                            startBeaconTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(startCheckFunction), userInfo: nil, repeats: true)
                        }
                    }
                }

                // Check Onepass Beacon
                if beaconServiceUsageType.contains(.BLE_ONPASS) {
                    // Open Lobby Beacon
                    RestApi.openlobby(uuid: uuid, major: major, minor: minor, rssi: rssi, distance: distance)
                }

            case 3:
                if beaconServiceUsageType.contains(.BLE_PARKING) {
                    DebugLog.log(TAG, items: "locationManager() - Time: \(startTime), Major: \(major), Minor: \(minor), RSSI: \(rssi)")
                    if endBeaconTimerCheck == true {
                        stopList.append(major)
                    }

                    StopQ.push(value: major)

                    if counterFlag == true {
                        DebugLog.log(TAG, items: "locationManager() - 전체 타이머 상태 3 : \(counterFlag)")
                        if beaconMajor1 == true, beaconMajor3 == false {
                            DebugLog.log(TAG, items: "locationManager() - 일반주차 완료 2 Beacon : \(major) / 권한 beaconMajor1 = \(beaconMajor1) : beaconMajor3 = \(beaconMajor3)")

                            // RestApi.sendParkingGateInformation(major: major, minor: minor, eventEmitter: self)

                            beaconMajor3 = true
                            endBeaconTimerCheck = true
                            endBeaconTimer.invalidate()
                            endBeaconTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(endCheckFunction), userInfo: nil, repeats: true)
                        }
                    }

                    if counterFlag == false {
                        DebugLog.log(TAG, items: "전체 타이머 상태 : \(counterFlag)")
                        if beaconMajor1 == false, beaconMajor3 == false {
                            DebugLog.log(TAG, items: "locationManager() - 이동주차 시작 1 Beacon : \(major) / 권한 beaconMajor1 = \(beaconMajor1) : beaconMajor3 = \(beaconMajor3)")

                            // RestApi.sendParkingGateInformation(major: major, minor: minor, eventEmitter: self)

                            // 시작전 타이머 종료(다시 시작 할꺼라)
                            // accelTimer.invalidate()

                            beaconMajor3 = true
                        }
                    }
                }

            case 4:
                if beaconServiceUsageType.contains(.BLE_PARKING) {
                    DebugLog.log(TAG, items: "locationManager() - Time: \(startTime), Major: \(major), Minor: \(minor), RSSI: \(rssi)")
                    appFunctionAccel()
                }

            case 5:
                if beaconServiceUsageType.contains(.BLE_PARKING) {
                    DebugLog.log(TAG, items: "locationManager() - Time: \(startTime), Major: \(major), Minor: \(minor), RSSI: \(rssi)")
                    appFunctionAccel()
                    appFunctionBeacon()
                }

            default:
                break
            }
        }
    }

    func resetData() {
        accelCount = 0
        counter = 0
        SensorSeq = 0
        BeaconSeq = 0

        // Gyro data 초기화
        PreRollCount = 0
        PrePitchCount = 0
        PreYawCount = 0
        RollResultCount = 0
        PitchResultCount = 0
        YawResultCount = 0
        gyroSaveCount = 0
        // Accel data 초기화
        PreValue = 0
        NextValue = 0
        ResultCount = 0

        // 기존의 구문을 이용하면 dic가 초기화되는게 아니라
        // 공백으로 dic가 채워지는 현상이 발생하여 dic 제거 함수로 변경
        b.BeaconDic.removeAll()
        s.SensorDic.removeAll()
        g.GyroDic.removeAll()
        acbc.AccelBeaconChangeDic.removeAll()
        // Add below line by JHLEE 2024.10.23
        acb.AccelBeaconDic.removeAll()

        // b.addBeaconDic(seq: "", id: "", state: "", rssi: "", delay: "")
        // s.addSensorDic(seq: "", state: "", delay: "")
        // g.addGyroDic(x: "", y: "", z: "", delay: "")
        // acbc.addAccelBeaconChangeDic(id: "", rssi: "", delay: "", count: "")

        // Dictionay 전부 초기화
        collectSensor.removeData()

        counterFlag = false
        sensorFlag = false
        AccelBeaconPermission = false

        beaconMajor1 = false
        beaconMajor3 = false
        beaconMajor2 = false
        beaconMajor6 = false

        startServiceFlag_W = true

        // 2025.02.28 jhlee gyroSaveCount 0으로 초기화 수정중
        gyroSaveCount = 0
        // 2025.02.28 jhlee gyroSaveCount 0으로 초기화 수정끝

        // Timer 종료
        mainTimer.invalidate()
//        accelTimer.invalidate()
    }

    @objc func timerFunction() {
        if counterFlag == true {
            if sensorFlag == false {
                sensorFlag = true
                // 자이로, 엑셀이 센서가 동작함
            }

            counter += 1
            isRestartCheck = true
            // 15분이 지나면 Beacon기능 제외 모든기능 정지 후 서버로 데이터 보냄
            if counter == 900 {
                collectSensor.paringDate = "IOS"

                collectSensor.addStartTime(startTime)
                collectSensor.addParingState()

                // create post request 서버로 보내는 작업

                collectSensor.sendGyroApi(count: 900, completion: { _, _ in })
                serviceComplete()
            }
        }

        accelTimerFunction()
    }

    @objc
    func startTimer00() {
        DispatchQueue.main.async {
            let now = Date()
            var calendar = Calendar.current
            calendar.timeZone = TimeZone.current
            let midnight = calendar.startOfDay(for: now).addingTimeInterval(86400) // 다음 자정

            let interval = midnight.timeIntervalSince(now)

            self.timer00?.invalidate()
            self.timer00 = nil
            // self.timer00 = Timer.scheduledTimer(timeInterval: interval, target: self, selector: #selector(self.executeTask24), userInfo: nil, repeats: false)
            self.timer00 = Timer.scheduledTimer(withTimeInterval: interval, repeats: false) { [weak self] _ in
                self?.executeTask24()
            }
            // RunLoop.main.add(timer00!, forMode: .common)
            DebugLog.log(self.TAG, items: "----------------- 24 Hour ServiceLiveNotify START!! \(interval)")
        }
    }

    @objc
    func startTimer30() {
        if !isRestartCheck {
            DispatchQueue.main.async {
                self.timer30?.invalidate()
                self.timer30 = nil
                // self.timer30 = Timer.scheduledTimer(timeInterval: 10, target: self, selector: #selector(self.executeTask30), userInfo: nil, repeats: true)

                self.timer30 = Timer.scheduledTimer(withTimeInterval: 1800, repeats: true) { [weak self] _ in
                    self?.executeTask30() // 30분마다 작동할 함수
                }
                // RunLoop.main.add(timer30!, forMode: .common)
                DebugLog.log(self.TAG, items: "----------------- 30 Minute ServiceLiveNotify START!!")
            }
        }
    }

    // 정각마다 실행 함수
    @objc
    private func executeTask24() {
        collectSensor.sendGyroApi(count: 2424, completion: { _, _ in })
    }

    // 30분마다 실행 함수
    @objc
    private func executeTask30() {
        collectSensor.sendGyroApi(count: 3030, completion: { _, _ in })
    }

    // 2025.01.09 by 수정끝 이정호 부장 자정마다 timer진행

    @objc func accelTimerFunction() {
        if counter % 3 == 0 {
            AccelBeaconPermission = true
        } else {
            AccelBeaconPermission = false
        }
        accelCount += 1

        // SensorSeq 증가
        SensorSeq += 1
//
//        if ResultCount < 3, ResultCount >= 0 {
//            Result = "T"
//        } else if ResultCount < 12, ResultCount >= 3 {
//            Result = "S"
//        } else {
//            Result = "W"
//        }

        // 이동주차 시작할 때 필요한 상태값 얻기
//        AccelResultData.instance.accRsult = Result
//        // 주차완료 할때 필요한 Queue저장 차에서 처음 내릴때 알기
//        if AccelQ.count == 0 {
//            AccelQ.push(value: Result)
//        } else {
//            AccelQ.push(value: Result)
//
//            let firstResult: String = AccelQ.pop()!
//            let scondResult: String = AccelQ.pop()!
        ////            if firstResult == "T", scondResult == "S" || scondResult == "W" {
        ////                AccelBeaconPermission = true
        ////            }
//            AccelQ.push(value: scondResult)
//        }

        if counterFlag == true {
            s.addSensorDic(seq: "\(SensorSeq)", state: "\(ResultCount)", delay: "\(counter)")
            collectSensor.addSensor(s: s)
        }

        accel_count = 0
        ResultCount = 0

        // 자이로에서 5가 넘었을시에도 해당됨
        if AccelBeaconPermission == true {
            AccelBeaconGet += 1
            // 3에서 10으로 수정 android와 동일한 값으로 처리
            if AccelBeaconGet == 10 {
                AccelBeaconGet = 0
                AccelBeaconPermission = false
            }
        }
        // JHLEE2수정끝///
    }

    @objc func endCheckFunction() {
        if endBeaconTimer.isValid == true {
            endCheckCount += 1

            if endCheckCount == 2 {
                endCheckCount = 0

                endBeaconTimer.invalidate()

                print("\(Date()) \(TAG) endCheckFunction() - stopList 갯수 : \(stopList.count)")

                if stopList.count != 0 {
                    beaconEndMajor = stopList.last!
                    print("\(Date()) \(TAG) endCheckFunction() - 마지막 stopList: \(beaconEndMajor)")

                    stopList.removeAll()
                    // stopList.remove(at: stopList.last!)

                    endBeaconTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(endCheckFunction), userInfo: nil, repeats: true)
                } else {
                    if beaconEndMajor == 3 {
                        collectSensor.sendGyroApi(count: 3333, completion: { _, _ in })
                        serviceComplete()
                    } else if beaconEndMajor == 1 {
                        print("\(Date()) \(TAG) endCheckFunction() - 종료 안하고 다시 로비로 나옴")
                        beaconMajor1 = false
                        beaconMajor3 = false
                    }
                }
            }
        }
    }

    @objc func startCheckFunction() {
        if startBeaconTimerCheck == true {
            startCheckCount += 1

            DebugLog.log(TAG, items: "startCheckFunction() - startCheckCount : \(startCheckCount)")

            if startCheckCount == 900 {
                // 다되면 타이머를 멈춰야 할까??
                resetData()

                // acellTimer.invalidate()
                startBeaconTimer.invalidate()

                beaconMajor1 = false
                beaconMajor3 = false
            }
        }
    }

    func serviceComplete() {
        for accelB in acb.AccelBeaconDic {
            var accelDataSend = AccelData()

            accelDataSend = accelB.value as! AccelData

            // 2.25.02.12 jhlee 수정진행 delayList 중복제거
            acbc.addAccelBeaconChangeDic(id: accelDataSend.id, rssi: accelDataSend.rssi, delay: accelDataSend.delay, count: accelDataSend.count, delayList: Array(Set(accelDataSend.delayList)))
            // 2.25.02.12 jhlee 수정진행 delayList 중복제거
            collectSensor.addAccelBeacon(abcb: acbc)
        }

        // create post request 서버로 보내는 작업

        if counter >= 10 {
            collectSensor.addStartTime(startTime)
//            collectSensor.RestApi(phoneInfo: "Test",
//                                  collectSensor: collectSensor,
//                                  errorcode: GlobalManager.shared.sharedValue)
//            { response, error in
//                if let response = response {
//                    print("API 호출 성공: \(response)")
//
//                    // 에러 파일이 존재하는 경우에만 ErrorApi 호출
//                    if JsonFileSave.isFileJsonExists() {
//                        self.collectSensor.ErrorApi(phoneInfo: "1234") { response, error in
//                            if let response = response {
//                                print("Error API 호출 성공: \(response)")
//                                JsonFileSave.deleteJson(filename: "file")
//                            } else if let error = error {
//                                print("Error API 호출 실패: \(error.localizedDescription)")
//                            }
//                        }
//                    } else {
//                        print("에러 파일이 존재하지 않습니다.")
//                    }
//                } else if let error = error {
//                    print("API 호출 실패: \(error.localizedDescription)")
//                    // 네트워크 오류 등으로 API 호출 실패 시, JSON 파일을 저장합니다.
//                    JsonFileSave.saveJson(filename: "file", jsonObject: self.collectSensor.collectDataDic, errorPointer: error.localizedDescription)
//                }
//            }

            let collectSensorInstance = CollectSensor(phoneInfo: "1234")
            BeaconServiceFore.ParkingComplete()
            RestApi.sendParkingComplete(collectSensor: collectSensorInstance) // ✅ OK!
            carDraftStartCheck = true // 자이로로 시작할 수 있도록 완료되면 초기화
            beaconMajor1 = false
            sendDataPermission = false

            resetData()
        }
    }

    func AccelStart() {
        // Make sure the accelerometer hardware is available.
        if motion.isAccelerometerAvailable {
            accelFetchTimer.invalidate()

            motion.accelerometerUpdateInterval = 1.0 / 15.0 // 초당 15회 발생
            motion.startAccelerometerUpdates()

            // 데이터로 무언가 수행하도록 타이머 구성
            accelFetchTimer = Timer(fire: Date(),
                                    interval: 1.0 / 15.0,
                                    repeats: true,
                                    block: { _ in
                                        // Get the accelerometer data.
                                        if let data = self.motion.accelerometerData {
                                            self.data_x = data.acceleration.x
                                            self.data_y = data.acceleration.y
                                            self.data_z = data.acceleration.z

                                            self.AccelTimerResult()
                                        }
                                    })
            // Add the timer to the current run loop.
            RunLoop.current.add(accelFetchTimer, forMode: RunLoop.Mode.default)
        }
    }

    func AccelTimerResult() {
        CVA = sqrt(data_x * data_x + data_y * data_y + data_z * data_z)

        if PreValue != 0 {
            NextValue = CVA

            let ABSValue: Double = abs(PreValue - NextValue)

            if ABSValue >= DefaltAbsValue {
                accel_count += 1
            }
            PreValue = NextValue
            ResultCount = accel_count
        } else {
            PreValue = CVA
        }
    }

    @objc func GyroStart() {
        if motion.isGyroAvailable {
            gyroFetchTimer.invalidate()
            motion.gyroUpdateInterval = 1.0 / 6.0
            motion.startGyroUpdates()

            // 타이머를 통해 gyroscope 데이터를 주기적으로 가져옴.
            gyroFetchTimer = Timer(fire: Date(),
                                   interval: 1.0 / 6.0,
                                   repeats: true,
                                   block: { _ in
                                       if let data = self.motion.gyroData {
                                           // 2. 각 축의 회전 속도 값을 배열에 추가
                                           self.gyroRollArray.append(data.rotationRate.x)
                                           self.gyroPitchArray.append(data.rotationRate.y)
                                           self.gyroYawArray.append(data.rotationRate.z)

                                           if self.gyroRollArray.count >= 6,
                                              self.gyroPitchArray.count >= 6,
                                              self.gyroYawArray.count >= 6
                                           {
                                               var cumulativeRoll = 0.0
                                               var cumulativePitch = 0.0
                                               var cumulativeYaw = 0.0
                                               var cumulativeRollAverage = 0.0
                                               var cumulativePitchAverage = 0.0
                                               var cumulativeYawAverage = 0.0
                                               // 4. 인접한 값 사이의 절대 차이를 계산하며 로그 출력
                                               // 변화량 계산이기 때문에 +2 -2 면 4인식으로 부호를 안보고 숫자자체로 계산할것
                                               // 근데 만일 2 에서 2 면 둘다 양수니까
                                               for i in 0 ..< self.gyroRollArray.count - 1 {
                                                   let diffRoll = abs(self.gyroRollArray[i + 1] - self.gyroRollArray[i])
                                                   let diffPitch = abs(self.gyroPitchArray[i + 1] - self.gyroPitchArray[i])
                                                   let diffYaw = abs(self.gyroYawArray[i + 1] - self.gyroYawArray[i])

                                                   cumulativeRoll += diffRoll
                                                   cumulativePitch += diffPitch
                                                   cumulativeYaw += diffYaw
                                               }

                                               cumulativeRollAverage = cumulativeRoll / Double(self.gyroRollArray.count - 1)
                                               cumulativePitchAverage = cumulativePitch / Double(self.gyroPitchArray.count - 1)
                                               cumulativeYawAverage = cumulativeYaw / Double(self.gyroYawArray.count - 1)
                                               GyroDataManager.shared.updateGyroData(
                                                   roll: cumulativeRollAverage,
                                                   pitch: cumulativePitchAverage,
                                                   yaw: cumulativeYawAverage
                                               )
                                               self.g.addGyroDic(x: String(format: "%.2f", cumulativeRollAverage),
                                                                 y: String(format: "%.2f", cumulativePitchAverage),
                                                                 z: String(format: "%.2f", cumulativeYawAverage),
                                                                 delay: "\(self.counter)")
                                               self.collectSensor.addGyro(g: self.g)

                                               self.gyroRollArray.removeAll()
                                               self.gyroPitchArray.removeAll()
                                               self.gyroYawArray.removeAll()
                                               cumulativeRoll = 0
                                               cumulativePitch = 0
                                               cumulativeYaw = 0
                                               cumulativeRollAverage = 0
                                               cumulativePitchAverage = 0
                                               cumulativeYawAverage = 0
                                           }
                                       }
                                   })
            RunLoop.current.add(gyroFetchTimer, forMode: RunLoop.Mode.default)
        }
    }

//    @objc func GyroSensorResult() {
//        let LimitPlus = 0.035
//        let LimitMinus = -0.035
//
//        if RollQ.count == 4 {
//            if !((RollQ.elements[0] < LimitPlus && RollQ.elements[0] > LimitMinus) || (RollQ.elements[1] < LimitPlus && RollQ.elements[1] > LimitMinus) || (RollQ.elements[2] < LimitPlus && RollQ.elements[2] > LimitMinus) || (RollQ.elements[3] < LimitPlus && RollQ.elements[3] > LimitMinus)) {
//                if useFlag {
//                    RollResultCount += 1
//                }
//            } else {
//                PreRollCount = RollResultCount
//                RollResultCount = 0
//            }
//
//            var _: Double = RollQ.pop()!
//            let SECONDR: Double = RollQ.pop()!
//            let THIRDR: Double = RollQ.pop()!
//            let FORTHR: Double = RollQ.pop()!
//            RollQ.push(value: SECONDR)
//            RollQ.push(value: THIRDR)
//            RollQ.push(value: FORTHR)
//            RollQ.push(value: kal_Roll)
//        } else {
//            RollQ.push(value: kal_Roll)
//        }
//
//        if PitchQ.count == 4 {
//            if !((PitchQ.elements[0] < LimitPlus && PitchQ.elements[0] > LimitMinus) || (PitchQ.elements[1] < LimitPlus && PitchQ.elements[1] > LimitMinus) || (PitchQ.elements[2] < LimitPlus && PitchQ.elements[2] > LimitMinus) || (PitchQ.elements[3] < LimitPlus && PitchQ.elements[3] > LimitMinus)) {
//                if useFlag {
//                    PitchResultCount += 1
//                }
//            } else {
//                PrePitchCount = PitchResultCount
//                PitchResultCount = 0
//            }
//
//            var _: Double = PitchQ.pop()!
//            let SECONDR: Double = PitchQ.pop()!
//            let THIRDR: Double = PitchQ.pop()!
//            let FORTHR: Double = PitchQ.pop()!
//
//            PitchQ.push(value: SECONDR)
//            PitchQ.push(value: THIRDR)
//            PitchQ.push(value: FORTHR)
//            PitchQ.push(value: kal_Pitch)
//        } else {
//            PitchQ.push(value: kal_Pitch)
//        }
//
//        if YawQ.count == 4 {
//            if !((YawQ.elements[0] < LimitPlus && YawQ.elements[0] > LimitMinus) || (YawQ.elements[1] < LimitPlus && YawQ.elements[1] > LimitMinus) || (YawQ.elements[2] < LimitPlus && YawQ.elements[2] > LimitMinus) || (YawQ.elements[3] < LimitPlus && YawQ.elements[3] > LimitMinus)) {
//                if useFlag {
//                    YawResultCount += 1
//                }
//            } else {
//                PreYawCount = YawResultCount
//                YawResultCount = 0
//            }
//
//            var _: Double = YawQ.pop()!
//            let SECONDR: Double = YawQ.pop()!
//            let THIRDR: Double = YawQ.pop()!
//            let FORTHR: Double = YawQ.pop()!
//
//            YawQ.push(value: SECONDR)
//            YawQ.push(value: THIRDR)
//            YawQ.push(value: FORTHR)
//            YawQ.push(value: kal_Yaw)
//        } else {
//            YawQ.push(value: kal_Yaw)
//        }
//
//        // 기존의 7값이 너무 타이트하게 잡혀서 운전 상태 판별이 잘 안됨
//        // 5로 조건을 완화함
//        print("after preRollCount : x", PreRollCount)
//        print("after PrePitchCount : y", PrePitchCount)
//        print("after PreYawCount : z", PreYawCount)
//        if PreRollCount >= 1 || PrePitchCount >= 1 || PreYawCount >= 1 {
//            carDraftCheck = true // Gyro Start 조건
//            gyroSaveFlag = true
//
//            gyroSaveCount += 1
//            counterFlag = true
//            print("z PreYawCount :", PreYawCount)
//            g.addGyroDic(x: "\(PreRollCount)", y: "\(PrePitchCount)", z: "\(PreYawCount)", delay: "\(counter)")
    ////            collectSensor.addGyro(g: g)
//            if startBeaconTimerCheck == true {
//                if AccelResultData.instance.accRsult == "T" {
//                    startBeaconTimerCheck = false
//                    startBeaconTimer.invalidate()
//                    startCheckCount = 0
//
//                    if carDraftStartCheck == false { // gyro 조건으로 스타트 중이라면 시작 안하게
//                        startSecond()
//                    }
//                }
//            }
//
//            // BackgroundTast 파일의 GyroSensorReult함수에 추가
//            print("if gyrosaveCount : ", gyroSaveCount)
//
//            if startServiceFlag_W == false, gyroSaveCount >= 5 {
//                // JHLEE2수정 - 2024.12.12 by Jungho Lee
//                AccelBeaconPermission = true
//
//                // 자이로로 인해서 5가 넘었을시 다시 10초동안 수집
//                AccelBeaconGet = 0
//                // JHLEE2수정끝
//                let username = UserDefaults.standard.string(forKey: "username") ?? ""
//                collectSensor.sendGyroApi(count: gyroSaveCount, userId: username) { success, error in
//                    if success {
//                        print("Gyro API 호출 성공")
//                    } else {
//                        if let error = error {
//                            print("Gyro API 호출 실패: \(error.localizedDescription)")
//                        } else {
//                            print("Gyro API 호출 실패: 알 수 없는 오류")
//                        }
//                    }
//                }
//            }
//
//            PreRollCount = 0
//            PrePitchCount = 0
//            PreYawCount = 0
//        } else {
//            gyroSaveFlag = false
//            // Gyro Start 조건
//            // carDraftCheck = false
//
//            if gyroSaveCount != 0, counterFlag == true {
//                if g.GyroDic.count != 0 {
//                    collectSensor.addGyro(g: g)
//                    g.GyroDic.removeAll()
//                }
//                gycount += 1
//
//                // 자이로 카운터가 2개 이상 일어날시 이전 일반 비컨값 제거
//                if gycount == 2 {
//                    collectSensor.removeAccelBeacon()
//                    gycount = 0
//                }
//                if gyroSaveCount > 5 {
//                    gyroSaveCount = 0
//                }
//            }
//        }
//
//        if useFlag == false {
//            PreRollCount = 0
//            PrePitchCount = 0
//            PreYawCount = 0
//        }
//
//        useFlag = true
//    }

    func startSecond() {
        // seq 값 초기화 안되는 현상이 있어 초기화 문구 추가
        SensorSeq = 0
        BeaconSeq = 0
        AccelBeaconPermission = true
        carDraftStartCheck = false
        counterFlag = true
        beaconMajor1 = false
        beaconMajor3 = false

        mainTimer.invalidate()
        // accelTimer.invalidate()
        mainTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(timerFunction), userInfo: nil, repeats: true)
        // accelTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(accelTimerFunction), userInfo: nil, repeats: true)

        AccelStart()
        GyroStart()
        let date = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        startTime = dateFormatter.string(from: date)

        DebugLog.log(TAG, items: "startSecond() - App Start 주차 시스템 시작 !!")

        // 2025.02.27 jhlee AccelStart 로그기록 수정중
        collectSensor.sendGyroApi(count: 12345, completion: { _, _ in })
        // 2025.02.27 jhlee AccelStart 로그기록 수정끝

        // 2025.03.25 jhlee 시작시 알림띄우기 위한 단독앱 포그라운드
        BeaconServiceFore.StartingService()
        // 2025.03.25 jhlee 시작시 알림띄우기 위한 단독앱 포그라운드 수정끝
    }

    func setupUserData() {
        // UserDataSingleton 에 사용자 Data 를 설정함.
        beaconServiceUsageType.removeAll()

        // UserDefaults에서 purpose 문자열 가져오기 (키 이름에 맞춰 수정)
        let purpose = UserDefaults.standard.string(forKey: "purpose") ?? ""
        switch purpose {
        case "parking":
            beaconServiceUsageType.append(.BLE_PARKING)
        case "doorphone":
            beaconServiceUsageType.append(.BLE_DOORPHONE)
        default:
            beaconServiceUsageType.append(.BLE_ONPASS)
        }
    }

    // CBCentralManagerDelegate 필수 메서드 구현
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch central.state {
        case .unknown:
            DebugLog.log(TAG, items: "centralManagerDidUpdateState: unknown")
        case .resetting:
            DebugLog.log(TAG, items: "centralManagerDidUpdateState: resetting")
        case .unsupported:
            DebugLog.log(TAG, items: "centralManagerDidUpdateState: unsupported")
        case .unauthorized:
            DebugLog.log(TAG, items: "centralManagerDidUpdateState: unauthorized")
        case .poweredOff:
            DebugLog.log(TAG, items: "centralManagerDidUpdateState: power OFF")
        case .poweredOn:
            DebugLog.log(TAG, items: "centralManagerDidUpdateState: power ON")
            if UserDataSingleton.shared.purpose.contains(.BLE_DOORPHONE) {
                guard central.isScanning == false else { return }
                startScan()
            }
            return
        @unknown default:
            fatalError()
        }

        if beaconServiceUsageType.contains(.BLE_DOORPHONE) {
            centralManager?.stopScan()
            DebugLog.log(TAG, items: "-------- stoped ble scan")
        }

        resetData()
    }

    func connectToPeripheral(_ peripheral: CBPeripheral) {
        // 연결 실패에 대비하여 현재 연결 중인 기기를 저장
        pendingPeripheral = peripheral
        centralManager?.connect(peripheral, options: nil)
    }

    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String: Any], rssi RSSI: NSNumber) {
        if peripheral.state != .disconnected {
            return
        }

        // Device의 Name을 가져옮(by 김성호, 2024.09.26) ------------>
        var advName = peripheral.name
        if advName == nil {
            advName = peripheral.identifier.uuidString
        }

        for data in advertisementData {
            if data.key == "kCBAdvDataLocalName" {
                advName = data.value as? String
            }
        }
        // <---------------------------------------------------------

        // 기기가 검색될 때 마다 필요한 코드를 작성
        if advName == UserDataSingleton.shared.advName {
            DebugLog.log(TAG, items: "centralManager(didDiscover) --------- \(peripheral.identifier)")
            // Connect to Doorphone
            connectToPeripheral(peripheral)
        }
    }

    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        DebugLog.log(TAG, items: "centralManager(didConnect) --------- \(peripheral.identifier)")

        // Stop scanning once we've connected
        centralManager.stopScan()
        DebugLog.log(TAG, items: "-------- ended ble scanForPeripherals")

        peripheral.delegate = self
        pendingPeripheral = nil
        connectedPeripheral = peripheral
        doorphoneProtocol = DoorphoneProtocol()

        // peripheral의 Service들을 검색
        peripheral.discoverServices([BLE_DOORPHONE_SERVICE_UUID])
    }

    func centralManager(_ cental: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: (any Error)?) {
        if let error = error {
            DebugLog.log(TAG, items: "centralManager(didDisconnectPeripheral) ERROR --------- \(error.localizedDescription)")
        }
        DebugLog.log(TAG, items: "centralManager(didDisconnectPeripheral) --------- \(peripheral.identifier)")

        // Reset the state and start scanning
        resetCentral()
        startScan()
    }

    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: (any Error)?) {
        // Fail Connection
        if let error = error {
            DebugLog.log(TAG, items: "centralManager(didFailToConnect) ERROR --------- \(error.localizedDescription)")
        }

        // Reset the state and start scanning again
        resetCentral()
        startScan()
    }

    func centralManager(_ central: CBCentralManager, willRestoreState dict: [String: Any]) {
        DebugLog.log(TAG, items: "centralManager(willRestoreState) ---------")

        let identifiyKey = dict[CBCentralManagerOptionRestoreIdentifierKey]
        if identifiyKey != nil {
            DebugLog.log(TAG, items: "centralManager(willRestoreState) --------- \(identifiyKey!)")
        }
    }

    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: (any Error)?) {
        if let error = error {
            DebugLog.log(TAG, items: "peripheral(didDiscoverServices) ERROR --------- \(error.localizedDescription)")
            cleanUp()
            return
        }

        DebugLog.log(TAG, items: "peripheral(didDiscoverServices) ---------")

        // 검색된 모든 service에 대해서 characteristic을 검색
        for service in peripheral.services! {
            if service.uuid == BLE_DOORPHONE_SERVICE_UUID {
                peripheral.discoverCharacteristics([BLE_READ_CHARACTERISTIC_UUID, BLE_WRITE_CHARACTERISTIC_UUID], for: service)
            }
        }
    }

    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: (any Error)?) {
        // Handle if any errors occurred
        if let error = error {
            DebugLog.log(TAG, items: "peripheral(didDiscoverCharacteristicsFor) ERROR --------- \(error.localizedDescription)")
            cleanUp()
            return
        }

        // 검색된 모든 characteristic에 대해 characteristicUUID를 체크하고 일치한다면 peripheral을 구독
        for charactristic in service.characteristics! {
            DebugLog.log(TAG, items: "peripheral(didDiscoverCharacteristicsFor) --------- \(charactristic.uuid)")

            if charactristic.uuid == BLE_READ_CHARACTERISTIC_UUID {
                // 해당 기기의 데이터를 구독
                if charactristic.properties.contains(.notify) {
                    peripheral.setNotifyValue(true, for: charactristic)
                }
            }
            if charactristic.uuid == BLE_WRITE_CHARACTERISTIC_UUID {
                writeCharacteristic = charactristic
                writeType = charactristic.properties.contains(.write) ? .withResponse : .withoutResponse
            }
        }
    }

    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor charactristic: CBCharacteristic, error: (any Error)?) {
        // Perform any error handling if one occurred
        if let error = error {
            DebugLog.log(TAG, items: "BLE DOOR received data ERROR --------- \(error.localizedDescription)")
            return
        }

        // 전송 받은 Data가 존재하는 지 Check
        let data = charactristic.value
        guard data != nil else { return }

        DebugLog.log(TAG, items: "BLE DOOR received data --------- \(data?.hexEncodedString() ?? "ERROR")")
        if doorphoneProtocol != nil {
            doorphoneProtocol!.fromByteCode(data?.bytes)
            if doorphoneProtocol!.command == .SECURE_KEY {
                // Write mID = Command('C') + username
                let sendMId = "C" + UserDataSingleton.shared.username
                let sendBytes = doorphoneProtocol!.getSendProtocol(sendMId)
                DebugLog.log(TAG, items: "BLE DOOR send data     --------- \(sendBytes?.hexEncodedString() ?? "ERROR")")
                sendBytesToDevice(sendBytes!)
            } else if doorphoneProtocol!.command == .SEND_COMMAND {
                let receivedData = doorphoneProtocol!.data
                if receivedData.isEmpty {
                    DebugLog.log(TAG, items: "BLE DOOR --------- Receive SUCCESS data")
                    if UserDataSingleton.shared.bleDoorphoneNotification {
                        // 사용자에게 스마트 인증 성공을 알림
                        UserNotificationManager.shared.addNotification(type: .Doorphone, title: "[더샵AiQ홈]안면인식 도어폰", message: "스마트 인증에 성공하였습니다.", icon: .ic_onepass)
                        UserNotificationManager.shared.schedule()
                    }
                } else {
                    DebugLog.log(TAG, items: "BLE DOOR --------- Receive ERROR data(\(receivedData))")
                }
                // Disconnect from peripheral
                // App에서 disconnect 하지 않더라도 Device(Doorphone)에서 Disconnect함.
                // centralManager.cancelPeripheralConnection(peripheral)
            }
        }
    }

    func sendBytesToDevice(_ bytes: [UInt8]) {
        guard bluetoothIsReady else { return }

        let data = Data(bytes: bytes, count: bytes.count)
        connectedPeripheral!.writeValue(data, for: writeCharacteristic!, type: writeType)
    }

    private func resetCentral() {
        pendingPeripheral = nil
        connectedPeripheral = nil
        writeCharacteristic = nil
        doorphoneProtocol = nil
    }

    private func startScan() {
        guard beaconServiceUsageType.contains(.BLE_DOORPHONE) else { return }
        guard let centralManager = centralManager, !centralManager.isScanning else { return }

        // Start scanning for a peripheral that matches out saved device
        centralManager.scanForPeripherals(withServices: [BLE_DOORPHONE_BLUETOOTH_UID], options: [CBCentralManagerScanOptionAllowDuplicatesKey: true])
        DebugLog.log(TAG, items: "-------- started ble scanForPeripherals")
    }

    fileprivate func cleanUp() {
        // Nothing to clean up if we haven't connected to a peripheral, or if the peripheral isn't connected
        guard let peripheral = connectedPeripheral, peripheral.state != .disconnected else { return }

        // Loop through all of the characteristics in each service,
        // and if any were configured to notify us, disconnect them
        peripheral.services?.forEach { service in
            service.characteristics?.forEach { characteristic in
                if characteristic.uuid != BLE_READ_CHARACTERISTIC_UUID { return }
                if characteristic.isNotifying {
                    peripheral.setNotifyValue(false, for: characteristic)
                }
            }
        }

        // Cancel the connection
        centralManager?.cancelPeripheralConnection(peripheral)
    }
}

extension Data {
    func hexEncodedString() -> String {
        return map {
            String(format: "%02hhx", $0)
        }.joined(separator: ", ")
    }
}
