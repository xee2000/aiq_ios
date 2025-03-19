//
//  Api.swift
//  aiq_ios
//
//  Created by 이정호 on 3/19/25.
//

import Foundation

class Api {
    @objc func RestApi(userId: String, dong: String, ho: String, phoneInfo: String, collectSensor: CollectSensor,
                       errorcode: Int)
    {
        print("Phone Info: \(phoneInfo)")
        print("collectDataDic before sending: \(collectSensor.collectDataDic)") // 전송 직전 상태 확인

        guard let url = URL(string: "https://woorisys2022.iptime.org:7777/pms-server-web/app/calcLocation?userId=\(userId)&dong=\(dong)&ho=\(ho)&errorcode=\(errorcode)") else {
            print("Invalid URL: https://221.158.214.211:24999/pms-server-web/app/calcLocation?userId=\(userId)&dong=\(dong)&ho=\(ho)")
            return
        }

        var request = URLRequest(url: url)
//        var errorrequest = URLRequest(url: errorurl)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        var payload = collectSensor.collectDataDic

        do {
            let jsonData = try JSONSerialization.data(withJSONObject: payload, options: [])
            request.httpBody = jsonData
            print("Payload JSON: \(payload)")
        } catch {
            print("Error encoding JSON: \(error.localizedDescription)")
            return
        }
    }
}
