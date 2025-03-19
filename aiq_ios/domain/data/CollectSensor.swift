//
//  CollectSensor.swift
//  SmartParking
//
//  Created by 우리시스템 on 2019. 2. 7..
//  Copyright © 2019년 Sumin Jin. All rights reserved.
//
import Foundation
import Network

class CollectSensor: NSObject, URLSessionDelegate {
    var collectDataDic: [String: Any] = .init()

    var inputDate: String = ""
    var paringDate: String = ""
    var savedFileName: String = ""

    var sensorsDic: [String: Any] = .init()
    var sensors: [Any] = .init()

    var beaconsDic: [String: Any] = .init()
    var beacons: [Any] = .init()

    var gyrosDic: [String: Any] = .init()
    var gyros: [Any] = .init()

    var AccelBeaconChangeDic: [String: Any] = .init()
    var AccelBeaconDic: [String: Any] = .init()
    var accelBeacons: [Any] = .init()
    private var pendingGyroRequests: [(count: Int, userId: String)] = []
    private var pendingRestApiRequests: [(userId: String, dong: String, ho: String, phoneInfo: String, payload: [String: Any], errorcode: Int)] = []

    private let monitorQueue = DispatchQueue(label: "GyroMonitorQueue")
    private let monitor = NWPathMonitor()

    // 네트워크 연결 상태 저장
    private var isConnected: Bool = false {
        didSet {
            // 오프라인 → 온라인 전환 시 저장된 요청 전송
            if isConnected && oldValue == false {
                sendPendingGyroRequests()
            }
        }
    }

    @objc func addStartTime() {
        collectDataDic.updateValue(inputDate, forKey: "InputDate")
    }

    @objc func addSensor(s: Sensor) {
        sensors.append(s.SensorDic)
        collectDataDic.updateValue(sensors, forKey: "Sensors")
    }

    @objc func addBeacon(b: Beacon) {
        beacons.append(b.BeaconDic)
        collectDataDic.updateValue(beacons, forKey: "Beacons")
    }

    @objc func addGyro(g: Gyro) {
        gyros.append(g.GyroDic)
        collectDataDic.updateValue(gyros, forKey: "Gyros")
    }

    @objc func addAccelBeacon(abcb: AccelBeaconChange) {
        accelBeacons.append(abcb.AccelBeaconChangeDic)
        collectDataDic.updateValue(accelBeacons, forKey: "AccelBeacons")
    }

    @objc func addParingState() {
        collectDataDic.updateValue(paringDate, forKey: "ParingState")
    }

    init(phoneInfo: String) {
        collectDataDic["PhoneInfo"] = phoneInfo
        collectDataDic["InputDate"] = inputDate
        collectDataDic["Sensors"] = sensors
        collectDataDic["Beacons"] = beacons
        collectDataDic["Gyros"] = gyros
        collectDataDic["AccelBeacons"] = accelBeacons
        collectDataDic["ParingState"] = "non-paring"
        collectDataDic["Version"] = "1.0"
    }

    @objc func removeData() {
        sensors.removeAll()
        beacons.removeAll()
        gyros.removeAll()
        accelBeacons.removeAll()

        sensorsDic.removeAll()
        beaconsDic.removeAll()
        gyrosDic.removeAll()
        AccelBeaconDic.removeAll()
        AccelBeaconChangeDic.removeAll()
    }

    @objc func removeAccelBeacon() {
        accelBeacons.removeAll()
    }

