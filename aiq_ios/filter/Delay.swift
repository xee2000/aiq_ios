//
//  Delay.swift
//  SmartParking
//
//  Created by 우리시스템 on 2019. 3. 20..
//  Copyright © 2019년 Sumin Jin. All rights reserved.
//
import Foundation

class Delay: NSObject {
    var opencheck: Bool = false

    let time = DispatchTime.now() + .seconds(5)
    func delay(delay: Double, closure _: @escaping () -> Void) {
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
            print("딜레이이이이이")
            self.opencheck = false
        }
    }
}
