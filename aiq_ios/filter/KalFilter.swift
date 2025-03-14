//
//  KalFilter.swift
//  SmartParking
//
//  Created by 우리시스템 on 2018. 12. 27..
//  Copyright © 2018년 Suzy Park. All rights reserved.
//
import Foundation

class KalFilter: NSObject {
    var Q: Double = 0.00001
    var R: Double = 0.001
    var X: Double = 0
    var P: Double = 1
    var K: Double = 0

    func MeasuremEntUpdate() {
        K = (P + Q) / (P + Q + R)
        P = R * (P + Q) / (R + P + Q)
    }

    func initFilter() {
        X = 0.0
        P = 0.0
        K = 0.0
        _ = Update(Value: 0.0)
    }

    func Update(Value: Double) -> Double {
        MeasuremEntUpdate()
        X = X + (Value - X) * K

        return X
    }
}
