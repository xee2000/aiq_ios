import CoreBluetooth
import CoreLocation
import CoreMotion
import SwiftUI
import UserNotifications

struct ContentView: View {
    @StateObject private var permissionManager = PermissionManager()
    @StateObject private var beaconService = BeaconService()
    
    @AppStorage("username") private var username: String = ""
    @AppStorage("dong") private var dong: String = ""
    @AppStorage("ho") private var ho: String = ""
    @AppStorage("purpose") private var purpose: String = ""
    @AppStorage("Authorization") private var Authorization: String = ""
    
    // 실제 저장되는 비콘 UUID
    @AppStorage("UUID") private var uuid: String = "201510058864-5654-3020010400-2409-01"
    
    let uuids: [(label: String, value: String)] = [
        ("더샵 트위넌스 1단지", "20151005-8864-5654-3020-010400240901"),
        ("더샵 트위넌스 2단지", "20151005-8864-5654-3020-010400240902"),
        ("대전 용문 더샵 엘리프 1단지", "20151005-8864-5654-3017-010500250101"),
        ("대전 용문 더샵 엘리프 2단지", "20151005-8864-5654-3017-010500250102"),
        ("대전 용문 더샵 엘리프 3단지", "20151005-8864-5654-3017-010500250103"),
        ("전남 광양 베이센트", "20151005-8864-5654-4623-010100240601")
    ]
    
    @State private var loggedIn = false
    
    // 앱 전체에서 공유할 GyroDataManager 인스턴스
    @StateObject private var gyroDataManager = GyroDataManager()
    
    var body: some View {
        if loggedIn {
            ServiceRunningView(
                onLogout: { logoutAndReset() },
                gyroData: gyroDataManager
            )
        } else {
            NavigationView {
                VStack(spacing: 20) {
                    // 단지 선택 및 로그인 UI
                    VStack(alignment: .leading, spacing: 5) {
                        Text("단지 선택")
                            .font(.headline)
                        Picker("단지명 선택", selection: $uuid) {
                            ForEach(uuids, id: \.value) { item in
                                Text(item.label).tag(item.value)
                            }
                        }
                        .pickerStyle(MenuPickerStyle())
                    }
                    VStack(alignment: .leading, spacing: 5) {
                        Text("아이디")
                            .font(.headline)
                        TextField("아이디를 입력하세요", text: $username)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                    }
                    VStack(alignment: .leading, spacing: 5) {
                        Text("동")
                            .font(.headline)
                        TextField("동을 입력하세요", text: $dong)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                    }
                    VStack(alignment: .leading, spacing: 5) {
                        Text("호")
                            .font(.headline)
                        TextField("호를 입력하세요", text: $ho)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                    }
                    Button(action: {
                        print("""
                        로그인 버튼 눌림
                        - 아이디: \(username)
                        - 동: \(dong)
                        - 호: \(ho)
                        - 단지명(표시용): \(uuidLabel(for: uuid))
                        - 실제 UUID: \(uuid)
                        """)
                        
                        beaconService.requestAlwaysAuthorization()
                        beaconService.startMonitoring()
                        BeaconServiceFore.StartingService()
                        
                        loggedIn = true
                        purpose = "parking"
                        Authorization = "Bearer xxxxxx" // 실제 토큰
                    }) {
                        Text("로그인")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }
                    
                    Spacer()
                }
                .padding()
                .navigationTitle("AIQ 주차위치 서비스")
                .navigationBarTitleDisplayMode(.inline)
            }
            .ignoresSafeArea()
            .onAppear {
                permissionManager.requestPermissions()
            }
        }
    }
    
    private func uuidLabel(for uuid: String) -> String {
        return uuids.first(where: { $0.value == uuid })?.label ?? ""
    }
    
    private func logoutAndReset() {
        username = ""
        dong = ""
        ho = ""
        purpose = ""
        Authorization = ""
        uuid = ""
        loggedIn = false
    }
}

struct ServiceRunningView: View {
    let onLogout: () -> Void
    @ObservedObject var gyroData: GyroDataManager
    
    // CMMotionManager 인스턴스 (실제 센서 데이터를 받아오기 위한)
    @State private var motionManager = CMMotionManager()
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Gyro Data")
                .font(.title)
                .padding()
            Text("x: \(gyroData.x, specifier: "%.3f")")
            Text("y: \(gyroData.y, specifier: "%.3f")")
            Text("z: \(gyroData.z, specifier: "%.3f")")
            
            Button("로그아웃") {
                onLogout()
            }
            .padding()
            .background(Color.red)
            .foregroundColor(.white)
            .cornerRadius(8)
        }
        .padding()
        .onAppear {
            startGyroUpdates()
            print("ServiceRunningView appeared")
        }
        .onDisappear {
            motionManager.stopGyroUpdates()
        }
    }
    
    // Timer 없이 센서 업데이트를 시작하는 함수
    func startGyroUpdates() {
        if motionManager.isGyroAvailable {
            motionManager.gyroUpdateInterval = 1.0 / 6.0
            motionManager.startGyroUpdates(to: OperationQueue.current ?? OperationQueue.main) { data, error in
                if let data = data {
                    // 센서에서 받아온 원시값을 그대로 업데이트
                    self.gyroData.updateGyroData(
                        roll: data.rotationRate.x,
                        pitch: data.rotationRate.y,
                        yaw: data.rotationRate.z
                    )
                } else if let error = error {
                    print("Gyro update error: \(error.localizedDescription)")
                }
            }
        } else {
            print("Gyro not available")
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
