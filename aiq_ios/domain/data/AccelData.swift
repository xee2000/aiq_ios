//
//  AccelData.swift
//  SmartParking
//
//  Created by 우리시스템 on 2019. 2. 7..
//  Copyright © 2019년 Sumin Jin. All rights reserved.
//
import Foundation

class AccelData: NSObject {
  var _id: String = ""

  var id: String {
    get {
      return _id
    }
    set(newval) {
      _id = newval
    }
  }

  var _rssi: String = ""

  var rssi: String {
    get {
      return _rssi
    }
    set(newval) {
      _rssi = newval
    }
  }

  var _delay: String = ""

  var delay: String {
    get {
      return _delay
    }
    set(newval) {
      _delay = newval
    }
  }

  var _delayList: [String] = []

  var delayList: [String] {
    get {
      return _delayList
    }
    set(newval) {
      _delayList = newval
    }
  }

  var _count: String = ""

  var count: String {
    get {
      return _count
    }
    set(newval) {
      _count = newval
    }
  }
}
