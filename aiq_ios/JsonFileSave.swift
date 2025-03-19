import Foundation

class JsonFileSave {
    /// JSON 데이터를 파일로 저장하는 함수 (오류 메시지 포함)
    static func saveJson(filename: String, jsonObject: Any, errorPointer: String) {
        // 에러가 발생한 경우 에러에 대한 갯수를 저장시키도록 한다
        GlobalManager.shared.sharedValue += 1
        
        // 원본 jsonObject와 에러 메시지를 함께 담을 wrapper dictionary 생성
        let wrapper: [String: Any] = [
            "error": errorPointer,
            "data": jsonObject
        ]
        
        // Documents 디렉토리 URL 가져오기
        guard let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            print("문서 디렉토리를 찾을 수 없습니다.")
            return
        }
        
        // 파일명에 .json 확장자 추가 (예: "data.json")
        let fileURL = documentsDirectory.appendingPathComponent(filename).appendingPathExtension("json")
        
        do {
            // wrapper dictionary를 Data 타입으로 변환 (옵션: prettyPrinted)
            let data = try JSONSerialization.data(withJSONObject: wrapper, options: .prettyPrinted)
            // 변환된 데이터를 파일에 기록 (atomic 옵션 사용)
            try data.write(to: fileURL, options: .atomic)
            
            // 성공 로그 출력
            print("JSON 파일이 성공적으로 저장되었습니다: \(fileURL)")
            print("저장된 파일 크기: \(data.count) 바이트")
            if let jsonString = String(data: data, encoding: .utf8) {
                print("저장된 JSON 내용:\n\(jsonString)")
            }
        } catch {
            print("JSON 파일 저장 중 에러 발생: \(error.localizedDescription)")
        }
    }
    
    /// 저장된 JSON 파일을 읽어와 JSON 객체로 변환하는 함수
    static func loadJson(filename: String) -> Any? {
        guard let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            print("문서 디렉토리를 찾을 수 없습니다.")
            return nil
        }
        
        let fileURL = documentsDirectory.appendingPathComponent(filename).appendingPathExtension("json")
        
        do {
            // 파일로부터 데이터를 읽어옴
            let data = try Data(contentsOf: fileURL)
            // Data를 JSON 객체로 변환
            let jsonObject = try JSONSerialization.jsonObject(with: data, options: [])
            print("JSON 파일을 성공적으로 불러왔습니다: \(fileURL)")
            print("불러온 파일 크기: \(data.count) 바이트")
            return jsonObject
        } catch {
            print("JSON 파일 로드 중 에러 발생: \(error.localizedDescription)")
            return nil
        }
    }
    
    /// Documents 디렉토리에서 지정된 이름의 JSON 파일이 존재하면 삭제하는 함수
    static func deleteJson(filename: String) {
        guard let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            print("문서 디렉토리를 찾을 수 없습니다.")
            return
        }
        
        let fileURL = documentsDirectory.appendingPathComponent(filename).appendingPathExtension("json")
        
        if FileManager.default.fileExists(atPath: fileURL.path) {
            do {
                try FileManager.default.removeItem(at: fileURL)
                print("파일이 성공적으로 삭제되었습니다: \(fileURL.lastPathComponent)")
            } catch {
                print("파일 삭제 실패: \(error.localizedDescription)")
            }
        } else {
            print("삭제할 파일이 존재하지 않습니다: \(fileURL.lastPathComponent)")
        }
    }
    
    /// "file.json" 파일이 존재하는지 체크하는 함수 (존재하면 true, 아니면 false 리턴)
    static func isFileJsonExists() -> Bool {
        guard let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            print("문서 디렉토리를 찾을 수 없습니다.")
            return false
        }
         
        let fileURL = documentsDirectory.appendingPathComponent("file").appendingPathExtension("json")
        return FileManager.default.fileExists(atPath: fileURL.path)
    }
}
