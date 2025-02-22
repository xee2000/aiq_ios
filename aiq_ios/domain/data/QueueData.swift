//
//  QueueData.swift
//  SmartParking
//
//  Created by 우리시스템 on 2019. 2. 7..
//  Copyright © 2019년 Sumin Jin. All rights reserved.
//
import Foundation

class QueueData: NSObject {
    /// 크기에 제약이 없는 FIFO 큐
    /// 복잡도: push O(1), pop O(`count`)
    public struct Queue<T>: ExpressibleByArrayLiteral {
        /// 내부 배열 저장소
        public var elements: [T] = []

        /// 새로운 엘리먼트 추가. 소요 시간 = O(1)
        public mutating func push(value: T) { elements.append(value) }

        /// 가장 앞에 있는 엘리먼트를 꺼내오기. 소요시간 = O(`count`)
        public mutating func pop() -> T? {
            if elements.isEmpty {
                return nil
            } else {
                return elements.removeFirst()
            }
        }

        /// 큐가 비었는지 검사
        public var isEmpty: Bool { return elements.isEmpty }

        /// 큐의 크기, 연산 프로퍼티
        public var count: Int { return elements.count }

        /// ArrayLiteralConvertible 지원
        public init(arrayLiteral elements: T...) { self.elements = elements }
    }
}
