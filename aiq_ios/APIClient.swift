import Foundation

enum APIError: Error {
    case invalidURL
    case noData
    case invalidResponseFormat
}

class APIClient {
    static let shared = APIClient()
    
    /// 센서 데이터(Location JSON)를 /calcLocation 엔드포인트로 전송하는 함수
    /// - Parameters:
    ///   - locationData: Location 객체에 해당하는 JSON 딕셔너리 (예: PhoneInfo, InputDate, ParingState, Sensors, Beacons, Gyros, AccelBeacons 등)
    ///   - userId: URL 쿼리 파라미터로 전달할 사용자 ID
    ///   - dong: URL 쿼리 파라미터로 전달할 동 정보
    ///   - ho: URL 쿼리 파라미터로 전달할 호 정보
    ///   - completion: 요청 결과를 반환하는 completion handler. 성공 시 JSON 딕셔너리, 실패 시 에러 반환.
    func sendCalcLocationRequest(locationData: [String: Any],
                                 userId: String,
                                 dong: String,
                                 ho: String,
                                 completion: @escaping (Result<[String: Any], Error>) -> Void)
    {
        // URL 구성: 쿼리 파라미터를 포함한 URL 생성
        guard var components = URLComponents(string: "http://192.168.0.75:8080/pms-server-web/app/calcLocation") else {
            completion(.failure(APIError.invalidURL))
            return
        }
        components.queryItems = [
            URLQueryItem(name: "userId", value: userId),
            URLQueryItem(name: "dong", value: dong),
            URLQueryItem(name: "ho", value: ho)
        ]
        guard let url = components.url else {
            completion(.failure(APIError.invalidURL))
            return
        }
        
        // URLRequest 생성 및 HTTP 메서드, 헤더 설정
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        
        // 요청 본문에 locationData를 JSON 데이터로 인코딩
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: locationData, options: [])
            request.httpBody = jsonData
        } catch {
            completion(.failure(error))
            return
        }
        
        // API 호출 실행
        let task = URLSession.shared.dataTask(with: request) { data, _, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            guard let data = data else {
                completion(.failure(APIError.noData))
                return
            }
            do {
                if let jsonResponse = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                    completion(.success(jsonResponse))
                } else {
                    completion(.failure(APIError.invalidResponseFormat))
                }
            } catch {
                completion(.failure(error))
            }
        }
        task.resume()
    }
}
