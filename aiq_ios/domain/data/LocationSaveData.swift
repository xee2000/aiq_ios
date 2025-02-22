//
//  LocationSaveData.swift
//  SmartParking
//
//  Created by 우리시스템 on 2019. 3. 5..
//  Copyright © 2019년 Sumin Jin. All rights reserved.
//
import Foundation

class LocationSaveData: NSObject {
    static let instance = LocationSaveData()
    override private init() {}

    var _markerX: Double = 0

    var markerX: Double {
        get {
            return _markerX
        }
        set(newval) {
            _markerX = newval
        }
    }

    var _markerY: Double = 0

    var markerY: Double {
        get {
            return _markerY
        }
        set(newval) {
            _markerY = newval
        }
    }
}
