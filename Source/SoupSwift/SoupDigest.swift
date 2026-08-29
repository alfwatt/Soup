import Foundation

public enum SoupDigest {
    public static func allValuesDigest(_ values: [Any]) -> Data {
        let valueHashes = values.map { digestComponent(for: $0) }
        return valueHashes.joined(separator: "+").data(using: .utf8) ?? Data()
    }

    public static func allKeysDigest(_ dictionary: [AnyHashable: Any]) -> Data {
        let keyHashes = dictionary.keys.map { digestComponent(for: $0) }
        return keyHashes.joined(separator: "+").data(using: .utf8) ?? Data()
    }

    public static func allKeysAndValuesDigest(_ dictionary: [AnyHashable: Any]) -> Data {
        let keysDigest = allKeysDigest(dictionary)
        let valuesDigest = allValuesDigest(Array(dictionary.values))
        var digest = Data()
        digest.append(keysDigest)
        digest.append(Data(":".utf8))
        digest.append(valuesDigest)
        return digest
    }
}

private func digestComponent(for value: Any) -> String {
    let object = value as AnyObject
    let classHash = ObjectIdentifier(type(of: object)).hashValue
    let valueHash = object.hash
    return "\(classHash)-\(valueHash)"
}
