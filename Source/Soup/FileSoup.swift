import Foundation

@objc(ILFileSoup)
@objcMembers
open class FileSoup: SoupStock {
    public let filePath: String

    public required init(name soupName: String) {
        self.filePath = soupName
        super.init(name: soupName)
    }

    public init(filePath: String) {
        self.filePath = filePath
        super.init(name: URL(fileURLWithPath: filePath).lastPathComponent)
    }

    public class func fileSoup(atPath filePath: String) -> FileSoup {
        FileSoup(filePath: filePath)
    }

    /// write the soup to its file
    public func save() throws {
        try write(to: URL(fileURLWithPath: filePath))
    }

    /// add the entries of the soup's file, if there is one
    public func load() throws {
        guard FileManager.default.fileExists(atPath: filePath) else { return }
        try read(from: URL(fileURLWithPath: filePath))
    }
}

// MARK: - Persistence

/// a soup's file isn't one Soup wrote, or a version it can't read
public enum SoupFileError: Error {
    case notASoup
    case unsupportedVersion(Int)
}

/// A soup's file is a binary property list of its entries, every version, oldest first, and of each sequence's values for each
/// entry identity, which keep the history of versions pruned before it was written, the soup reading it rebuilds its own indices
/// and sequences, values which aren't property list types, URLs or UUIDs are left out, and no classes are unarchived
extension SoupStock {

    static let fileVersion = 1
    private static let versionKey = "soup.file.version"
    private static let nameKey = "soup.file.name"
    private static let entriesKey = "soup.file.entries"
    private static let sequencesKey = "soup.file.sequences"
    private static let hashKey = "soup.file.hash"
    private static let keysKey = "soup.file.keys"
    private static let urlKey = "soup.file.url"
    private static let uuidKey = "soup.file.uuid"

    /// @returns the soup as a property list, with the number of values left out, which a property list can't have
    @nonobjc public func soupData() throws -> (data: Data, omitted: Int) {
        var omitted = 0
        let all = querySoup(NSPredicate(value: true))
        let entries = all.entries(in: NSRange(location: 0, length: all.count)).sorted {
            SoupStock.entryDate($0) < SoupStock.entryDate($1)
        }
        let savedEntries: [[String: Any]] = entries.map { entry in
            [SoupStock.hashKey: entry.entryHash.absoluteString,
             SoupStock.keysKey: entry.entryKeys.compactMapValues { SoupStock.encode($0, omitted: &omitted) }]
        }
        var sequences: [String: [String: [[Any]]]] = [:]
        for case let sequence as StockSequence in soupSequences {
            var timelines: [String: [[Any]]] = [:]
            for identity in sequence.timelineIdentities {
                timelines[identity] = sequence.timeline(for: identity).map { [$0.date, $0.value] }
            }
            sequences[sequence.sequencePath] = timelines
        }
        let file: [String: Any] = [SoupStock.versionKey: SoupStock.fileVersion, SoupStock.nameKey: soupName,
                                   SoupStock.entriesKey: savedEntries, SoupStock.sequencesKey: sequences]
        return (try PropertyListSerialization.data(fromPropertyList: file, format: .binary, options: 0), omitted)
    }

    /// write the soup to the file, see soupData()
    public func write(to url: URL) throws {
        try soupData().data.write(to: url, options: .atomic)
    }

