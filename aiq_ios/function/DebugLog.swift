//
//  DebugLog.swift
//  cordoba_aiq
//
//  Created by Sun,Kim on 2/28/25.
//  print log를 DEBUG Mode에서만 출력하기 위한 함수임.
//

import Foundation

class DebugLog: NSObject {
    static func log(_ tag: String, items: Any..., separator: String = " ", terminator: String = "\n") {
        #if DEBUG
            Swift.print("\(Date()) \(tag)", items.map { "\($0)" }.joined(separator: separator), terminator: terminator)
        #endif
    }
}
