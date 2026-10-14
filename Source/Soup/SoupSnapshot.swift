import Foundation

/// SoupSnapshot captures properties of an object into a soup entry, described by a snapshot map:
///
///     ILSoupSnapshotProperties: [                                  // key paths of the object to capture
///         "identifier.UUIDString": [ILSoupSnapshotStorageKey: "uuid",  // stored under a different key
///                                   ILSoupSnapshotValueTransformer: "TransformerName"], // or a ValueTransformer
///         "name": [:]                                              // stored under the key path
///     ],
///     ILSoupEntryClassName: "MyEntry",                             // optional MutableSoupEntry class to create
///     ILSoupSnapshotMatchKeyPath: "identifier.UUIDString"          // optional, identity index used to find the previous entry
///
/// key paths are read with KVC through objects and dictionaries, one component at a time, a component the object
/// doesn't respond to captures nothing instead of raising
@objc(ILSoupSnapshot)
@objcMembers
open class SoupSnapshot: NSObject {
    public let snapshotMap: [String: Any]

    public init(map snapshotMap: [String: Any]) {
        self.snapshotMap = snapshotMap
    }

    private var properties: [String: [String: Any]] {
        (snapshotMap[ILSoupSnapshotProperties] as? [String: [String: Any]]) ?? [:]
    }

    private func storageKey(for keyPath: String) -> String {
        (properties[keyPath]?[ILSoupSnapshotStorageKey] as? String) ?? keyPath
    }

    /// @returns the captured values of the object, keyed by storage key, without adding anything to a soup
    open func capture(_ object: NSObject) -> [String: Any] {
        var capture: [String: Any] = [:]

        for (keyPath, config) in properties {
            var value = valueForSnapshot(from: object, keyPath: keyPath)
            if value != nil, let transformer = valueTransformer(config[ILSoupSnapshotValueTransformer]) {
                value = transformer.transformedValue(value)
            }
            if let value = value, !(value is NSNull) {
                capture[storageKey(for: keyPath)] = value
            }
        }

        return capture
    }

    open func snapshot(_ object: NSObject, in soup: Soup) -> SoupEntry? {
        snapshot(object, in: soup, with: [:])
    }

    /// capture the object, merge in the additional values and add the new version of the entry to the soup
    ///
    /// the previous version is found in the identity index of the match key path's storage key, a new entry
    /// of the ILSoupEntryClassName class is created if there isn't one
    open func snapshot(_ object: NSObject, in soup: Soup, with additional: [String: Any]) -> SoupEntry? {
        var capture = capture(object)
        for (key, value) in additional {
            capture[key] = value
        }

        if let matchKeyPath = snapshotMap[ILSoupSnapshotMatchKeyPath] as? String {
            let matchKey = storageKey(for: matchKeyPath)
            if let matchValue = capture[matchKey],
               let identity = soup.queryIdentityIndex(matchKey),
               let existing = identity.entry(withValue: matchValue) as? MutableSoupEntry {
                let next = existing.mutatedEntry(capture)
                _ = soup.addEntry(next)
                return next
            }
        }

        let blank = entryClass.flatMap { soup.createBlankEntry(ofClass: $0) } ?? soup.createBlankEntry()
        let next = blank.mutatedEntry(capture)
        _ = soup.addEntry(next)
        return next
    }

    // MARK: - Private

    private var entryClass: MutableSoupEntry.Type? {
        guard let className = snapshotMap[ILSoupEntryClassName] as? String else { return nil }
        return NSClassFromString(className) as? MutableSoupEntry.Type
    }

    private func valueTransformer(_ configured: Any?) -> ValueTransformer? {
        if let transformer = configured as? ValueTransformer {
            return transformer
        }
        if let name = configured as? String {
            return ValueTransformer(forName: NSValueTransformerName(rawValue: name))
        }
        return nil
    }

    private func valueForSnapshot(from object: NSObject, keyPath: String) -> Any? {
        if let dictionary = object as? NSDictionary, let value = dictionary[keyPath] { // keys may contain dots
            return value
        }

        var current: Any? = object
        for key in keyPath.split(separator: ".").map(String.init) {
            current = value(of: current, forKey: key)
            if current == nil {
                break
            }
        }
        return current
    }

    private func value(of object: Any?, forKey key: String) -> Any? {
        switch object {
        case let dictionary as NSDictionary:
            return dictionary[key]
        case let nsObject as NSObject where nsObject.responds(to: NSSelectorFromString(key)):
            return nsObject.value(forKey: key)
        case let some?: // Swift objects and structs
            guard let child = Mirror(reflecting: some).children.first(where: { $0.label == key })?.value else { return nil }
            let childMirror = Mirror(reflecting: child)
            return childMirror.displayStyle == .optional ? childMirror.children.first?.value : child
        default:
            return nil
        }
    }
}
