import Foundation

public enum SoupDigest {
    public static func allValuesDigest(_ values: [Any]) -> Data {
        let valueHashes = values.map { digestComponent(for: $0) }
        return encodedDigestData(from: valueHashes)
    }

    public static func allKeysDigest(_ dictionary: [AnyHashable: Any]) -> Data {
        let keyHashes = orderedKeys(for: dictionary).map { digestComponent(for: $0) }
        return encodedDigestData(from: keyHashes)
    }

    public static func allKeysAndValuesDigest(_ dictionary: [AnyHashable: Any]) -> Data {
        let keysDigest = allKeysDigest(dictionary)
        let valuesDigest = allValuesDigest(orderedValues(for: dictionary))
        var digest = Data()
        appendChunk(keysDigest, to: &digest)
        appendChunk(valuesDigest, to: &digest)
        return digest
    }
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