    /// add the entries and sequence values of soup data, oldest first, which build the soup's indices and sequences,
    /// each date passes through adjustingDates, e.g. to move recorded data to the present, entries keep their classes
    public func read(_ data: Data, adjustingDates: ((Date) -> Date)? = nil) throws {
        let file = try SoupStock.file(data)
        let adjust = adjustingDates ?? { $0 }
        var aliases: [String: SoupAlias] = [:] // the saved hashes of the entries, and their hashes now, which their dates change
        for saved in file[SoupStock.entriesKey] as? [[String: Any]] ?? [] {
            guard let keys = saved[SoupStock.keysKey] as? [String: Any] else { continue }
            var decoded = keys.mapValues { SoupStock.decode($0, adjust: adjust) }
            if let ancestor = decoded[ILSoupEntryAncestorEntryHash] as? SoupAlias, let now = aliases[ancestor.absoluteString] {
                decoded[ILSoupEntryAncestorEntryHash] = now
            }
            let entryClass = (decoded[ILSoupEntryClassName] as? String).flatMap { NSClassFromString($0) as? MutableSoupEntry.Type }
            let entry = (entryClass ?? StockEntry.self).init(keys: decoded)
            _ = addEntry(entry)
            if let hash = saved[SoupStock.hashKey] as? String {
                aliases[hash] = entry.entryHash
            }
        }
        for (path, timelines) in file[SoupStock.sequencesKey] as? [String: [String: [[Any]]]] ?? [:] {
            guard let sequence = querySequence(path) as? StockSequence else { continue }
            for (identity, values) in timelines {
                let timeline = values.compactMap { pair -> (date: Date, value: NSNumber)? in
                    guard pair.count == 2, let date = pair[0] as? Date, let value = pair[1] as? NSNumber else { return nil }
                    return (adjust(date), value)
                }
                sequence.setTimeline(timeline, for: identity)
            }
        }
        _ = resetCursor()
    }

    /// add the entries of the soup's file, see read(_:adjustingDates:)
    public func read(from url: URL, adjustingDates: ((Date) -> Date)? = nil) throws {
        try read(Data(contentsOf: url), adjustingDates: adjustingDates)
    }

    /// @returns the newest date in soup data, of its entries and sequences, e.g. to move recorded data to the present
    public static func newestDate(in data: Data) throws -> Date? {
        let file = try SoupStock.file(data)
        var newest: Date?
        func visit(_ value: Any) {
            switch value {
            case let date as Date: newest = max(newest ?? date, date)
            case let array as [Any]: array.forEach(visit)
            case let dictionary as [String: Any]: dictionary.values.forEach(visit)
            default: break
            }
        }
        visit(file[SoupStock.entriesKey] ?? [])
        visit(file[SoupStock.sequencesKey] ?? [:])
        return newest
    }

    // MARK: - Private

    private static func file(_ data: Data) throws -> [String: Any] {
        guard let file = try PropertyListSerialization.propertyList(from: data, format: nil) as? [String: Any],
              let version = file[versionKey] as? Int else { throw SoupFileError.notASoup }
        guard version <= fileVersion else { throw SoupFileError.unsupportedVersion(version) }
        return file
    }

    /// the version's date, mutated or created, so ancestors come before their descendants
    private static func entryDate(_ entry: SoupEntry) -> Date {
        (entry.entryKeys[ILSoupEntryMutationDate] as? Date) ?? (entry.entryKeys[ILSoupEntryCreationDate] as? Date) ?? .distantPast
    }

    /// @returns the value as a property list, URLs and UUIDs tagged, nil for anything else, which is counted
    private static func encode(_ value: Any, omitted: inout Int) -> Any? {
        switch value {
        case is String, is Date, is Data:
            return value
        case let number as NSNumber:
            return number
        case let url as URL:
            return [urlKey: url.absoluteString]
        case let uuid as UUID:
            return [uuidKey: uuid.uuidString]
        case let array as [Any]:
            return array.compactMap { encode($0, omitted: &omitted) }
        case let dictionary as [String: Any]:
            return dictionary.compactMapValues { encode($0, omitted: &omitted) }
        default:
            omitted += 1
            return nil
        }
    }

    /// @returns the value from a property list, with its URLs and UUIDs, and its dates adjusted
    private static func decode(_ value: Any, adjust: (Date) -> Date) -> Any {
        switch value {
        case let date as Date:
            return adjust(date)
        case let array as [Any]:
            return array.map { decode($0, adjust: adjust) }
        case let dictionary as [String: Any]:
            if dictionary.count == 1, let url = (dictionary[urlKey] as? String).flatMap(URL.init(string:)) { return url }
            if dictionary.count == 1, let uuid = (dictionary[uuidKey] as? String).flatMap(UUID.init(uuidString:)) { return uuid }
            return dictionary.mapValues { decode($0, adjust: adjust) }
        default:
            return value
        }
    }
}
