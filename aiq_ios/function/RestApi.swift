// RestApi.swift
// BluetoothService
//
// Created by 우리시스템 MAC on 2020/04/07
// Copyright © 2020 Facebook. All rights reserved.
//

import Network
import NotificationCenter

class RestApi: NSObject {
    static let TAG: String = "RestApi --"
    static let shared = RestApi()
    private static var pendingRestApiRequests: [URLRequest] = []

    private let monitor = NWPathMonitor()
    private let monitorQueue = DispatchQueue(label: "ApiQueue")
    
    static var isConnected: Bool = false
    override init() {}
    
    public func Loading() {
        monitor.pathUpdateHandler = { _ in
            if RestApi.isConnected {
                RestApi.sendPendingRestApiRequests()
            }
        }

        monitor.start(queue: monitorQueue)
    }

    static func openlobby(uuid: String, major: Int, minor: Int, rssi: Int, distance: Double) {
        let minorHex = String(format: "%04X", minor)
    
        let userData = UserDataSingleton.shared
        let onepassList = userData.onepassList
    
        for beacon in onepassList {
            if beacon.uuid == uuid && beacon.minor == minorHex && rssi >= beacon.rssi {
                // Check Detect Time
                DebugLog.log(TAG, items: "openLobby() - OPEN 요청: Major: \(major), Minor: \(minorHex), RSSI: \(rssi), Distance: \(distance)")
//                sendBeaconDetectSignal(beacon, rssi: rssi, distance: distance, eventEmitter: eventEmitter, isSendBeaconToJS: isSendBeaconToJS)
            }
        }
    }
  
    static func sendEventToJS(_ beacon: OnepassBeacon) {
//        if isSendToJS {
//            eventEmitter.sendEvent(withName: "onSendBeaconEvent", body: ["major": beacon.major, "minor": beacon.minor, "type": sendType, "elapsedTime": beacon.apiElapsedTime] as [String: Any])
//        }
    }
  
    static func sendBeaconDetectSignal(_ beacon: OnepassBeacon, rssi: Int, distance: Double) {
        // 최근에 OpenLobby API에 성공한 Beacon Signal이 일정 시간내에 있으면 다시 보내지 않음
        let now = Date()
        if beacon.lastDetectedAt > now {
            return
        }
    
        // Default로 다음에 보낼 시간을 미리 설정함.
        let userData = UserDataSingleton.shared
        beacon.lastDetectedAt = Date(timeIntervalSinceNow: Double(userData.ignoreInterval))
    
        // Send Time formatter
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm:ss.SSS"
    
        let body: [String: Any] = [
            "sid": beacon.sid,
            "major": beacon.major,
            "minor": beacon.minor,
            "rssi": rssi,
            "distance": distance,
            "sendTime": dateFormatter.string(from: Date())
        ]
    
        // API 경과 시간 시작
        let startTime = DispatchTime.now()
    
        // create post request 서버로 보내는 작업
        let userNotificationManager = UserNotificationManager.shared
        let request = makePlatformRequest(.DetectBeaconSignal, body: body)
    
//        sendEventToJS(beacon, eventEmitter: eventEmitter, isSendToJS: isSendBeaconToJS, sendType: "SendSignal")
    
        let task = URLSession.shared.dataTask(with: request) { data, _, error in
            guard let data = data, error == nil else {
                DebugLog.log(self.TAG, items: error?.localizedDescription ?? "No data")
        
                userNotificationManager.addNotification(type: .Onepass, title: "[더샵AiQ홈]공동현관 문열림", message: "플랫폼 서버에 연결할 수 없습니다.\n잠시 후 다시 시도해 보세요!", icon: .ic_onepass_error)
                userNotificationManager.schedule()
        
//                sendEventToJS(beacon, eventEmitter: eventEmitter, isSendToJS: isSendBeaconToJS, sendType: "ErrorOthers")
                return
            }
      
            // API Call 경과시간
            let endTime = DispatchTime.now()
            beacon.apiElapsedTime = Double(endTime.uptimeNanoseconds - startTime.uptimeNanoseconds) / 1_000_000
      
            let responseJSON = try? JSONSerialization.jsonObject(with: data, options: [])
            if let responseJSON = responseJSON as? [String: Any] {
                DebugLog.log(self.TAG, items: "Onepass Response = \(responseJSON)")
        
                if responseJSON["error"] == nil {
                    // 정상적으로 문열림 이벤트 전송
                    beacon.lastDetectedAt = Date(timeIntervalSinceNow: Double(userData.sendInterval))
                    userNotificationManager.addNotification(type: .Onepass, title: "[더샵AiQ홈]공동현관 문열림", message: "\(beacon.name)의 공동현관문을 열었습니다.", icon: .ic_onepass)
                    userNotificationManager.schedule()
          
//                    sendEventToJS(beacon, eventEmitter: eventEmitter, isSendToJS: isSendBeaconToJS, sendType: "OpenSuccess")
                } else {
                    // 문열림 이벤트 전송 오류
                    if let errorObject = responseJSON["error"] as? [String: Any] {
                        let errorCode = errorObject["code"] as? String
//                        switch errorCode {
//                            case "55":
//                                sendEventToJS(beacon, eventEmitter: eventEmitter, isSendToJS: isSendBeaconToJS, sendType: "Error55")
//                            case "93", "95", "-201":
//                                // Send TokenExpired to JSModule
//                                eventEmitter.sendEvent(withName: "onExpiredAccessToken", body: ["authorization": userData.authorization])
//                            case "111":
//                                beacon.lastDetectedAt = Date(timeIntervalSinceNow: Double(60))
//
//                                userNotificationManager.addNotification(type: .Onepass, title: "[더샵AiQ홈]공동현관 문열림", message: "월패드의 개인정보 수집·이용 혹은 제3자 정보제공 정책에 동의하지 않았습니다.", icon: .ic_onepass_error)
//                                userNotificationManager.schedule()
//                            case "24", "97", "99":
//                                sendEventToJS(beacon, eventEmitter: eventEmitter, isSendToJS: isSendBeaconToJS, sendType: "ErrorOthers")
//                            // ignore HomenetConnectionException, HomenetException, UnknownException
//                            default:
//                                if let errorMessage = errorObject["message"] as? String {
//                                    if errorMessage.lowercased().range(of: "resolve") != nil {
//                                        userNotificationManager.addNotification(type: .Onepass, title: "[더샵AiQ홈]공동현관 문열림", message: "\(beacon.name)의 문열림 오류입니다.(인터넷 연결을 확인하세요.)", icon: .ic_onepass_error)
//                                    } else {
//                                        userNotificationManager.addNotification(type: .Onepass, title: "[더샵AiQ홈]공동현관 문열림", message: "\(beacon.name)의 문열림 오류입니다.(\(errorMessage))", icon: .ic_onepass_error)
//                                    }
//                                    userNotificationManager.schedule()
//                                }
//                        }
                    }
                }
            }
        }
        task.resume()
    }
  
