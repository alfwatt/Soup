import Foundation
import CryptoKit

public enum SoupDigest {
    public static func allValuesDigest(_ values: [Any]) -> Data {
        let valueHashes = values.map { digestComponent(for: $0) }
        return sha256(encodedDigestData(from: valueHashes))
    }

    public static func allKeysDigest(_ dictionary: [AnyHashable: Any]) -> Data {
        let keyHashes = orderedKeys(for: dictionary).map { digestComponent(for: $0) }
        return sha256(encodedDigestData(from: keyHashes))
    }

    public static func allKeysAndValuesDigest(_ dictionary: [AnyHashable: Any]) -> Data {
        let keysDigest = allKeysDigest(dictionary)
        let valuesDigest = allValuesDigest(orderedValues(for: dictionary))
        var digest = Data()
        appendChunk(keysDigest, to: &digest)
        appendChunk(valuesDigest, to: &digest)
        return sha256(digest)
    }

    static func alias(for digest: Data) -> SoupAlias {
        precondition(digest.count >= 16, "A SoupAlias requires at least 124 digest bits")

        var prefix = Array(digest.prefix(16))
        prefix[15] &= 0xF0
        guard let alias = URL(string: "alias:\(base58Encode(prefix, paddedTo: 22))") else {
            preconditionFailure("Unable to create SoupAlias URL")
        }
        return alias
    }
}

private func sha256(_ data: Data) -> Data {
    Data(SHA256.hash(data: data))
}

private func base58Encode(_ bytes: [UInt8], paddedTo length: Int) -> String {
    let alphabet = Array("123456789ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz")
    var digits: [UInt8] = []

    for byte in bytes {
        var carry = Int(byte)
        for index in digits.indices {
            carry += Int(digits[index]) << 8
            digits[index] = UInt8(carry % 58)
            carry /= 58
        }
        while carry > 0 {
            digits.append(UInt8(carry % 58))
            carry /= 58
        }
    }

    let encoded = String(digits.reversed().map { alphabet[Int($0)] })
    return String(repeating: "1", count: length - encoded.count) + encoded
}

private func encodedDigestData(from components: [Data]) -> Data {
    var digest = Data()
    for component in components {
        appendChunk(component, to: &digest)
    }
    return digest
}

private func appendChunk(_ chunk: Data, to digest: inout Data) {
    var chunkLength = UInt64(chunk.count).bigEndian
    withUnsafeBytes(of: &chunkLength) { rawBuffer in
        digest.append(rawBuffer.bindMemory(to: UInt8.self))
    }
    digest.append(chunk)
}

private func orderedKeys(for dictionary: [AnyHashable: Any]) -> [AnyHashable] {
    dictionary.keys.sorted {
        canonicalOrderingString(for: $0) < canonicalOrderingString(for: $1)
    }
}

private func orderedValues(for dictionary: [AnyHashable: Any]) -> [Any] {
    orderedKeys(for: dictionary).compactMap { dictionary[$0] }
}

private func canonicalValueData(for value: Any) -> Data {
    if let string = value as? String {
        return Data(string.utf8)
    }

    if let number = value as? NSNumber {
        return Data(number.stringValue.utf8)
    }

    if let date = value as? Date {
        return Data(
            String(
            format: "%.9f",
            locale: Locale(identifier: "en_US_POSIX"),
            date.timeIntervalSinceReferenceDate
            ).utf8
        )
    }

    if let data = value as? Data {
        return data
    }

    return Data(String(describing: value).utf8)
}

private func canonicalOrderingString(for value: Any) -> String {
    canonicalValueData(for: value).base64EncodedString()
}

private func digestComponent(for value: Any) -> Data {
    let className = String(describing: type(of: value))
    let valueData = canonicalValueData(for: value)
    var component = Data()
    appendChunk(Data(className.utf8), to: &component)
    appendChunk(valueData, to: &component)
    return component
}
