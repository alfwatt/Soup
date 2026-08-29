import Foundation

public enum SoupDigest {
    public static func allValuesDigest(_ values: [Any]) -> Data {
        let valueHashes = values.map { digestComponent(for: $0) }
        return valueHashes.joined(separator: "+").data(using: .utf8) ?? Data()
    }

    public static func allKeysDigest(_ dictionary: [AnyHashable: Any]) -> Data {
        let keyHashes = orderedKeys(for: dictionary).map { digestComponent(for: $0) }
        return keyHashes.joined(separator: "+").data(using: .utf8) ?? Data()
    }

    public static func allKeysAndValuesDigest(_ dictionary: [AnyHashable: Any]) -> Data {
        let keysDigest = allKeysDigest(dictionary)
        let valuesDigest = allValuesDigest(orderedValues(for: dictionary))
        var digest = Data()
        digest.append(keysDigest)
        digest.append(Data(":".utf8))
        digest.append(valuesDigest)
        return digest
    }
}

private func orderedKeys(for dictionary: [AnyHashable: Any]) -> [AnyHashable] {
    dictionary.keys.sorted {
        canonicalString(for: $0) < canonicalString(for: $1)
    }
}

private func orderedValues(for dictionary: [AnyHashable: Any]) -> [Any] {
    orderedKeys(for: dictionary).compactMap { dictionary[$0] }
}

private func canonicalString(for value: Any) -> String {
    if let string = value as? String {
        return string
    }

    if let number = value as? NSNumber {
        return number.stringValue
    }

    if let date = value as? Date {
        return String(date.timeIntervalSinceReferenceDate)
    }

    if let data = value as? Data {
        return data.base64EncodedString()
    }

    return String(describing: value)
}

private func digestComponent(for value: Any) -> String {
    let className = String(describing: type(of: value))
    return "\(className)-\(canonicalString(for: value))"
}
