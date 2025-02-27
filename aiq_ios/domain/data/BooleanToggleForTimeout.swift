//
//  BooleanToggleForTimeout.swift
//  cordoba_aiq
//
//  Created by Sun,Kim on 10/30/24.
//
import Foundation

class BooleanToggleForTimeout {
  // Flag 변수
  private var toggleFlag: Bool = false
  // flag 변경을 자동으로 취소할 DispatchWorkItem
  private var cancelableWorkItem: DispatchWorkItem?
  // 동기화 처리를 위한 직렬 큐
  private let queue = DispatchQueue(label: "com.poscoict.thesharpiotapp.BooleanToggleForTimeout", attributes: .concurrent)
  private var timeout: TimeInterval = 300.0

  init(timeout: TimeInterval) {
  }

  // Flag 값을 읽는 메서드
  var isFlagActive: Bool {
    return queue.sync {
      toggleFlag
    }
  }

  // Flag를 true로 설정하고 5분 뒤 false로 자동 설정하는 메서드
  func activateFlag() {
    // 기존 예약된 작업이 있다면 취소
    cancelableWorkItem?.cancel()
    // Flag를 True로 설정
    queue.async(flags: .barrier) {
      self.toggleFlag = true
    }

    // 일정 시간 후에 flag를 false로 설정하는 작업을 DispatchWorkItem으로 생성
    let workItem = DispatchWorkItem { [weak self] in
      guard let self = self else { return }
      self.queue.async(flags: .barrier) {
        self.toggleFlag = false
      }
    }

    // 작업 아이텤을 일정 시간 후에 실행되도록 예약
    queue.asyncAfter(deadline: .now() + timeout, execute: workItem)

    // 작업 아이템을 인스턴스 변수에 저장해 두고 필요 시 취소할 수 있도록 함
    cancelableWorkItem = workItem
  }

  // 타이머를 취소하는 메서드
  func cancelTimer() {
    cancelableWorkItem?.cancel()
    cancelableWorkItem = nil
  }
}
