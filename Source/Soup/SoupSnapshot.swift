import Foundation

@objc(ILSoupSnapshot)
@objcMembers
open class SoupSnapshot: NSObject {
    public let snapshotMap: [String: Any]

    public init(map snapshotMap: [String: Any]) {
        self.snapshotMap = snapshotMap
    }

    open func snapshot(_ object: NSObject, in soup: Soup) -> SoupEntry? {
        let properties = (snapshotMap[ILSoupSnapshotProperties] as? [String: [String: Any]]) ?? [:]
        var capture: [String: Any] = [:]

        for (keyPath, config) in properties {
            let storageKey = (config[ILSoupSnapshotStorageKey] as? String) ?? keyPath
            let value = valueForSnapshot(from: object, keyPath: keyPath)
            if let value {
                capture[storageKey] = value
            }
        }

        if let matchKeyPath = snapshotMap[ILSoupSnapshotMatchKeyPath] as? String,
           let matchValue = valueForSnapshot(from: object, keyPath: matchKeyPath),
           let identity = soup.queryIdentityIndex(matchKeyPath),
           let existing = identity.entry(withValue: matchValue) as? MutableSoupEntry {
            let next = existing.mutatedEntry(capture)
            _ = soup.addEntry(next)
            return next
        }

        let next = soup.createBlankEntry().mutatedEntry(capture)
        _ = soup.addEntry(next)
        return next
    }

    private func valueForSnapshot(from object: NSObject, keyPath: String) -> Any? {
        if let dictionary = object as? NSDictionary {
            return dictionary[keyPath]
        }
        let mirror = Mirror(reflecting: object)
        return mirror.children.first(where: { $0.label == keyPath })?.value
    }
}
