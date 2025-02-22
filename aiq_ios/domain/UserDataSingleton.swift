//
//  UserDataSingleton.swift
//  BeaconService
//
//  Created by POSCO ICT on 2020/04/06.
//  Copyright © 2020 Facebook. All rights reserved.
//

class UserDataSingleton {
  static let shared = UserDataSingleton()
  private init() {
    _onepassList = [OnepassBeacon]()
  }

  var _purpose: String = ""
  var purpose: String {
    get {
      return _purpose
    }
    set {
      _purpose = newValue
    }
  }

  var _baseUrl: String = ""
  var baseUrl: String {
    get {
      return _baseUrl
    }
    set {
      _baseUrl = newValue
    }
  }

  var _phoneUid: String = ""
  var phoneUid: String {
    get {
      return _phoneUid
    }
    set {
      _phoneUid = newValue
    }
  }

  var _authorization: String = ""
  var authorization: String {
    get {
      return _authorization
    }
    set {
      _authorization = newValue
    }
  }

  var _basicAuthorization: String = ""
  var basicAuthorization: String {
    get {
      return _basicAuthorization
    }
    set {
      _basicAuthorization = newValue
    }
  }

  var _complex: String = ""
  var complex: String {
    get {
      return _complex
    }
    set {
      _complex = newValue
    }
  }

  var _dong: String = ""
  var dong: String {
    get {
      return _dong
    }
    set {
      _dong = newValue
    }
  }

  var _ho: String = ""
  var ho: String {
    get {
      return _ho
    }
    set {
      _ho = newValue
    }
  }

  var _username: String = ""
  var username: String {
    get {
      return _username
    }
    set {
      _username = newValue
    }
  }

  var _isDriver: Bool = false
  var isDriver: Bool {
    get {
      return _isDriver
    }
    set {
      _isDriver = newValue
    }
  }

  var _beaconUUID: String = ""
  var beaconUUID: String {
    get {
      return _beaconUUID
    }
    set {
      _beaconUUID = newValue
    }
  }

  var _sendInterval: Int = 0
  var sendInterval: Int {
    get {
      return _sendInterval
    }
    set {
      _sendInterval = newValue
    }
  }

  var _ignoreInterval: Int = 0
  var ignoreInterval: Int {
    get {
      return _ignoreInterval
    }
    set {
      _ignoreInterval = newValue
    }
  }

  var _onepassList: [OnepassBeacon]
  var onepassList: [OnepassBeacon] {
    get {
      return _onepassList
    }
    set {
      _onepassList = newValue
    }
  }

  var _notification: Bool = true
  var notification: Bool {
    get {
      return _notification
    }
    set {
      _notification = newValue
    }
  }
}
