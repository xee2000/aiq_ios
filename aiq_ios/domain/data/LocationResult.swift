//
//  LocationResult.swift
//  SmartParking
//
//  Created by 우리시스템 on 2019. 2. 7..
//  Copyright © 2019년 Sumin Jin. All rights reserved.
//
import Foundation

class LocationResult: NSObject {
//    var userInfo = userData()
    var selectIndex: Int = 0

    static let instance = LocationResult()
    var returnCode: Int = 0
    var interestCar: String = ""

    var _locationArray: [Any] = [5]

    var locationArray: [Any] {
        get {
            return _locationArray
        }
        set(newval) {
            _locationArray = newval
        }
    }

    var _carNumber = [String]()

    var carNumber: [String] {
        get {
            return _carNumber
        }
        set(newval) {
            _carNumber = newval
        }
    }

    var _mapId = Array(repeating: "", count: 5)

    var mapId: [String] {
        get {
            return _mapId
        }
        set(newval) {
            _mapId = newval
        }
    }

    var _lastParkingTime = Array(repeating: "", count: 5)

    var lastParkingTime: [String] {
        get {
            return _lastParkingTime
        }
        set(newval) {
            _lastParkingTime = newval
        }
    }

    var _area = Array(repeating: "", count: 5)

    var area: [String] {
        get {
            return _area
        }
        set(newval) {
            _area = newval
        }
    }

    var _x = Array(repeating: 0.0, count: 5)

    var x: [Double] {
        get {
            return _x
        }
        set(newval) {
            _x = newval
        }
    }

    var _y = Array(repeating: 0.0, count: 5)

    var y: [Double] {
        get {
            return _y
        }
        set(newval) {
            _y = newval
        }
    }

    var _startParkingTime = Array(repeating: "", count: 1)

    var startParkingTime: [String] {
        get {
            return _startParkingTime
        }
        set(newval) {
            _startParkingTime = newval
        }
    }
}
