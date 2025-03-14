//
//  AESSwift.swift
//  cordoba_aiq
//
//  Created by Sun,Kim on 10/10/24.
//

import CommonCrypto
import Foundation

public extension Data {
    var bytes: [UInt8] {
        Array(self)
    }
}

@objc public enum AESType: Int {
    case aes128
    case aes192
    case aes256
  
    var keyLength: Int {
        switch self {
            case .aes128: return 16
            case .aes192: return 24
            case .aes256: return 32
        }
    }
}

public extension NSData {
    @objc func aesEncrypt(key: String, iv: String = "", type: AESType = .aes256, options: Int = kCCOptionPKCS7Padding) -> NSData? {
        let paddingKey = key.padding(toLength: type.keyLength, withPad: "0", startingAt: 0)
    
        if let keyData = paddingKey.data(using: String.Encoding.utf8),
           let cryptData = NSMutableData(length: Int(self.count) + kCCBlockSizeAES128)
        {
            let keyLength = size_t(paddingKey.count)
            let operation: CCOperation = UInt32(kCCEncrypt)
            let algoritm: CCAlgorithm = UInt32(kCCAlgorithmAES128)
            let options: CCOptions = UInt32(options)
      
            var numBytesEncrypted: size_t = 0
      
            let cryptStatus: CCCryptorStatus = CCCrypt(operation,
                                                       algoritm,
                                                       options,
                                                       keyData.bytes,
                                                       keyLength,
                                                       (iv.count > 0) ? iv : nil,
                                                       self.bytes,
                                                       self.count,
                                                       cryptData.mutableBytes,
                                                       cryptData.length,
                                                       &numBytesEncrypted)
      
            guard cryptStatus == CCCryptorStatus(kCCSuccess) else {
                return nil
            }
      
            cryptData.length = Int(numBytesEncrypted)
            return cryptData
        }
    
        return nil
    }
  
    @objc func aesDecrypt(key: String, iv: String = "", type: AESType = .aes256, options: Int = kCCOptionPKCS7Padding) -> NSData? {
        let paddingKey = key.padding(toLength: type.keyLength, withPad: "0", startingAt: 0)
    
        if let keyData = paddingKey.data(using: String.Encoding.utf8),
           let cryptData = NSMutableData(length: Int(self.count) + kCCBlockSizeAES128)
        {
            let keyLength = size_t(paddingKey.count)
            let operation: CCOperation = UInt32(kCCDecrypt)
            let algoritm: CCAlgorithm = UInt32(kCCAlgorithmAES128)
            let options: CCOptions = UInt32(options)
      
            var numBytesEncrypted: size_t = 0
      
            let cryptStatus: CCCryptorStatus = CCCrypt(operation,
                                                       algoritm,
                                                       options,
                                                       keyData.bytes,
                                                       keyLength,
                                                       (iv.count > 0) ? iv : nil,
                                                       self.bytes,
                                                       self.count,
                                                       cryptData.mutableBytes,
                                                       cryptData.length,
                                                       &numBytesEncrypted)
      
            guard cryptStatus == CCCryptorStatus(kCCSuccess) else {
                return nil
            }
      
            cryptData.length = Int(numBytesEncrypted)
            return cryptData
        }
    
        return nil
    }
}

public extension Data {
    func aesEncrypt(key: String, iv: String = "", type: AESType = .aes256, options: Int = kCCOptionPKCS7Padding) -> Data? {
        return NSData(data: self).aesEncrypt(key: key, iv: iv, type: type, options: options) as? Data
    }
  
    func aesDecrypt(key: String, iv: String = "", type: AESType = .aes256, options: Int = kCCOptionPKCS7Padding) -> Data? {
        return NSData(data: self).aesDecrypt(key: key, iv: iv, type: type, options: options) as? Data
    }
}