    @objc func sendGyroApi(count: Int, userId: String, completion: @escaping (Bool, Error?) -> Void) {
        monitor.pathUpdateHandler = { [weak self] path in
            self?.isConnected = (path.status == .satisfied)
            print("네트워크 상태: \(path.status == .satisfied ? "연결됨" : "끊김")")
        }
        monitor.start(queue: monitorQueue)

        if !isConnected {
            print("네트워크 오프라인: 요청을 임시 저장합니다.")
            pendingGyroRequests.append((count: count, userId: userId))
            completion(false, NSError(domain: "Offline", code: -1009, userInfo: [NSLocalizedDescriptionKey: "네트워크가 오프라인입니다. 요청이 저장되었습니다."]))
            return
        }

        guard let url = URL(string: "https://woorisys2022.iptime.org:7777/pms-server-web/app/gyroInfo?count=\(count)&userId=\(userId)") else {
            print("잘못된 URL")
            completion(false, NSError(domain: "InvalidURL", code: -1, userInfo: [NSLocalizedDescriptionKey: "잘못된 URL입니다."]))
            return
        }

        print("Sending request to URL: \(url.absoluteString)")

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let session = URLSession(configuration: .default, delegate: self, delegateQueue: nil)
        let task = session.dataTask(with: request) { data, response, error in

            if let error = error {
                let nsError = error as NSError
                if nsError.domain == NSURLErrorDomain && nsError.code == NSURLErrorNotConnectedToInternet {
                    self.pendingGyroRequests.append((count: count, userId: userId))
                }
                print("REST API 호출 에러: \(error.localizedDescription)")
                completion(false, error)
                return
            }

            if let httpResponse = response as? HTTPURLResponse {
                print("HTTP Response Code: \(httpResponse.statusCode)")

                guard httpResponse.statusCode == 200 else {
                    print("Server returned an error. HTTP status code: \(httpResponse.statusCode)")
                    if let data = data, let responseBody = String(data: data, encoding: .utf8) {
                        print("Response body: \(responseBody)")
                    }
                    let serverError = NSError(domain: "ServerError", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: "Server returned an error"])
                    completion(false, serverError)
                    return
                }
            } else {
                print("No valid HTTP response received.")
            }

            if let data = data {
                do {
                    let responseJson = try JSONSerialization.jsonObject(with: data, options: [])
                    print("Response JSON: \(responseJson)")
                    completion(true, nil)
                } catch {
                    print("Error decoding response JSON: \(error.localizedDescription)")
                    if let rawData = String(data: data, encoding: .utf8) {
                        print("Raw response data: \(rawData)")
                    }
                    completion(false, error)
                }
            } else {
                print("No response data received")
                completion(false, NSError(domain: "NoData", code: -4, userInfo: [NSLocalizedDescriptionKey: "No response data received"]))
            }
        }

