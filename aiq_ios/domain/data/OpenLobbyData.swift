//
//  OpenRobbyData.swift
//  SmartParking
//
//  Created by 우리시스템 on 2019. 3. 20..
//  Copyright © 2019년 Sumin Jin. All rights reserved.
//
import Foundation

class OpenLobbyData: NSObject {
  static let instance = OpenLobbyData()
  override public init() {}

  //    var returnCode :Int = 0

  var returnCode: Int = 2

  var message: String = ""

  var rssiSenserValue: Int = -75
}
