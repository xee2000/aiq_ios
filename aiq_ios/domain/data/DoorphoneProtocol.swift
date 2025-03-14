//
//  DoorphoneProtocol.swift
//  cordoba_aiq
//
//  Created by Sun,Kim on 9/26/24.
//
import Foundation

class DoorphoneProtocol: NSObject {
    private let TAG: String = "DoorphoneProtocol --"
  
    private let STX: UInt8 = 0x02
    private let ETX: UInt8 = 0x0d
    private let SECURE_KEY_COMMAND = 0x76
    private let SEND_COMMAND = 0x43
    private let BLE_AES_KEY_DATA = "cRfUjWnZr4u7x!A%"
    private let BLE_AES_IV_DATA = "g6064257AGd2wfsa"
  
    var _command: DoorphoneProtocolType = .SECURE_KEY
    var command: DoorphoneProtocolType {
        get {
            return _command
        }
        set {
            _command = newValue
        }
    }
  
    var _secureKey: String = ""
    var secureKey: String {
        get {
            return _secureKey
        }
        set {
            _secureKey = newValue
        }
    }
  
    var _data: String = ""
    var data: String {
        get {
            return _data
        }
        set {
            _data = newValue
        }
    }
  
    func fromByteCode(_ values: [UInt8]?) {
        guard values != nil else { return }
        if values!.count < 5 || values?[0] != STX || values?[values!.count - 1] != ETX {
            command = .ERROR
            return
        }
    
        // Length check
        let length = Int(String(data: Data([values![1], values![2]]), encoding: .utf8)!, radix: 16)
        // Length = STX(1) + length(2) + (COMMAND(1) + DATA) + ETX(1)
        if values!.count != 1 + 2 + length! + 1 {
            command = .ERROR
            return
        }
    
        // Command
        if values![3] == SECURE_KEY_COMMAND {
            command = .SECURE_KEY
            if length! > 1 {
                // Secure Key
                let encryptedSecureKey = Array(values![4..<4 + length! - 1])
                // 암호화된 SecureKey를 Decryp해야 함.
                let decryptedSecureKey = Data(encryptedSecureKey).aesDecrypt(key: BLE_AES_KEY_DATA, iv: BLE_AES_IV_DATA, type: .aes128, options: 0)
                if decryptedSecureKey != nil {
                    secureKey = String(data: decryptedSecureKey!, encoding: .utf8) ?? ""
                }
            } else {
                secureKey = ""
            }
        } else {
            command = .ERROR
            data = ""
            let receivedValues = Array(values![3..<3 + length!])
      
            var decryptedValues: Data?
            // 전체가 암호화 되어 있어서 전체를 Decryt해야 함.
            if secureKey.isEmpty {
                decryptedValues = Data(receivedValues)
            } else {
                decryptedValues = Data(receivedValues).aesDecrypt(key: secureKey, iv: BLE_AES_IV_DATA, type: .aes128, options: 0)
                if decryptedValues == nil {
                    return
                }
            }
      
            if decryptedValues![0] == SEND_COMMAND {
                command = .SEND_COMMAND
            }
            // Remove tailing 0x00
            let arraySize = decryptedValues!.count
      
            for index in stride(from: arraySize - 1, to: 0, by: -1) {
                if decryptedValues![index] != 0x00 {
                    break
                }
                decryptedValues!.removeLast()
            }
      
            // Remove Command
            decryptedValues?.removeFirst()
      
            // Make String
            data = String(bytes: decryptedValues!, encoding: .utf8)!
        }
    }
  
    func getSendProtocol(_ value: String) -> [UInt8]? {
        var sendArray: [UInt8] = []
    
        for chunk in value.chunks(16) {
            let splitArray = Array(chunk.utf8).padding(repeating: 0x00, inLength: 16)
      
            if secureKey.isEmpty {
                sendArray = sendArray + splitArray
            } else {
                let encryptedData = Data(splitArray).aesEncrypt(key: secureKey, iv: BLE_AES_IV_DATA, type: .aes128, options: 0)
                sendArray = sendArray + encryptedData!
            }
        }
    
        let length = Array(String(format: "%02hhx", sendArray.count).utf8)
    
        var bytesArray: [UInt8] = []
        bytesArray.append(0x02)
        bytesArray = bytesArray + length
        bytesArray = bytesArray + sendArray
        bytesArray.append(0x0d)
    
        return bytesArray
    }
}

extension String {
    func chunks(_ size: Int) -> [String] {
        stride(from: 0, to: count, by: size).map {
            let i0 = self.index(self.startIndex, offsetBy: $0)
            let i1 = self.index(self.startIndex, offsetBy: min($0 + size, self.count))
            return "\(self[i0..<i1])"
        }
    }
}

extension Array {
    func padding(repeating element: Element, inLength length: Int) -> [Element] {
        guard count < length else { return self }
    
        let paddingCount = length - count
        let result = self + Array(repeating: element, count: paddingCount)
        return result
    }
}

extension Array where Element == UInt8 {
    func hexEncodedString() -> String {
        var hexString = ""
        var count = self.count
        for byte in self {
            hexString.append(String(format: "%02hhx", byte))
            count = count - 1
            if count > 0 {
                hexString.append(", ")
            }
        }
        return hexString
    }
}
