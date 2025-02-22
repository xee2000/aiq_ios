//
//  BGSingleton.swift
//  SmartParking
//
//  Created by 우리시스템MAC on 2022/05/13.
//  Copyright © 2022 Sumin Jin. All rights reserved.
//

class BGSingleton {
    static let shared = BGSingleton()

    var backgroundFlag: Bool = false

    private init() {}
}