    static func sendParkingGateInformation(major: Int, minor: Int) {
        let body = [
            "major": major,
            "minor": minor
        ]
    
        let request = makePlatformRequest(.ParkingGateInformation, body: body)
    
//        sendParkingData(request: request, eventEmitter: eventEmitter, isComplete: false, showNotification: false)
    }
  
    static func sendGyroInformation(count: Int) {
        let body = [
            "count": String(count)
        ]
    
        let request = makePlatformRequest(.ParkingGyroInformation, body: body)
    
//        sendParkingData(request: request, eventEmitter: eventEmitter, isComplete: false, showNotification: false)
    }
  
    static func sendParkingComplete(collectSensor: CollectSensor) {
        // 수집한 데이터들
        let body: [String: Any] = [
            "dong": UserDataSingleton.shared.dong,
            "ho": UserDataSingleton.shared.ho,
            "errorCode": GlobalManager.shared.sharedValue,
            "total": collectSensor.collectDataDic
        ]
    
        // create post request 서버로 보내는 작업
        let request = makePlatformRequest(.ParkingComplete, body: body)
    
        sendParkingData(request: request, isComplete: true, showNotification: true)
    }
  
    static func sendParkingData(request: URLRequest, isComplete: Bool, showNotification: Bool) {
        let userData = UserDataSingleton.shared

        if !RestApi.isConnected {
            DebugLog.log(TAG, items: "📡 인터넷 연결 안됨, 요청 저장")
            print("request : ", request)
            pendingRestApiRequests.append(request)
            return
        }

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                GlobalManager.shared.sharedValue += 1
                DebugLog.log(TAG, items: "Request error: \(error.localizedDescription)")
                return
            }

            if let httpResponse = response as? HTTPURLResponse {
                DebugLog.log(TAG, items: "HTTP Response status code: \(httpResponse.statusCode)")
            }

            guard let data = data else {
                GlobalManager.shared.sharedValue += 1
                DebugLog.log(TAG, items: "No data")
                return
            }

            let responseJSON = try? JSONSerialization.jsonObject(with: data, options: [])
            if let responseJSON = responseJSON as? [String: Any] {
                DebugLog.log(TAG, items: "Parking Response = \(responseJSON)")
                if responseJSON["error"] == nil {
                    if isComplete && showNotification {
                        let userNotificationManager = UserNotificationManager.shared
                        userNotificationManager.addNotification(
                            type: .Parking,
                            title: "[더샵AiQ홈]스마트 주차위치",
                            message: "주차위치가 확인되었습니다.",
                            icon: .ic_parking
                        )
                        userNotificationManager.schedule()
                    }
                }
            }
        }

        task.resume()
    }