        task.resume()
    }

    @objc func RestApi(userId: String,
                       dong: String,
                       ho: String,
                       phoneInfo: String,
                       collectSensor: CollectSensor,
                       errorcode: Int,
                       completion: @escaping (Any?, NSError?) -> Void)
    {
        // 네트워크 상태 모니터링 (이미 init()에서 실행 중이라면 생략 가능)
        monitor.pathUpdateHandler = { [weak self] path in
            self?.isConnected = (path.status == .satisfied)
            print("네트워크 상태: \(path.status == .satisfied ? "연결됨" : "끊김")")
            if self?.isConnected == true {
                self?.sendPendingRestApiRequests()
            }
        }
        monitor.start(queue: monitorQueue)

        // 네트워크 연결 여부 확인
        if !isConnected {
            print("네트워크 오프라인: RestApi 요청을 임시 저장합니다.")
            // collectSensor.collectDataDic에 저장된 데이터를 payload로 사용
            let payload = collectSensor.collectDataDic
            // pendingRestApiRequests 배열에 요청 정보 저장
            pendingRestApiRequests.append((userId: userId,
                                           dong: dong,
                                           ho: ho,
                                           phoneInfo: phoneInfo,
                                           payload: payload,
                                           errorcode: errorcode))
            // 네트워크가 오프라인임을 알리는 에러와 함께 completion 호출
            completion(nil, NSError(domain: "Offline", code: -1009, userInfo: [NSLocalizedDescriptionKey: "네트워크가 오프라인입니다. RestApi 요청이 저장되었습니다."]))
            return
        }

        // 네트워크가 연결된 상태라면 정상적으로 REST API 호출 진행
        guard let url = URL(string: "https://woorisys2022.iptime.org:7777/pms-server-web/app/calcLocation?userId=\(userId)&dong=\(dong)&ho=\(ho)&errorcode=\(errorcode)") else {
            print("Invalid URL")
            completion(nil, NSError(domain: "InvalidURL", code: 0, userInfo: nil))
            return
        }

        print("Sending RestApi request to URL: \(url.absoluteString)")

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        do {
            let jsonData = try JSONSerialization.data(withJSONObject: collectSensor.collectDataDic, options: [])
            request.httpBody = jsonData
            print("Payload JSON: \(collectSensor.collectDataDic)")
        } catch {
            print("Error encoding JSON: \(error.localizedDescription)")
            completion(nil, error as NSError)
            return
        }

        let session = URLSession(configuration: .default, delegate: self, delegateQueue: nil)
        let task = session.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error in REST API call: \(error.localizedDescription)")
                completion(nil, error as NSError)
                return
            }

            guard let httpResponse = response as? HTTPURLResponse else {
                print("No valid HTTP response received.")
                completion(nil, NSError(domain: "NoHTTPResponse", code: 0, userInfo: nil))
                return
            }

            print("HTTP Response Code: \(httpResponse.statusCode)")
            guard httpResponse.statusCode == 200 else {
                if let data = data, let responseBody = String(data: data, encoding: .utf8) {
                    print("Response body: \(responseBody)")
                }
                let serverError = NSError(domain: "ServerError",
                                          code: httpResponse.statusCode,
                                          userInfo: [NSLocalizedDescriptionKey: "Server returned an error"])
                completion(nil, serverError)
                return
            }
            BeaconServiceFore.ParkingComplete()

            if let data = data {
                do {
                    let responseJson = try JSONSerialization.jsonObject(with: data, options: [])
                    print("Response JSON: \(responseJson)")
                    completion(responseJson, nil)
                } catch {
                    print("Error decoding response JSON: \(error.localizedDescription)")
                    if let rawData = String(data: data, encoding: .utf8) {
                        print("Raw response data: \(rawData)")
                    }
                    completion(nil, error as NSError)
                }
            } else {
                print("No response data received")
                completion(nil, NSError(domain: "NoData", code: 0, userInfo: nil))
            }
        }
        task.resume()
    }

    @objc func ErrorApi(userId: String,
                        dong: String,
                        ho: String,
                        phoneInfo: String,
                        completion: @escaping (Any?, NSError?) -> Void)
    {
        guard let url = URL(string: "https://192.168.0.33:8080/pms-server-web/app/errorScript?userId=\(userId)&dong=\(dong)&ho=\(ho)") else {
            print("Invalid URL")
            completion(nil, NSError(domain: "InvalidURL", code: 0, userInfo: nil))
            return
        }

        print("Sending RestApi request to URL: \(url.absoluteString)")

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        // 에러파일이 존재한다면 가져와서 보내지도록 가져온다
        if let jsonObject = JsonFileSave.loadJson(filename: "file") {
            do {
                let data = try JSONSerialization.data(withJSONObject: jsonObject, options: [])
                request.httpBody = data
            } catch {
                print("JSON 객체를 Data로 변환하는데 실패했습니다: \(error.localizedDescription)")
                completion(nil, error as NSError)
                return
            }
        } else {
            print("파일에서 JSON 객체를 불러오지 못했습니다.")
            let fileError = NSError(domain: "FileNotFound", code: 0, userInfo: [NSLocalizedDescriptionKey: "파일에서 JSON 객체를 불러오지 못했습니다."])
            completion(nil, fileError)
            return
        }

        let session = URLSession(configuration: .default, delegate: self, delegateQueue: nil)
        let task = session.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error in REST API call: \(error.localizedDescription)")
                completion(nil, error as NSError)
                return
            }

            guard let httpResponse = response as? HTTPURLResponse else {
                print("No valid HTTP response received.")
                completion(nil, NSError(domain: "NoHTTPResponse", code: 0, userInfo: nil))
                return
            }

            print("HTTP Response Code: \(httpResponse.statusCode)")
            guard httpResponse.statusCode == 200 else {
                print("Server returned an error. HTTP status code: \(httpResponse.statusCode)")

                if let data = data, let responseBody = String(data: data, encoding: .utf8) {
                    print("Response body: \(responseBody)")
                }
                let serverError = NSError(domain: "ServerError",
                                          code: httpResponse.statusCode,
                                          userInfo: [NSLocalizedDescriptionKey: "Server returned an error"])
                completion(nil, serverError)
                return
            }

            if let data = data {
                do {
                    let responseJson = try JSONSerialization.jsonObject(with: data, options: [])
                    print("Response JSON: \(responseJson)")
                    completion(responseJson, nil)
                } catch {
                    print("Error decoding response JSON: \(error.localizedDescription)")
                    if let rawData = String(data: data, encoding: .utf8) {
                        print("Raw response data: \(rawData)")
                    }
                    completion(nil, error as NSError)
                }
            } else {
                print("No response data received")
                completion(nil, NSError(domain: "NoData", code: 0, userInfo: nil))
            }
        }
        task.resume()
    }

    // URLSessionDelegate 구현
    func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        if let serverTrust = challenge.protectionSpace.serverTrust {
            completionHandler(.useCredential, URLCredential(trust: serverTrust))
        } else {
            print("serverTrust is nil. Cannot bypass SSL validation.")
            completionHandler(.cancelAuthenticationChallenge, nil)
        }
    }

    /// 저장된 요청들을 네트워크가 연결되었을 때 전송하는 함수
    private func sendPendingGyroRequests() {
        guard !pendingGyroRequests.isEmpty else { return }
        print("저장된 요청 전송 시작...")

        // 저장된 요청들을 순차적으로 전송
        for requestInfo in pendingGyroRequests {
            sendGyroApi(count: requestInfo.count, userId: requestInfo.userId) { success, error in
                if success {
                    print("임시 저장된 요청 전송 성공: count=\(requestInfo.count), userId=\(requestInfo.userId)")
                } else {
                    print("임시 저장된 요청 전송 실패: count=\(requestInfo.count), userId=\(requestInfo.userId), error: \(String(describing: error))")
                }
            }
        }
        // 전송 후 pending 배열 초기화
        pendingGyroRequests.removeAll()
    }

    /// 네트워크 복구 시 저장된 RestApi 요청들을 전송하는 함수
    private func sendPendingRestApiRequests() {
        guard !pendingRestApiRequests.isEmpty else { return }
        print("네트워크 연결 복구됨: 저장된 RestApi 요청 전송 시작...")

        for requestInfo in pendingRestApiRequests {
            // 재전송을 위해 위 RestApi 함수를 호출하거나 별도의 재전송 로직을 구현
            // 아래는 재전송의 예시 (completion 블록은 생략하거나 별도로 처리)
            RestApi(userId: requestInfo.userId,
                    dong: requestInfo.dong,
                    ho: requestInfo.ho,
                    phoneInfo: requestInfo.phoneInfo,
                    collectSensor: CollectSensor(phoneInfo: requestInfo.phoneInfo), // 또는 기존 collectSensor 객체 사용
                    errorcode: requestInfo.errorcode)
            { _, error in
                if error == nil {
                    print("저장된 RestApi 요청 전송 성공: userId=\(requestInfo.userId)")
                } else {
                    print("저장된 RestApi 요청 전송 실패: userId=\(requestInfo.userId), error: \(String(describing: error))")
                }
            }
        }
        // 전송 후 저장된 요청들을 비움
        pendingRestApiRequests.removeAll()
    }
}

