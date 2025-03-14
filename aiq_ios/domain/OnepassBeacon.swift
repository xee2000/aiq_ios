//
//  OnepassBeacon.swift
//  BeaconService
//
//  Created by POSCO ICT on 2020/04/06.
//  Copyright © 2020 Facebook. All rights reserved.
//
import Foundation

class OnepassBeacon {
    var _sid: String = ""
    var sid: String {
        get {
            return _sid
        }
        set {
            _sid = newValue
        }
    }

    var _name: String = ""
    var name: String {
        get {
            return _name
        }
        set {
            _name = newValue
        }
    }

    var _uuid: String = ""
    var uuid: String {
        get {
            return _uuid
        }
        set {
            _uuid = newValue
        }
    }

    var _major: String = ""
    var major: String {
        get {
            return _major
        }
        set {
            _major = newValue
        }
    }

    var _minor: String = ""
    var minor: String {
        get {
            return _minor
        }
        set {
            _minor = newValue
        }
    }

    var _rssi: Int = 0
    var rssi: Int {
        get {
            return _rssi
        }
        set {
            _rssi = newValue
        }
    }

    // 하루 전
    var _lastDetectedAt = Date(timeIntervalSinceNow: -86400)
    var lastDetectedAt: Date {
        get {
            return _lastDetectedAt
        }
        set {
            _lastDetectedAt = newValue
        }
    }

    var _apiElapsedTime: Double = 0.0
    var apiElapsedTime: Double {
        get {
            return _apiElapsedTime
        }
        set {
            _apiElapsedTime = newValue
        }
    }
}
