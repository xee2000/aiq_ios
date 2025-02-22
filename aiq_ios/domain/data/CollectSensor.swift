//
//  CollectSensor.swift
//  SmartParking
//
//  Created by 우리시스템 on 2019. 2. 7..
//  Copyright © 2019년 Sumin Jin. All rights reserved.
//
import Foundation

class CollectSensor: NSObject, URLSessionDelegate {
  var collectDataDic: [String: Any] = .init()

  var inputDate: String = ""
  var paringDate: String = ""

  var sensorsDic: [String: Any] = .init()
  var sensors: [Any] = .init()

  var beaconsDic: [String: Any] = .init()
  var beacons: [Any] = .init()

  var gyrosDic: [String: Any] = .init()
  var gyros: [Any] = .init()

  var AccelBeaconChangeDic: [String: Any] = .init()
  var AccelBeaconDic: [String: Any] = .init()
  var accelBeacons: [Any] = .init()

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
    collectDataDic["ParingState"] = paringDate
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

  // 수정된 sendGyroApi 메서드
  @objc func sendGyroApi(count: Int, userId: String, completion: @escaping (Bool, Error?) -> Void) {
    guard let url = URL(string: "https://192.168.0.12:8080/pms-server-web/app/gyroInfo?count=\(count)&userId=\(userId)") else {
      print("Invalid URL")
      completion(false, NSError(domain: "InvalidURL", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"]))
      return
    }

    // Create request
    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")

    // Send request
    let session = URLSession(configuration: .default, delegate: self, delegateQueue: nil)
    let task = session.dataTask(with: request) { data, response, error in
      if let error = error {
        print("Error in REST API call: \(error)")
//        completion(false, error)
        return
      }

      if let httpResponse = response as? HTTPURLResponse {
        print("HTTP Response Code: \(httpResponse.statusCode)")

        // Check for successful response
        guard httpResponse.statusCode == 200 else {
          let serverError = NSError(domain: "ServerError", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: "Server returned an error"])
//          completion(false, serverError)
          return
        }
      }

      // Process response data
      if let data = data {
        do {
          let responseJson = try JSONSerialization.jsonObject(with: data, options: [])
          print("Response JSON: \(responseJson)")
          completion(true, nil)
        } catch {
          print("Error decoding response JSON: \(error)")
          completion(false, error)
        }
      } else {
        print("No response data received")
        completion(false, NSError(domain: "NoData", code: -4, userInfo: [NSLocalizedDescriptionKey: "No response data received"]))
      }
    }

    task.resume()
  }

  // 수정된 sendGyroApi 메서드
  @objc func RestApi(userId: String, dong: String, ho: String, phoneInfo: String, collectSensor: CollectSensor) {
    print("Phone Info: \(phoneInfo)")
    print("collectDataDic before sending: ", collectSensor.collectDataDic) // 전송 직전 상태 확인

    guard let url = URL(string: "https://172.30.1.82:8080/pms-server-web/app/calcLocation?userId=\(userId)&dong=\(dong)&ho=\(ho)") else {
      print("Invalid URL")

      return
    }

    // Create request
    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")

    // Add count to payload
    var payload = collectSensor.collectDataDic
//    payload["count"] = count

    // Encode to JSON
    do {
      let jsonData = try JSONSerialization.data(withJSONObject: payload, options: [])
      request.httpBody = jsonData
      print("Payload JSON: \(payload)")
    } catch {
      print("Error encoding JSON: \(error)")
//      completion(false, error)
      return
    }

    // Send request
    let session = URLSession(configuration: .default, delegate: self, delegateQueue: nil)
    let task = session.dataTask(with: request) { data, response, error in
      if let error = error {
        print("Error in REST API call: \(error)")
//        completion(false, error)
        return
      }

      if let httpResponse = response as? HTTPURLResponse {
        print("HTTP Response Code: \(httpResponse.statusCode)")

        // Check for successful response
        guard httpResponse.statusCode == 200 else {
          let serverError = NSError(domain: "ServerError", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: "Server returned an error"])
//          completion(false, serverError)
          return
        }
      }

      // Process response data
      if let data = data {
        do {
          let responseJson = try JSONSerialization.jsonObject(with: data, options: [])
          print("Response JSON: \(responseJson)")
//          completion(true, nil)
        } catch {
          print("Error decoding response JSON: \(error)")
//          completion(false, error)
        }
      } else {
        print("No response data received")
//        completion(false, NSError(domain: "NoData", code: -4, userInfo: [NSLocalizedDescriptionKey: "No response data received"]))
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
    print("delayList : ", delayList)
    AccelBeaconChangeDic["ID"] = id
    AccelBeaconChangeDic["Rssi"] = rssi
    AccelBeaconChangeDic["Delay"] = delay
    AccelBeaconChangeDic["Count"] = count

    AccelBeaconChangeDic["DelayList"] = delayList
  }
}
