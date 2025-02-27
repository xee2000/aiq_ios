//
//  ThreadSafeQueue.swift
//  cordoba_aiq
//
//  Created by Sun,Kim on 11/5/24.
//

import Foundation

class ThreadSafeQueue<T> {
  private var queue = [T]()
  private let dispatchQueue = DispatchQueue(label: "com.poscoict.thesharpiotapp.ThreadSafeQueue", attributes: .concurrent)
  private let semaphore = DispatchSemaphore(value: 1)
  
  // 큐에 요소 추가 (enqueue)
  func enqueue(_ element: T) {
    dispatchQueue.async(flags: .barrier) {
      self.semaphore.wait()
      self.queue.append(element)
      self.semaphore.signal()
    }
  }
  
  // 큐에서 요소 제거 (dequeue)
  func dequeue() -> T? {
    var element: T?
    dispatchQueue.sync {
      self.semaphore.wait()
      if !self.queue.isEmpty {
        element = self.queue.removeFirst()
      }
      self.semaphore.signal()
    }
    return element
  }
  
  // 큐의 첫 번째 요소 확인
  func peek() -> T? {
    var element: T?
    dispatchQueue.sync {
      self.semaphore.wait()
      element = self.queue.first
      self.semaphore.signal()
    }
    return element
  }
  
  // 큐가 비어 있는지 확인
  func isEmpty() -> Bool {
    var result = false
    dispatchQueue.sync {
      self.semaphore.wait()
      result = self.queue.isEmpty
      self.semaphore.signal()
    }
    return result
  }
}
