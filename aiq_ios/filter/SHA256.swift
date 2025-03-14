//
//  SHA256.swift
//  SmartParking
//
//  Created by 우리시스템 on 2019. 1. 29..
//  Copyright © 2019년 Sumin Jin. All rights reserved.
//

import CommonCrypto
import Foundation

public enum SHA256 {
    public static func digest(input: NSData) -> NSData {
        let digestLength = HMACAlgorithm.SHA256.digestLength()

//        var hash = [UInt8](count: digestLength, repeatedValue: 0)
        var hash = [UInt8](repeating: 0, count: digestLength)

        CC_SHA256(input.bytes, UInt32(input.length), &hash)

        return NSData(bytes: hash, length: digestLength)
    }

    // Takes a string representation of a hexadecimal number
    public static func hexStringDigest(input: String) -> NSData {
        let data = SHA256.dataFromHexString(input: input)
        return digest(input: data)
    }

    public static func dataFromHexString(input: String) -> NSData {
        // Based on: http://stackoverflow.com/a/2505561/313633
        let data = NSMutableData()

        var string = ""

        for char in input {
            string.append(char)
            if string.count == 2 {
                let scanner = Scanner(string: string)
                var value: CUnsignedInt = 0
                scanner.scanHexInt32(&value)
                data.append(&value, length: 1)
                string = ""
            }
        }

        return data as NSData
    }

    public static func hexStringFromData(input: NSData) -> String {
        let sha256description = input.description as String

        // TODO: more elegant way to convert NSData to a hex string

        var result = ""

        for char in sha256description {
            switch char {
            case "0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "a", "b", "c", "d", "e", "f":
                result.append(char)
            default:
                result += ""
            }
        }
        return result
    }
}

// http://stackoverflow.com/a/24411522/313633
enum HMACAlgorithm {
    case MD5, SHA1, SHA224, SHA256, SHA384, SHA512

    func toCCEnum() -> CCHmacAlgorithm {
        var result = 0
        switch self {
        case .MD5:
            result = kCCHmacAlgMD5
        case .SHA1:
            result = kCCHmacAlgSHA1
        case .SHA224:
            result = kCCHmacAlgSHA224
        case .SHA256:
            result = kCCHmacAlgSHA256
        case .SHA384:
            result = kCCHmacAlgSHA384
        case .SHA512:
            result = kCCHmacAlgSHA512
        }
        return CCHmacAlgorithm(result)
    }

    func digestLength() -> Int {
        var result: CInt = 0
        switch self {
        case .MD5:
            result = CC_MD5_DIGEST_LENGTH
        case .SHA1:
            result = CC_SHA1_DIGEST_LENGTH
        case .SHA224:
            result = CC_SHA224_DIGEST_LENGTH
        case .SHA256:
            result = CC_SHA256_DIGEST_LENGTH
        case .SHA384:
            result = CC_SHA384_DIGEST_LENGTH
        case .SHA512:
            result = CC_SHA512_DIGEST_LENGTH
        }
        return Int(result)
    }
}
