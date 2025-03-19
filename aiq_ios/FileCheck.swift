import Foundation

class FileCheck {
    /// JSON 데이터를 파일로 저장하는 함수 (오류 메시지 포함)
    static func filecheck() {
        // Documents 디렉토리 내의 "file.json" 파일 존재 여부 확인
        if let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            let fileURL = documentsDirectory.appendingPathComponent("file").appendingPathExtension("json")
            if FileManager.default.fileExists(atPath: fileURL.path) {
                print("저장된 파일이 존재합니다: \(fileURL.lastPathComponent)")
                // 저장된 파일이 있으면 파일을 삭제하도록 한다.
                do {
                    try FileManager.default.removeItem(at: fileURL)
                    print("파일을 성공적으로 삭제했습니다.")
                } catch {
                    print("파일 삭제에 실패했습니다: \(error.localizedDescription)")
                }
            } else {
                print("저장된 파일이 없습니다.")
            }
        }
    }
}
