//
//  AccelRsultData.swift
//  SmartParking
//
//  Created by 우리시스템 on 2019. 4. 16..
//  Copyright © 2019년 Sumin Jin. All rights reserved.
//
import Foundation

class AccelResultData: NSObject {
    static let instance = AccelResultData()
    override public init() {}

    var _accRsult: String = ""

    var accRsult: String {
        get {
            return _accRsult
        }
        set(newval) {
            _accRsult = newval
        }
    }
}
