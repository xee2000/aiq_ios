//
//  GlobalManager.swift
//  aiq_ios
//
//  Created by 이정호 on 3/18/25.
//

import Foundation

class GlobalManager {
    static let shared = GlobalManager()
    var sharedValue: Int = 0
    private init() {} // 외부에서 인스턴스 생성 방지
}
