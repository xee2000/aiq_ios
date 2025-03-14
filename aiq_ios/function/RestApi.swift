// RestApi.swift
// BeaconService
//
// Created by 우리시스템 MAC on 2020/04/07
// Copyright © 2020 Facebook. All rights reserved.
//

import NotificationCenter

class RestApi: NSObject {
    static func openlobby(uuid: String, major: Int, minor: Int, rssi: Int, distance: Double) {
        let minorHex = String(format: "%04X", minor)

        let userData = UserDataSingleton.shared
        let onepassList = userData.onepassList

        for beacon in onepassList {
            if beacon.uuid == uuid && beacon.minor == minorHex && rssi >= beacon.rssi {
                // Check Detect Time
                print("PSJ_OpenLobby: openLobby() - OPEN 요청: Major: \(major), Minor: \(minorHex), RSSI: \(rssi), Distance: \(distance)")
//                sendBeaconDetectSignal(beacon, rssi: rssi, distance: distance, eventEmitter: eventEmitter, isSendBeaconToJS: isSendBeaconToJS)
            }
        }
    }

//    static func sendEventToJS(_ beacon: OnepassBeacon, eventEmitter: RCTEventEmitter, isSendToJS: Bool, sendType: String) {
//        if isSendToJS {
//            eventEmitter.sendEvent(withName: "onSendBeaconEvent", body: ["major": beacon.major, "minor": beacon.minor, "type": sendType, "elapsedTime": beacon.apiElapsedTime] as [String: Any])
//        }
//    }

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
            "sendTime": dateFormatter.string(from: Date()),
        ]

        // API 경과 시간 시작
        let startTime = DispatchTime.now()

        // create post request 서버로 보내는 작업
        let userNotificationManager = UserNotificationManager()
    }

    static func sendParkingGateInformation(major: Int, minor: Int) {
        let body = [
            "major": major,
            "minor": minor,
        ]

        var Authorization = "Authorization"

//        let request = makePlatformRequest(.ParkingGateInformation, body: body, Authorization: String)

//        sendParkingData(request: request, eventEmitter: eventEmitter, isComplete: false)
    }

    static func sendGyroInformation(count: Int) {
        let body = [
            "count": String(count),
        ]

//        let request = makePlatformRequest(.ParkingGyroInformation, body: body, Authorization: <#T##String#>)

//        sendParkingData(request: request, eventEmitter: eventEmitter, isComplete: false)
    }

    static func sendParkingComplete(collectSensor: CollectSensor) {
//        let username = UserDefaults.standard.string(forKey: "username") ?? ""
//        let dong = UserDefaults.standard.string(forKey: "dong") ?? ""
//        let ho = UserDefaults.standard.string(forKey: "ho") ?? ""
        let Authorization = UserDefaults.standard.string(forKey: "Authorization") ?? ""

//        print("username: ", username)
//        print("dong: ", dong)
//        print("ho: ", ho)
//        print("Authorization: ", Authorization)

        // 사용자 정보는 쿼리 파라미터로 전달되므로, 본문에는 센서 데이터만 포함합니다.
        let body: [String: Any] = collectSensor.collectDataDic

        let request = makePlatformRequest(body: body)

        sendParkingData(request: request)
    }

    static func sendParkingData(request: URLRequest) {
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Request error: \(error.localizedDescription)")
            }

            if let httpResponse = response as? HTTPURLResponse {
                print("HTTP Response status code: \(httpResponse.statusCode)")
            }

            guard let data = data, error == nil else {
                print("No data received")
                return
            }

            do {
                let responseJSON = try JSONSerialization.jsonObject(with: data, options: [])
                if let responseDict = responseJSON as? [String: Any] {
                    print("Parking Response = \(responseDict)")

                    if let errorObject = responseDict["error"] as? [String: Any] {
                        let errorCode = errorObject["code"] as? String
                        if errorCode == "93" || errorCode == "95" || errorCode == "-201" {
                            // 만료된 토큰 처리 로직 추가 가능
                        } else {
                            if let errorMessage = errorObject["message"] as? String {
                                print("Error: \(errorMessage)")
                            }
                        }
                    }
                }
            } catch {
                print("JSON parsing error: \(error.localizedDescription)")
            }
        }
        task.resume()
    }

    static func makePlatformRequest(body: Any) -> URLRequest {
        guard let userInfo = body as? [String: Any] else {
            fatalError("Invalid body data")
        }

        var components = URLComponents(string: "http://192.168.0.75:8080/pms-server-web/app/calcLocation")!
        components.queryItems = [
            URLQueryItem(name: "userId", value: "1234"),
            URLQueryItem(name: "dong", value: "1234"),
            URLQueryItem(name: "ho", value: "1234"),
        ]

        guard let url = components.url else {
            fatalError("Invalid URL")
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")

        // 전체 body를 그대로 전송하려면:
        request.httpBody = try! JSONSerialization.data(withJSONObject: userInfo, options: [])

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
            "username": userData.username,
        ]

        request.httpBody = try! JSONSerialization.data(withJSONObject: requestBody, options: [])

        return request
    }

    static func getNewAccessToken(_ id: String, title: String, icon: BluetoothServiceIconType) {
        let userData = UserDataSingleton.shared

        let userNotificationManager = UserNotificationManager()

        let request = makeGetNewAccessTokenRequest()

        let task = URLSession.shared.dataTask(with: request) { data, _, error in
            guard let data = data, error == nil else {
                print(error?.localizedDescription ?? "No data")
                if userData.notification {
                    userNotificationManager.addNotification(id: id, title: title, message: "플랫폼 서버에 연결할 수 없습니다.\n잠시 후 다시 시도해 보세요!", icon: icon)
                    userNotificationManager.schedule()
                }
                return
            }

            let responseJSON = try? JSONSerialization.jsonObject(with: data, options: [])
            if let responseJSON = responseJSON as? [String: Any] {
                print("new AccessToken Response = \(responseJSON)")
                if responseJSON["error"] == nil {
                    // 정상적으로 AccessToken을 받아 옮.
                    if let accessToken = responseJSON["access_token"] as? String {
                        userData.authorization = "Bearer " + accessToken
                    }
                } else {
                    if userData.notification {
                        userNotificationManager.addNotification(id: id, title: title, message: "인증토큰이 만료되었습니다.\n더샵 AiQ 홈 앱을 종료하시고 다시 시작해 주세요!", icon: icon)
                        userNotificationManager.schedule()
                    }
                }
            }
        }
        task.resume()
    }
}
