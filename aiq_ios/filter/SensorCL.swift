import Foundation // NSObject를 사용하려면 Foundation이 필요합니다

class SensorCL: NSObject {
    static let instance = SensorCL()
    override private init() {}

    // 계산 진행을 위한 State 값 -> 다음 어떤 진행을 할 것인지 확인하기 위해서 필요한 변수
    public var STATECalc_W: String = "START"

    // 세우기의 조건을 만족하였는지 Check, 2번 확인 해야됨 (오른쪽 -> 세우기 / 왼쪽 -> 세우기)
    var StayMatch_W: Bool = false

    // 오른쪽으로 기울이기의 조건을 만족하였는지 Check
    var RightMatch_W: Bool = false

    // 왼쪽으로 기울이기의 조건을 만족하였는지 Check
    var LeftMatch_W: Bool = false

    func STAY(ROLL: Double, PITCH: Double) {
        if ROLL <= -80 && ROLL >= -100 && PITCH <= -160 && PITCH >= -180 {
            StayMatch_W = true
        }
    }

    func RIGHT(ROLL: Double, PITCH: Double) {
        if ROLL <= -115 && ROLL >= -135 && PITCH <= 105 && PITCH >= 85 {
            RightMatch_W = true
        }
    }

    func LEFT(ROLL: Double, PITCH: Double) {
        if ROLL <= -125 && ROLL >= -145 && PITCH <= -85 && PITCH >= -105 {
            LeftMatch_W = true
        }
    }

    var STATECalc: String {
        get {
            return STATECalc_W
        }
        set(newSTATE) {
            STATECalc_W = newSTATE
        }
    }
}
