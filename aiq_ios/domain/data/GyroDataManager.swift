import Foundation

public class GyroDataManager: ObservableObject {
    public static let shared = GyroDataManager() // singleton 인스턴스

    @Published public var x: Double = 0.0
    @Published public var y: Double = 0.0
    @Published public var z: Double = 0.0

    /// 센서에서 계산된 평균값을 그대로 업데이트
    public func updateGyroData(roll: Double, pitch: Double, yaw: Double) {
        DispatchQueue.main.async {
            self.x = roll
            self.y = pitch
            self.z = yaw
            print("GyroData updated -> x: \(self.x), y: \(self.y), z: \(self.z)")
        }
    }
}