// 기존 클래스들 유지
class Sensor: NSObject {
    var SensorDic: [String: Any] = .init()

    @objc func addSensorDic(seq: String, state: String, delay: String) {
        SensorDic["Seq"] = seq
        SensorDic["State"] = state
        SensorDic["Delay"] = delay
    }
}

class Beacon: NSObject {
    var BeaconDic: [String: Any] = .init()

    @objc func addBeaconDic(seq: String, id: String, state: String, rssi: String, delay: String) {
        BeaconDic["Seq"] = seq
        BeaconDic["ID"] = id
        BeaconDic["State"] = state
        BeaconDic["Rssi"] = rssi
        BeaconDic["Delay"] = delay
    }
}

class Gyro: NSObject {
    var GyroDic: [String: Any] = .init()

    @objc func addGyroDic(x: String, y: String, z: String, delay: String) {
        GyroDic["X"] = x
        GyroDic["Y"] = y
        GyroDic["Z"] = z
        GyroDic["Delay"] = delay
    }
}

class AccelBeacon: NSObject {
    var AccelBeaconDic: [String: Any] = .init()
}

class AccelBeaconChange: NSObject {
    var AccelBeaconChangeDic: [String: Any] = .init()

    @objc func addAccelBeaconChangeDic(id: String, rssi: String, delay: String, count: String, delayList: [String]) {
        AccelBeaconChangeDic["ID"] = id
        AccelBeaconChangeDic["Rssi"] = rssi
        AccelBeaconChangeDic["Delay"] = delay
        AccelBeaconChangeDic["Count"] = count

        AccelBeaconChangeDic["DelayList"] = delayList
    }
}