//    static func sendErrorData(body: [String: Any]) {
//        let request = RestApi.makePlatformRequest(.SendErrorData, body: body)
//        let task = URLSession.shared.dataTask(with: request) { data, _, error in
//            guard let data = data, error == nil else {
//                DebugLog.log(self.TAG, items: error?.localizedDescription ?? "No data")
//                return
//            }
//
//            let responseJSON = try? JSONSerialization.jsonObject(with: data, options: [])
//            if let responseJSON = responseJSON as? [String: Any] {
//                DebugLog.log(self.TAG, items: "SendErrorData Response = \(responseJSON)")
//            }
//        }
//        task.resume()
//    }
//
    static func makePlatformRequest(_ messageType: MobileMessageType, body: Any) -> URLRequest {
        let userData = UserDataSingleton.shared
    
        let url = URL(string: userData.baseUrl + "api/v1/mobile")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
    
        // Headers
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue(userData.authorization, forHTTPHeaderField: "Authorization")
    
        // Body
        let requestBody = [
            "id": UUID().uuidString,
            "type": messageType.rawValue,
            "version": 1,
            "phoneUid": userData.phoneUid,
            "body": body
        ]
        DebugLog.log(TAG, items: "requestBody = \(requestBody)")
        request.httpBody = try! JSONSerialization.data(withJSONObject: requestBody, options: [])
    
        return request
    }
  
    static func makeGetNewAccessTokenRequest() -> URLRequest {
        let userData = UserDataSingleton.shared
        let url = URL(string: userData.baseUrl + "api/v1/oauth2/getNewToken")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
    
        // Headers
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue(userData.basicAuthorization, forHTTPHeaderField: "Authorization")
    
        let requestBody = [
            "complex": userData.complex,
            "address": userData.dong + "-" + userData.ho,
            "username": userData.username
        ]
    
        request.httpBody = try! JSONSerialization.data(withJSONObject: requestBody, options: [])
    
        return request
    }
  
    static func getNewAccessToken(_ type: UserNotificationType, title: String, icon: BluetoothServiceIconType) {
        let userData = UserDataSingleton.shared
        let userNotificationManager = UserNotificationManager.shared
        let request = makeGetNewAccessTokenRequest()
    
        let task = URLSession.shared.dataTask(with: request) { data, _, error in
            guard let data = data, error == nil else {
                DebugLog.log(self.TAG, items: error?.localizedDescription ?? "No data")
                userNotificationManager.addNotification(type: type, title: title, message: "플랫폼 서버에 연결할 수 없습니다.\n잠시 후 다시 시도해 보세요!", icon: icon)
                userNotificationManager.schedule()
        
                return
            }
      
            let responseJSON = try? JSONSerialization.jsonObject(with: data, options: [])
            if let responseJSON = responseJSON as? [String: Any] {
                DebugLog.log(self.TAG, items: "new AccessToken Response = \(responseJSON)")
                if responseJSON["error"] == nil {
                    // 정상적으로 AccessToken을 받아 옮.
                    if let accessToken = responseJSON["access_token"] as? String {
                        userData.authorization = "Bearer " + accessToken
                    }
                } else {
                    userNotificationManager.addNotification(type: type, title: title, message: "인증토큰이 만료되었습니다.\n더샵AiQ홈 앱을 종료하시고 다시 시작해 주세요!", icon: icon)
                    userNotificationManager.schedule()
                }
            }
        }
        task.resume()
    }
    
    /// 네트워크 복구 시 저장된 RestApi 요청들을 전송하는 함수
    public static func sendPendingRestApiRequests() {
        print("Request L: ", pendingRestApiRequests)
        guard !pendingRestApiRequests.isEmpty else {
            DebugLog.log(TAG, items: "📦 보류된 요청 없음")
            return
        }

        DebugLog.log(TAG, items: "🌐 네트워크 복구됨 - 보류된 요청 전송 시작")

        for request in pendingRestApiRequests {
            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                if let error = error {
                    DebugLog.log(TAG, items: "📡 저장된 요청 실패: \(error.localizedDescription)")
                    return
                }

                if let httpResponse = response as? HTTPURLResponse {
                    DebugLog.log(TAG, items: "📬 저장된 요청 응답 코드: \(httpResponse.statusCode)")
                    if httpResponse.statusCode == 200 {
                        pendingRestApiRequests.removeAll()
                    }
                }

                if let data = data,
                   let responseJSON = try? JSONSerialization.jsonObject(with: data, options: []),
                   let responseDict = responseJSON as? [String: Any]
                {
                    DebugLog.log(TAG, items: "✅ 저장된 요청 응답: \(responseDict)")
                }
            }

            task.resume()
        }

        // 전송 완료 후 초기화
        pendingRestApiRequests.removeAll()
    }
}
