import Foundation

class MySensor {
  var sensorDic: [String: String] = [:]

  // addSensorDic 메서드: seq, state, delay를 매핑하여 저장
  func addSensorDic(seq: String, state: String, delay: String) {
    let sensorData: [String: String] = [
      "Seq": seq,
      "State": state,
      "Delay": delay,
    ]
    // 데이터 저장
    sensorDic = sensorData
  }
}
