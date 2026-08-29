import Foundation
import CoreGraphics

public let ILSoupEntryIdentityUUID = "soup.entry.uuid"
public let ILSoupEntryCreationDate = "soup.entry.created"
public let ILSoupEntryHash = "soup.entry.hash"
public let ILSoupEntryDataHash = "soup.entry.dataHash"
public let ILSoupEntryKeysHash = "soup.entry.keysHash"
public let ILSoupEntryClassName = "soup.entry.className"
public let ILSoupEntryDuplicateUUID = "soup.entry.duplicate.uuid"
public let ILSoupEntryAncestorEntryHash = "soup.entry.ancestor.hash"
public let ILSoupEntryMutationDate = "soup.entry.mutated"

public let ILSoupSnapshotProperties = "Properties"
public let ILSoupSnapshotStorageKey = "StorageKeyPath"
public let ILSoupSnapshotValueTransformer = "ValueTransformer"
public let ILSoupSnapshotMatchKeyPath = "MatchKeyPath"

public protocol ILSoupEntry: AnyObject, NSCopying, NSMutableCopying {
    var entryHash: String { get }
    var dataHash: String { get }
    var keysHash: String { get }
    var entryKeys: [String: Any] { get }
    var sortedEntryKeys: [String] { get }
}

public protocol ILMutableSoupEntry: ILSoupEntry {
    init()
    init(keys: [String: Any])
    func mutatedEntry(_ mutatedValues: [String: Any]) -> Self
    func duplicateEntry() -> Self
}

public extension ILMutableSoupEntry {
    func duplicate() -> Self {
        duplicateEntry()
    }
}

@objcMembers
open class ILStockEntry: NSObject, ILMutableSoupEntry {
    private var storage: [String: Any]

    public required override init() {
        let identity = UUID().uuidString
        storage = [
            ILSoupEntryIdentityUUID: identity,
            ILSoupEntryCreationDate: Date(),
            ILSoupEntryClassName: NSStringFromClass(Self.self)
        ]
        super.init()
    }

    public required init(keys: [String: Any]) {
        storage = keys
        super.init()
    }

    public class func soupEntry(withKeys entryKeys: [String: Any]) -> Self {
        self.init(keys: entryKeys)
    }

    open var entryKeys: [String: Any] { storage }

    open var sortedEntryKeys: [String] { storage.keys.sorted() }

    open var keysHash: String {
        SoupDigest.allKeysDigest(storage).base64EncodedString()
    }

    open var dataHash: String {
        let dataKeys = storage
            .filter { key, _ in !key.hasPrefix("soup.entry.") }
            .map { $0.value }
        return SoupDigest.allValuesDigest(dataKeys).base64EncodedString()
    }

    open var entryHash: String {
        SoupDigest.allKeysAndValuesDigest(storage).base64EncodedString()
    }

    open func copy(with zone: NSZone? = nil) -> Any {
        Self.init(keys: storage)
    }

    open func mutableCopy(with zone: NSZone? = nil) -> Any {
        Self.init(keys: storage)
    }

    open func propertyMutations() -> [String: Any]? {
        nil
    }

    open func entryWithPropertyMutations() -> Self {
        if let mutations = propertyMutations() {
            return mutatedEntry(mutations)
        }
        return Self.init(keys: storage)
    }

    open func mutatedEntry(_ mutatedValues: [String: Any]) -> Self {
        var next = storage
        for (key, value) in mutatedValues {
            next[key] = value
        }
        next[ILSoupEntryAncestorEntryHash] = entryHash
        next[ILSoupEntryMutationDate] = Date()
        next[ILSoupEntryClassName] = NSStringFromClass(Self.self)
        return Self.init(keys: next)
    }

    open func duplicateEntry() -> Self {
        var next = storage
        let previous = (storage[ILSoupEntryIdentityUUID] as? String) ?? UUID().uuidString
        next[ILSoupEntryDuplicateUUID] = previous
        next[ILSoupEntryIdentityUUID] = UUID().uuidString
        next[ILSoupEntryClassName] = NSStringFromClass(Self.self)
        return Self.init(keys: next)
    }

    open func duplicate() -> Self {
        duplicateEntry()
    }
}

public protocol ILSoupCursor: AnyObject {
    var entries: [ILSoupEntry] { get }
    var index: UInt { get }
    var count: Int { get }
    func nextEntry() -> ILSoupEntry?
    func resetCursor()
    func entry(at entryIndex: UInt) -> ILSoupEntry
    func entries(in entryRange: NSRange) -> [ILSoupEntry]
}

open class ILStockCursor: ILSoupCursor {
    public static let sharedEmpty = ILStockCursor(entries: [])
    public private(set) var entries: [ILSoupEntry]
    public private(set) var index: UInt = 0
    public var count: Int { entries.count }

    public class func emptyCursor() -> Self {
        self.init(entries: [])
    }

    public required init(entries: [ILSoupEntry]) {
        self.entries = entries
    }

    open func nextEntry() -> ILSoupEntry? {
        let i = Int(index)
        guard i < entries.count else { return nil }
        defer { index += 1 }
        return entries[i]
    }

    open func resetCursor() {
        index = 0
    }

    open func entry(at entryIndex: UInt) -> ILSoupEntry {
        entries[Int(entryIndex)]
    }

    open func entries(in entryRange: NSRange) -> [ILSoupEntry] {
        guard entryRange.location < entries.count else { return [] }
        let end = min(entries.count, entryRange.location + entryRange.length)
        return Array(entries[entryRange.location..<end])
    }
}

open class ILStockAliasCursor: ILSoupCursor {
    private let aliases: [String]
    private weak var sourceSoup: ILSoup?
    private let fallbackEntries: [ILSoupEntry]
    public private(set) var index: UInt = 0
    public var count: Int { aliases.count }
    public var entries: [ILSoupEntry] {
        aliases.compactMap { sourceSoup?.gotoAlias($0) }
    }

    public init(aliases: [String], inSoup sourceSoup: ILSoup?) {
        self.aliases = aliases
        self.sourceSoup = sourceSoup
        self.fallbackEntries = aliases.compactMap { sourceSoup?.gotoAlias($0) }
    }

    public func nextAlias() -> String? {
        let i = Int(index)
        guard i < aliases.count else { return nil }
        defer { index += 1 }
        return aliases[i]
    }

    open func nextEntry() -> ILSoupEntry? {
        if let alias = nextAlias() {
            return sourceSoup?.gotoAlias(alias)
        }
        return nil
    }

    open func resetCursor() {
        index = 0
    }

    open func entry(at entryIndex: UInt) -> ILSoupEntry {
        entries[Int(entryIndex)]
    }

    open func entries(in entryRange: NSRange) -> [ILSoupEntry] {
        guard entryRange.location < fallbackEntries.count else { return [] }
        let end = min(fallbackEntries.count, entryRange.location + entryRange.length)
        return Array(fallbackEntries[entryRange.location..<end])
    }
}

public protocol ILSoupTime: AnyObject {
    static func earlier() -> ILSoupTime
    static func earlierThan(_ latest: Date) -> ILSoupTime
    static func later() -> ILSoupTime
    static func laterThan(_ earliest: Date) -> ILSoupTime
    static func anytime() -> ILSoupTime
    static func whenever() -> ILSoupTime
    static func never() -> ILSoupTime
    static func interval(_ seconds: TimeInterval, before latest: Date) -> ILSoupTime
    static func interval(_ seconds: TimeInterval, around center: Date) -> ILSoupTime
    static func interval(_ seconds: TimeInterval, after earliest: Date) -> ILSoupTime
    static func recently() -> ILSoupTime
    static func nowish() -> ILSoupTime
    static func soonish() -> ILSoupTime
    static func today() -> ILSoupTime
    static func thisMonth() -> ILSoupTime
    static func thisYear() -> ILSoupTime
    static func lastYear() -> ILSoupTime
    static func lastDecade() -> ILSoupTime
    static func lastCentury() -> ILSoupTime
    static func lastMillennium() -> ILSoupTime
    static func nextYear() -> ILSoupTime
    static func nextDecade() -> ILSoupTime
    static func nextCentury() -> ILSoupTime
    static func nextMillennium() -> ILSoupTime
    var earliest: Date { get }
    var latest: Date { get }
    init(earliest: Date, andLatest latest: Date)
    func interval() -> TimeInterval
    func compare(_ date: Date) -> ComparisonResult
}

open class ILSoupClock: NSObject, ILSoupTime {
    public let earliest: Date
    public let latest: Date
    private let alwaysMatch: Bool

    public required init(earliest: Date, andLatest latest: Date) {
        self.earliest = earliest
        self.latest = latest
        self.alwaysMatch = false
        super.init()
    }

    private init(earliest: Date, latest: Date, alwaysMatch: Bool) {
        self.earliest = earliest
        self.latest = latest
        self.alwaysMatch = alwaysMatch
        super.init()
    }

    public static func earlier() -> ILSoupTime {
        earlierThan(Date())
    }

    public static func earlierThan(_ latest: Date) -> ILSoupTime {
        ILSoupClock(earliest: .distantPast, andLatest: latest)
    }

    public static func later() -> ILSoupTime {
        laterThan(Date())
    }

    public static func laterThan(_ earliest: Date) -> ILSoupTime {
        ILSoupClock(earliest: earliest, andLatest: .distantFuture)
    }

    public static func anytime() -> ILSoupTime {
        ILSoupClock(earliest: .distantPast, andLatest: .distantFuture)
    }

    public static func whenever() -> ILSoupTime {
        ILSoupClock(earliest: .distantPast, latest: .distantFuture, alwaysMatch: true)
    }

    public static func never() -> ILSoupTime {
        ILSoupClock(earliest: .distantFuture, andLatest: .distantPast)
    }

    public static func interval(_ seconds: TimeInterval, before latest: Date) -> ILSoupTime {
        ILSoupClock(earliest: latest.addingTimeInterval(-seconds), andLatest: latest)
    }

    public static func interval(_ seconds: TimeInterval, around center: Date) -> ILSoupTime {
        let half = seconds / 2
        return ILSoupClock(earliest: center.addingTimeInterval(-half), andLatest: center.addingTimeInterval(half))
    }

    public static func interval(_ seconds: TimeInterval, after earliest: Date) -> ILSoupTime {
        ILSoupClock(earliest: earliest, andLatest: earliest.addingTimeInterval(seconds))
    }

    public static func recently() -> ILSoupTime { interval(5 * 60, before: Date()) }
    public static func nowish() -> ILSoupTime { interval(2 * 60, around: Date()) }
    public static func soonish() -> ILSoupTime { interval(5 * 60, after: Date()) }

    public static func today() -> ILSoupTime {
        let calendar = Calendar.current
        let start = calendar.startOfDay(for: Date())
        let end = calendar.date(byAdding: DateComponents(day: 1, second: -1), to: start) ?? Date()
        return ILSoupClock(earliest: start, andLatest: end)
    }

    public static func thisMonth() -> ILSoupTime {
        let calendar = Calendar.current
        let now = Date()
        let start = calendar.date(from: calendar.dateComponents([.year, .month], from: now)) ?? now
        let end = calendar.date(byAdding: DateComponents(month: 1, second: -1), to: start) ?? now
        return ILSoupClock(earliest: start, andLatest: end)
    }

    public static func thisYear() -> ILSoupTime {
        let calendar = Calendar.current
        let now = Date()
        let start = calendar.date(from: calendar.dateComponents([.year], from: now)) ?? now
        let end = calendar.date(byAdding: DateComponents(year: 1, second: -1), to: start) ?? now
        return ILSoupClock(earliest: start, andLatest: end)
    }

    public static func lastYear() -> ILSoupTime {
        shiftYear(by: -1)
    }

    public static func lastDecade() -> ILSoupTime {
        shiftYears(startOffset: -10, length: 10)
    }

    public static func lastCentury() -> ILSoupTime {
        shiftYears(startOffset: -100, length: 100)
    }

    public static func lastMillennium() -> ILSoupTime {
        shiftYears(startOffset: -1000, length: 1000)
    }

    public static func nextYear() -> ILSoupTime {
        shiftYear(by: 1)
    }

    public static func nextDecade() -> ILSoupTime {
        shiftYears(startOffset: 0, length: 10)
    }

    public static func nextCentury() -> ILSoupTime {
        shiftYears(startOffset: 0, length: 100)
    }

    public static func nextMillennium() -> ILSoupTime {
        shiftYears(startOffset: 0, length: 1000)
    }

    private static func shiftYear(by offset: Int) -> ILSoupTime {
        let calendar = Calendar.current
        let now = Date()
        let thisStart = calendar.date(from: calendar.dateComponents([.year], from: now)) ?? now
        let start = calendar.date(byAdding: .year, value: offset, to: thisStart) ?? now
        let end = calendar.date(byAdding: DateComponents(year: 1, second: -1), to: start) ?? now
        return ILSoupClock(earliest: start, andLatest: end)
    }

    private static func shiftYears(startOffset: Int, length: Int) -> ILSoupTime {
        let calendar = Calendar.current
        let now = Date()
        let thisStart = calendar.date(from: calendar.dateComponents([.year], from: now)) ?? now
        let start = calendar.date(byAdding: .year, value: startOffset, to: thisStart) ?? now
        let end = calendar.date(byAdding: DateComponents(year: length, second: -1), to: start) ?? now
        return ILSoupClock(earliest: start, andLatest: end)
    }

    public func interval() -> TimeInterval {
        latest.timeIntervalSince(earliest)
    }

    public func compare(_ date: Date) -> ComparisonResult {
        if alwaysMatch { return .orderedSame }
        if earliest > latest { return .orderedAscending }
        if date < earliest { return .orderedAscending }
        if date > latest { return .orderedDescending }
        return .orderedSame
    }
}

public protocol ILSoupSequence: AnyObject {
    var sequencePath: String { get }
    static func sequence(withPath sequencePath: String) -> Self
    func sequenceEntry(_ entry: ILSoupEntry, atTime timeIndex: Date)
    func removeEntry(_ entry: ILSoupEntry)
    func includesEntry(_ entry: ILSoupEntry) -> Bool
    func fetchSequence(for entry: ILSoupEntry, times: inout [Date], values: inout [NSNumber]) -> Bool
    func fetchSequenceSource(for entry: ILSoupEntry) -> ILSoupSequenceSource?
}

public protocol ILSoupSequenceSource: AnyObject {
    var sampleDates: [Date] { get }
    func sampleValue(at index: UInt) -> CGFloat
}

open class ILStockSequenceSource: NSObject, ILSoupSequenceSource {
    public let sampleDates: [Date]
    private let sequenceValues: [NSNumber]

    public init(times: [Date], andValues values: [NSNumber]) {
        sampleDates = times
        sequenceValues = values
    }

    public class func sequenceSource(withTimes times: [Date], andValues values: [NSNumber]) -> Self {
        self.init(times: times, andValues: values)
    }

    public func sampleValue(at index: UInt) -> CGFloat {
        guard Int(index) < sequenceValues.count else { return 0 }
        return CGFloat(truncating: sequenceValues[Int(index)])
    }
}

open class ILStockSequence: NSObject, ILSoupSequence {
    public let sequencePath: String
    private var timelineByAlias: [String: [(Date, NSNumber)]] = [:]

    public required init(path: String) {
        self.sequencePath = path
    }

    public class func sequence(withPath sequencePath: String) -> Self {
        self.init(path: sequencePath)
    }

    public func sequenceEntry(_ entry: ILSoupEntry, atTime timeIndex: Date = Date()) {
        guard let rawValue = entry.entryKeys[sequencePath] else { return }
        let value = rawValue as? NSNumber ?? NSNumber(value: 0)
        timelineByAlias[entry.entryHash, default: []].append((timeIndex, value))
    }

    public func removeEntry(_ entry: ILSoupEntry) {
        timelineByAlias.removeValue(forKey: entry.entryHash)
    }

    public func includesEntry(_ entry: ILSoupEntry) -> Bool {
        timelineByAlias[entry.entryHash] != nil
    }

    public func fetchSequence(for entry: ILSoupEntry, times: inout [Date], values: inout [NSNumber]) -> Bool {
        guard let sequence = timelineByAlias[entry.entryHash] else { return false }
        times = sequence.map { $0.0 }
        values = sequence.map { $0.1 }
        return true
    }

    public func fetchSequenceSource(for entry: ILSoupEntry) -> ILSoupSequenceSource? {
        var times: [Date] = []
        var values: [NSNumber] = []
        guard fetchSequence(for: entry, times: &times, values: &values) else { return nil }
        return ILStockSequenceSource(times: times, andValues: values)
    }
}

public protocol ILSoupDelegate: AnyObject {
    func soup(_ deJour: ILSoup, createdEntry entry: ILSoupEntry)
    func soup(_ deJour: ILSoup, addedEntry entry: ILSoupEntry)
    func soup(_ deJour: ILSoup, deletedEntry entry: ILSoupEntry)
    func soup(_ deJour: ILSoup, createdIndex index: ILSoupIndex)
    func soup(_ deJour: ILSoup, updatedIndex index: ILSoupIndex)
    func soup(_ deJour: ILSoup, createdSequence sequence: ILSoupSequence)
    func soup(_ deJour: ILSoup, updatedSequence sequence: ILSoupSequence)
    func soupFilled(_ deJour: ILSoup)
    func soupDone(_ deJour: ILSoup)
}

public extension ILSoupDelegate {
    func soup(_ deJour: ILSoup, createdEntry entry: ILSoupEntry) {}
    func soup(_ deJour: ILSoup, addedEntry entry: ILSoupEntry) {}
    func soup(_ deJour: ILSoup, deletedEntry entry: ILSoupEntry) {}
    func soup(_ deJour: ILSoup, createdIndex index: ILSoupIndex) {}
    func soup(_ deJour: ILSoup, updatedIndex index: ILSoupIndex) {}
    func soup(_ deJour: ILSoup, createdSequence sequence: ILSoupSequence) {}
    func soup(_ deJour: ILSoup, updatedSequence sequence: ILSoupSequence) {}
    func soupFilled(_ deJour: ILSoup) {}
    func soupDone(_ deJour: ILSoup) {}
}

public protocol ILSoup: AnyObject {
    var soupUUID: UUID { get }
    var soupName: String { get set }
    var soupDescription: String { get set }
    var soupQuery: NSPredicate { get set }
    var cursor: ILSoupCursor { get }
    var defaultEntry: [String: Any] { get set }
    var delegate: ILSoupDelegate? { get set }
    static func makeSoup(_ soupName: String) -> Self?
    init(name soupName: String)
    func createBlankEntry() -> ILMutableSoupEntry
    func createBlankEntry(ofClass conformsToMutableSoupEntry: ILMutableSoupEntry.Type) -> ILMutableSoupEntry?
    func addEntry(_ entry: ILSoupEntry) -> String
    func deleteEntry(_ entry: ILSoupEntry)
    func entryAlias(_ entry: ILSoupEntry) -> String
    func gotoAlias(_ alias: String) -> ILMutableSoupEntry?
    func querySoup(_ query: NSPredicate) -> ILSoupCursor
    @discardableResult func resetCursor() -> ILSoupCursor
    var soupIndices: [ILSoupIndex] { get }
    func indexForPath(_ indexPath: String) -> ILSoupIndex
    func createIndex(_ indexPath: String) -> ILSoupIndex
    func queryIndex(_ indexPath: String) -> ILSoupIndex?
    func createEntryIdentityIndex() -> ILSoupIdentityIndex
    func queryEntryIdentityIndex(_ entryIdentityUUID: String) -> ILSoupEntry?
    func createAncestryIndex() -> ILSoupAncestryIndex
    func queryAncestryIndex() -> ILSoupAncestryIndex?
    func createValueIndex(_ indexPath: String) -> ILSoupIndex
    func queryValueIndex(_ indexPath: String) -> ILSoupIndex?
    func createIdentityIndex(_ indexPath: String) -> ILSoupIdentityIndex
    func queryIdentityIndex(_ indexPath: String) -> ILSoupIdentityIndex?
    func createTextIndex(_ indexPath: String) -> ILSoupTextIndex
    func queryTextIndex(_ indexPath: String) -> ILSoupTextIndex?
    func createNumberIndex(_ indexPath: String) -> ILSoupNumberIndex
    func queryNumberIndex(_ indexPath: String) -> ILSoupNumberIndex?
    func createDateIndex(_ indexPath: String) -> ILSoupDateIndex
    func queryDateIndex(_ indexPath: String) -> ILSoupDateIndex?
    var soupSequences: [ILSoupSequence] { get }
    func createSequence(_ sequencePath: String) -> ILSoupSequence
    func querySequence(_ sequencePath: String) -> ILSoupSequence?
    func fillNewSoup()
    func doneWithSoup(_ appIdentifier: String)
}

public protocol ILSoupIndex: AnyObject {
    var indexPath: String { get }
    var valueCount: Int { get }
    func allValues() -> [Any]
    func allValues(orderedBy descriptor: NSSortDescriptor) -> [Any]
    var entryCount: Int { get }
    func indexEntry(_ entry: ILSoupEntry)
    func removeEntry(_ entry: ILSoupEntry)
    func includesEntry(_ entry: ILSoupEntry) -> Bool
    func allEntries() -> ILSoupCursor
    func entries(withValue value: Any?) -> ILSoupCursor
}

public protocol ILSoupIdentityIndex: ILSoupIndex {
    func entry(withValue value: Any) -> ILSoupEntry?
}

public protocol ILSoupAncestryIndex: ILSoupIdentityIndex {
    func ancestor(of descendant: ILSoupEntry) -> ILSoupEntry?
    func ancestry(of descendant: ILSoupEntry) -> ILSoupCursor
    func descendants(of ancestor: ILSoupEntry) -> ILSoupCursor
    func progenitors() -> ILSoupCursor
}

public protocol ILSoupTextIndex: ILSoupIndex {
    func entries(matching pattern: String) -> ILSoupCursor
}

public protocol ILSoupNumberIndex: ILSoupIndex {
    func entriesBetween(_ min: NSNumber, and max: NSNumber) -> ILSoupCursor
}

public protocol ILSoupDateIndex: ILSoupIndex {
    func entriesBetween(_ early: Date, and late: Date) -> ILSoupCursor
    func entries(in timeRange: ILSoupTime) -> ILSoupCursor
}

open class ILStockIndex: NSObject, ILSoupIndex {
    public let indexPath: String
    public weak var containingSoup: ILSoup?
    fileprivate var entriesByAlias: [String: ILSoupEntry] = [:]
    fileprivate var aliasesByValue: [String: [String]] = [:]
    fileprivate var valueByAlias: [String: Any] = [:]
    fileprivate var keyByAlias: [String: String] = [:]

    public required init(path indexPath: String, inSoup containingSoup: ILSoup) {
        self.indexPath = indexPath
        self.containingSoup = containingSoup
    }

    public class func index(withPath indexPath: String, inSoup containingSoup: ILSoup) -> Self {
        self.init(path: indexPath, inSoup: containingSoup)
    }

    open var valueCount: Int { aliasesByValue.keys.count }
    open var entryCount: Int { entriesByAlias.count }

    open func allValues() -> [Any] {
        Array(Set(valueByAlias.values.map { canonicalOrderingString(for: $0) })).sorted()
    }

    open func allValues(orderedBy descriptor: NSSortDescriptor) -> [Any] {
        (allValues() as NSArray).sortedArray(using: [descriptor])
    }

    open func indexEntry(_ entry: ILSoupEntry) {
        removeEntry(entry)
        let alias = entry.entryHash
        entriesByAlias[alias] = entry
        guard let value = entry.entryKeys[indexPath] else { return }
        let valueKey = canonicalOrderingString(for: value)
        valueByAlias[alias] = value
        keyByAlias[alias] = valueKey
        aliasesByValue[valueKey, default: []].append(alias)
    }

    open func removeEntry(_ entry: ILSoupEntry) {
        let alias = entry.entryHash
        entriesByAlias.removeValue(forKey: alias)
        valueByAlias.removeValue(forKey: alias)
        if let valueKey = keyByAlias.removeValue(forKey: alias) {
            aliasesByValue[valueKey] = aliasesByValue[valueKey]?.filter { $0 != alias }
            if aliasesByValue[valueKey]?.isEmpty == true {
                aliasesByValue.removeValue(forKey: valueKey)
            }
        }
    }

    open func includesEntry(_ entry: ILSoupEntry) -> Bool {
        entriesByAlias[entry.entryHash] != nil
    }

    open func allEntries() -> ILSoupCursor {
        ILStockCursor(entries: Array(entriesByAlias.values))
    }

    open func entries(withValue value: Any?) -> ILSoupCursor {
        guard let value else { return ILStockCursor(entries: []) }
        let valueKey = canonicalOrderingString(for: value)
        let aliases = aliasesByValue[valueKey] ?? []
        let entries = aliases.compactMap { entriesByAlias[$0] }
        return ILStockCursor(entries: entries)
    }
}

open class ILStockIdentityIndex: ILStockIndex, ILSoupIdentityIndex {
    open func entry(withValue value: Any) -> ILSoupEntry? {
        entries(withValue: value).entries.last
    }

    override open func indexEntry(_ entry: ILSoupEntry) {
        removeEntry(entry)
        let alias = entry.entryHash
        entriesByAlias[alias] = entry
        guard let value = entry.entryKeys[indexPath] else { return }
        let valueKey = canonicalOrderingString(for: value)
        valueByAlias[alias] = value
        keyByAlias[alias] = valueKey
        if let oldAliases = aliasesByValue[valueKey] {
            oldAliases.forEach {
                entriesByAlias.removeValue(forKey: $0)
                valueByAlias.removeValue(forKey: $0)
                keyByAlias.removeValue(forKey: $0)
            }
        }
        aliasesByValue[valueKey] = [alias]
    }
}

open class ILStockAncestryIndex: ILStockIdentityIndex, ILSoupAncestryIndex {
    open func ancestor(of descendant: ILSoupEntry) -> ILSoupEntry? {
        guard let ancestorAlias = descendant.entryKeys[ILSoupEntryAncestorEntryHash] as? String else { return nil }
        return containingSoup?.gotoAlias(ancestorAlias)
    }

    open func ancestry(of descendant: ILSoupEntry) -> ILSoupCursor {
        var chain: [ILSoupEntry] = [descendant]
        var cursor = descendant
        while let next = ancestor(of: cursor) {
            chain.append(next)
            cursor = next
        }
        return ILStockCursor(entries: chain)
    }

    open func descendants(of ancestor: ILSoupEntry) -> ILSoupCursor {
        let aliases = aliasesByValue[ancestor.entryHash] ?? []
        return ILStockCursor(entries: aliases.compactMap { entriesByAlias[$0] })
    }

    open func progenitors() -> ILSoupCursor {
        var roots: [String: ILSoupEntry] = [:]
        for entry in entriesByAlias.values {
            let chain = ancestry(of: entry).entries
            if let root = chain.last {
                roots[root.entryHash] = root
            }
        }
        return ILStockCursor(entries: Array(roots.values))
    }
}

open class ILStockTextIndex: ILStockIndex, ILSoupTextIndex {
    open func entries(matching pattern: String) -> ILSoupCursor {
        guard let regex = try? NSRegularExpression(pattern: pattern) else { return ILStockCursor(entries: []) }
        let matches = entriesByAlias.values.filter { entry in
            guard let string = entry.entryKeys[indexPath] as? String else { return false }
            let range = NSRange(location: 0, length: string.utf16.count)
            return regex.firstMatch(in: string, range: range) != nil
        }
        return ILStockCursor(entries: matches)
    }
}

open class ILStockNumberIndex: ILStockIndex, ILSoupNumberIndex {
    open func entriesBetween(_ min: NSNumber, and max: NSNumber) -> ILSoupCursor {
        let values = entriesByAlias.values.filter { entry in
            guard let number = entry.entryKeys[indexPath] as? NSNumber else { return false }
            return number.doubleValue >= min.doubleValue && number.doubleValue <= max.doubleValue
        }
        return ILStockCursor(entries: values)
    }
}

open class ILStockDateIndex: ILStockIndex, ILSoupDateIndex {
    open func entriesBetween(_ early: Date, and late: Date) -> ILSoupCursor {
        let values = entriesByAlias.values.filter { entry in
            guard let date = entry.entryKeys[indexPath] as? Date else { return false }
            return date >= early && date <= late
        }
        return ILStockCursor(entries: values)
    }

    open func entries(in timeRange: ILSoupTime) -> ILSoupCursor {
        entriesBetween(timeRange.earliest, and: timeRange.latest)
    }
}

@objcMembers
open class ILSoupStock: NSObject, ILSoup {
    public let soupUUID: UUID = UUID()
    public var soupName: String
    public var soupDescription: String = ""
    public var soupQuery: NSPredicate = NSPredicate(value: true) {
        didSet { _ = resetCursor() }
    }
    public var defaultEntry: [String: Any] = [:]
    public weak var delegate: ILSoupDelegate?

    private var entriesByAlias: [String: ILMutableSoupEntry] = [:]
    private var indicesByPath: [String: ILSoupIndex] = [:]
    private var sequencesByPath: [String: ILSoupSequence] = [:]
    private var defaultCursor: ILSoupCursor = ILStockCursor(entries: [])

    public required init(name soupName: String) {
        self.soupName = soupName
        super.init()
        fillNewSoup()
        _ = resetCursor()
    }

    public class func makeSoup(_ soupName: String) -> Self? {
        self.init(name: soupName)
    }

    open var cursor: ILSoupCursor { defaultCursor }
    open var soupIndices: [ILSoupIndex] { indicesByPath.values.sorted { $0.indexPath < $1.indexPath } }
    open var soupSequences: [ILSoupSequence] { sequencesByPath.values.sorted { $0.sequencePath < $1.sequencePath } }

    open func createBlankEntry() -> ILMutableSoupEntry {
        createBlankEntry(ofClass: ILStockEntry.self) ?? ILStockEntry()
    }

    open func createBlankEntry(ofClass conformsToMutableSoupEntry: ILMutableSoupEntry.Type) -> ILMutableSoupEntry? {
        var values = defaultEntry
        values[ILSoupEntryIdentityUUID] = UUID().uuidString
        values[ILSoupEntryCreationDate] = Date()
        let entry = conformsToMutableSoupEntry.init()
        if !values.isEmpty {
            return entry.mutatedEntry(values)
        }
        delegate?.soup(self, createdEntry: entry)
        return entry
    }

    open func add(_ entry: ILSoupEntry) -> String {
        addEntry(entry)
    }

    open func add(_ entry: Any) -> String {
        if let soupEntry = entry as? ILSoupEntry {
            return addEntry(soupEntry)
        }
        return ""
    }

    open func addEntry(_ entry: ILSoupEntry) -> String {
        let alias = entryAlias(entry)
        if let mutable = entry as? ILMutableSoupEntry {
            entriesByAlias[alias] = mutable
        } else if let copied = entry.mutableCopy() as? ILMutableSoupEntry {
            entriesByAlias[alias] = copied
        }
        indexEntry(entry)
        sequenceEntry(entry)
        delegate?.soup(self, addedEntry: entry)
        _ = resetCursor()
        return alias
    }

    open func deleteEntry(_ entry: ILSoupEntry) {
        let alias = entryAlias(entry)
        entriesByAlias.removeValue(forKey: alias)
        removeFromIndices(entry)
        removeFromSequences(entry)
        delegate?.soup(self, deletedEntry: entry)
        _ = resetCursor()
    }

    open func entryAlias(_ entry: ILSoupEntry) -> String {
        entry.entryHash
    }

    open func gotoAlias(_ alias: String) -> ILMutableSoupEntry? {
        entriesByAlias[alias]
    }

    open func querySoup(_ query: NSPredicate) -> ILSoupCursor {
        let values = entriesByAlias.values.filter { entry in
            query.evaluate(with: entry.entryKeys)
        }
        return ILStockCursor(entries: values)
    }

    @discardableResult
    open func resetCursor() -> ILSoupCursor {
        defaultCursor = querySoup(soupQuery)
        return defaultCursor
    }

    open func indexForPath(_ indexPath: String) -> ILSoupIndex {
        queryIndex(indexPath) ?? createIndex(indexPath)
    }

    open func createIndex(_ indexPath: String) -> ILSoupIndex {
        let index = ILStockIndex(path: indexPath, inSoup: self)
        indicesByPath[indexPath] = index
        entriesByAlias.values.forEach { index.indexEntry($0) }
        delegate?.soup(self, createdIndex: index)
        return index
    }

    open func queryIndex(_ indexPath: String) -> ILSoupIndex? {
        indicesByPath[indexPath]
    }

    open func createEntryIdentityIndex() -> ILSoupIdentityIndex {
        if let index = queryIdentityIndex(ILSoupEntryIdentityUUID) { return index }
        let index = ILStockIdentityIndex(path: ILSoupEntryIdentityUUID, inSoup: self)
        indicesByPath[ILSoupEntryIdentityUUID] = index
        entriesByAlias.values.forEach { index.indexEntry($0) }
        delegate?.soup(self, createdIndex: index)
        return index
    }

    open func queryEntryIdentityIndex(_ entryIdentityUUID: String) -> ILSoupEntry? {
        queryIdentityIndex(ILSoupEntryIdentityUUID)?.entry(withValue: entryIdentityUUID)
    }

    open func createAncestryIndex() -> ILSoupAncestryIndex {
        if let index = queryAncestryIndex() { return index }
        let index = ILStockAncestryIndex(path: ILSoupEntryAncestorEntryHash, inSoup: self)
        indicesByPath[ILSoupEntryAncestorEntryHash] = index
        entriesByAlias.values.forEach { index.indexEntry($0) }
        delegate?.soup(self, createdIndex: index)
        return index
    }

    open func queryAncestryIndex() -> ILSoupAncestryIndex? {
        indicesByPath[ILSoupEntryAncestorEntryHash] as? ILSoupAncestryIndex
    }

    open func createValueIndex(_ indexPath: String) -> ILSoupIndex {
        if let existing = queryValueIndex(indexPath) { return existing }
        let index = ILStockIndex(path: indexPath, inSoup: self)
        indicesByPath[indexPath] = index
        entriesByAlias.values.forEach { index.indexEntry($0) }
        delegate?.soup(self, createdIndex: index)
        return index
    }

    open func queryValueIndex(_ indexPath: String) -> ILSoupIndex? {
        indicesByPath[indexPath]
    }

    open func createIdentityIndex(_ indexPath: String) -> ILSoupIdentityIndex {
        if let existing = queryIdentityIndex(indexPath) { return existing }
        let index = ILStockIdentityIndex(path: indexPath, inSoup: self)
        indicesByPath[indexPath] = index
        entriesByAlias.values.forEach { index.indexEntry($0) }
        delegate?.soup(self, createdIndex: index)
        return index
    }

    open func queryIdentityIndex(_ indexPath: String) -> ILSoupIdentityIndex? {
        indicesByPath[indexPath] as? ILSoupIdentityIndex
    }

    open func createTextIndex(_ indexPath: String) -> ILSoupTextIndex {
        if let existing = queryTextIndex(indexPath) { return existing }
        let index = ILStockTextIndex(path: indexPath, inSoup: self)
        indicesByPath[indexPath] = index
        entriesByAlias.values.forEach { index.indexEntry($0) }
        delegate?.soup(self, createdIndex: index)
        return index
    }

    open func queryTextIndex(_ indexPath: String) -> ILSoupTextIndex? {
        indicesByPath[indexPath] as? ILSoupTextIndex
    }

    open func createNumberIndex(_ indexPath: String) -> ILSoupNumberIndex {
        if let existing = queryNumberIndex(indexPath) { return existing }
        let index = ILStockNumberIndex(path: indexPath, inSoup: self)
        indicesByPath[indexPath] = index
        entriesByAlias.values.forEach { index.indexEntry($0) }
        delegate?.soup(self, createdIndex: index)
        return index
    }

    open func queryNumberIndex(_ indexPath: String) -> ILSoupNumberIndex? {
        indicesByPath[indexPath] as? ILSoupNumberIndex
    }

    open func createDateIndex(_ indexPath: String) -> ILSoupDateIndex {
        if let existing = queryDateIndex(indexPath) { return existing }
        let index = ILStockDateIndex(path: indexPath, inSoup: self)
        indicesByPath[indexPath] = index
        entriesByAlias.values.forEach { index.indexEntry($0) }
        delegate?.soup(self, createdIndex: index)
        return index
    }

    open func queryDateIndex(_ indexPath: String) -> ILSoupDateIndex? {
        indicesByPath[indexPath] as? ILSoupDateIndex
    }

    open func createSequence(_ sequencePath: String) -> ILSoupSequence {
        if let existing = querySequence(sequencePath) { return existing }
        let sequence = ILStockSequence(path: sequencePath)
        sequencesByPath[sequencePath] = sequence
        entriesByAlias.values.forEach { sequence.sequenceEntry($0, atTime: Date()) }
        delegate?.soup(self, createdSequence: sequence)
        return sequence
    }

    open func querySequence(_ sequencePath: String) -> ILSoupSequence? {
        sequencesByPath[sequencePath]
    }

    open func indexEntry(_ entry: ILSoupEntry) {
        for index in indicesByPath.values {
            index.indexEntry(entry)
            delegate?.soup(self, updatedIndex: index)
        }
    }

    open func removeFromIndices(_ entry: ILSoupEntry) {
        for index in indicesByPath.values {
            index.removeEntry(entry)
            delegate?.soup(self, updatedIndex: index)
        }
    }

    open func sequenceEntry(_ entry: ILSoupEntry) {
        for sequence in sequencesByPath.values {
            sequence.sequenceEntry(entry, atTime: Date())
            delegate?.soup(self, updatedSequence: sequence)
        }
    }

    open func removeFromSequences(_ entry: ILSoupEntry) {
        for sequence in sequencesByPath.values {
            sequence.removeEntry(entry)
            delegate?.soup(self, updatedSequence: sequence)
        }
    }

    open func fillNewSoup() {
        delegate?.soupFilled(self)
    }

    open func doneWithSoup(_ appIdentifier: String) {
        entriesByAlias.removeAll()
        indicesByPath.removeAll()
        sequencesByPath.removeAll()
        delegate?.soupDone(self)
    }
}

open class ILMemorySoup: ILSoupStock {}

open class ILFileSoup: ILSoupStock {
    public let filePath: String

    public required init(name soupName: String) {
        self.filePath = ""
        super.init(name: soupName)
    }

    public init(filePath: String) {
        self.filePath = filePath
        super.init(name: URL(fileURLWithPath: filePath).lastPathComponent)
    }

    public class func fileSoup(atPath filePath: String) -> ILFileSoup {
        ILFileSoup(filePath: filePath)
    }
}

public protocol ILQueuedSoupDelegate: ILSoupDelegate {}

open class ILQueuedSoup: ILSoupStock {
    public var queued: ILSoup
    public var soupOperations: OperationQueue

    public required init(name soupName: String) {
        self.queued = ILMemorySoup(name: soupName)
        self.soupOperations = OperationQueue()
        super.init(name: soupName)
    }

    public init(queuedSoup: ILSoup, soupQueue soupOps: OperationQueue?) {
        self.queued = queuedSoup
        self.soupOperations = soupOps ?? OperationQueue()
        super.init(name: queuedSoup.soupName)
    }

    public class func queuedSoup(_ queuedSoup: ILSoup, soupQueue soupOps: OperationQueue?) -> Self {
        self.init(queuedSoup: queuedSoup, soupQueue: soupOps)
    }
}

open class ILSynchedSoup: ILSoupStock {
    public var synchronized: ILSoup
    private let lock = NSRecursiveLock()

    public required init(name soupName: String) {
        self.synchronized = ILMemorySoup(name: soupName)
        super.init(name: soupName)
    }

    public init(synched: ILSoup) {
        self.synchronized = synched
        super.init(name: synched.soupName)
    }

    public class func synchronizedSoup(_ synched: ILSoup) -> Self {
        self.init(synched: synched)
    }

    override open func addEntry(_ entry: ILSoupEntry) -> String {
        lock.lock()
        defer { lock.unlock() }
        return synchronized.addEntry(entry)
    }
}

public protocol ILUnionSoupDelegate: ILSoupDelegate {
    func unionSoup(_ unionSoup: ILUnionSoup, addedSoup soup: ILSoup)
    func unionSoup(_ unionSoup: ILUnionSoup, removedSoup soup: ILSoup)
    func unionSoup(_ unionSoup: ILUnionSoup, copiedEntry entry: ILSoupEntry, fromSoup: ILSoup, toSoup: ILSoup)
    func unionSoup(_ unionSoup: ILUnionSoup, movedEntry entry: ILSoupEntry, fromSoup: ILSoup, toSoup: ILSoup)
    func unionSoup(_ unionSoup: ILUnionSoup, pushedEntry entry: ILSoupEntry, fromSoup: ILSoup, toSoup: ILSoup)
    func unionSoup(_ unionSoup: ILUnionSoup, popedEntry entry: ILSoupEntry, fromSoup: ILSoup, toSoup: ILSoup)
}

public extension ILUnionSoupDelegate {
    func unionSoup(_ unionSoup: ILUnionSoup, addedSoup soup: ILSoup) {}
    func unionSoup(_ unionSoup: ILUnionSoup, removedSoup soup: ILSoup) {}
    func unionSoup(_ unionSoup: ILUnionSoup, copiedEntry entry: ILSoupEntry, fromSoup: ILSoup, toSoup: ILSoup) {}
    func unionSoup(_ unionSoup: ILUnionSoup, movedEntry entry: ILSoupEntry, fromSoup: ILSoup, toSoup: ILSoup) {}
    func unionSoup(_ unionSoup: ILUnionSoup, pushedEntry entry: ILSoupEntry, fromSoup: ILSoup, toSoup: ILSoup) {}
    func unionSoup(_ unionSoup: ILUnionSoup, popedEntry entry: ILSoupEntry, fromSoup: ILSoup, toSoup: ILSoup) {}
}

open class ILUnionSoup: ILSoupStock {
    public private(set) var loadedSoups: [ILSoup] = []
    public weak var unionDelegate: ILUnionSoupDelegate?

    open override func querySoup(_ query: NSPredicate) -> ILSoupCursor {
        let all = loadedSoups.flatMap { $0.querySoup(query).entries }
        return ILStockCursor(entries: all)
    }

    open func addSoup(_ soup: ILSoup) {
        loadedSoups.append(soup)
        unionDelegate?.unionSoup(self, addedSoup: soup)
    }

    open func insertSoup(_ soup: ILSoup, at index: UInt) {
        loadedSoups.insert(soup, at: min(Int(index), loadedSoups.count))
        unionDelegate?.unionSoup(self, addedSoup: soup)
    }

    open func removeSoup(_ soup: ILSoup) {
        loadedSoups.removeAll { $0 === soup }
        unionDelegate?.unionSoup(self, removedSoup: soup)
    }

    open func copyEntry(_ entryHash: String, fromSoup: ILSoup, toSoup: ILSoup) -> Bool {
        guard let entry = fromSoup.gotoAlias(entryHash) else { return false }
        let copy = entry.copy() as? ILSoupEntry ?? entry
        _ = toSoup.addEntry(copy)
        unionDelegate?.unionSoup(self, copiedEntry: copy, fromSoup: fromSoup, toSoup: toSoup)
        return true
    }

    open func moveEntry(_ entryHash: String, fromSoup: ILSoup, toSoup: ILSoup) -> Bool {
        guard let entry = fromSoup.gotoAlias(entryHash) else { return false }
        _ = toSoup.addEntry(entry)
        fromSoup.deleteEntry(entry)
        unionDelegate?.unionSoup(self, movedEntry: entry, fromSoup: fromSoup, toSoup: toSoup)
        return true
    }

    open func pushEntry(_ entryHash: String) -> Bool {
        guard loadedSoups.count > 1 else { return false }
        for i in 0..<(loadedSoups.count - 1) {
            if moveEntry(entryHash, fromSoup: loadedSoups[i], toSoup: loadedSoups[i + 1]) {
                if let moved = loadedSoups[i + 1].gotoAlias(entryHash) {
                    unionDelegate?.unionSoup(self, pushedEntry: moved, fromSoup: loadedSoups[i], toSoup: loadedSoups[i + 1])
                }
                return true
            }
        }
        return false
    }

    open func popEntry(_ entryHash: String) -> Bool {
        guard loadedSoups.count > 1 else { return false }
        for i in stride(from: loadedSoups.count - 1, through: 1, by: -1) {
            if moveEntry(entryHash, fromSoup: loadedSoups[i], toSoup: loadedSoups[i - 1]) {
                if let moved = loadedSoups[i - 1].gotoAlias(entryHash) {
                    unionDelegate?.unionSoup(self, popedEntry: moved, fromSoup: loadedSoups[i], toSoup: loadedSoups[i - 1])
                }
                return true
            }
        }
        return false
    }
}

open class ILSoupSnapshot: NSObject {
    public let snapshotMap: [String: Any]

    public init(map snapshotMap: [String: Any]) {
        self.snapshotMap = snapshotMap
    }

    open func snapshot(_ object: NSObject, in soup: ILSoup) -> ILSoupEntry? {
        let properties = (snapshotMap[ILSoupSnapshotProperties] as? [String: [String: Any]]) ?? [:]
        var capture: [String: Any] = [:]

        for (keyPath, config) in properties {
            let storageKey = (config[ILSoupSnapshotStorageKey] as? String) ?? keyPath
            let value = valueForSnapshot(from: object, keyPath: keyPath)
            if let transformer = config[ILSoupSnapshotValueTransformer] as? ValueTransformer {
                capture[storageKey] = transformer.transformedValue(value)
            } else if let value {
                capture[storageKey] = value
            }
        }

        if let matchKeyPath = snapshotMap[ILSoupSnapshotMatchKeyPath] as? String,
           let matchValue = valueForSnapshot(from: object, keyPath: matchKeyPath),
           let identity = soup.queryIdentityIndex(matchKeyPath),
           let existing = identity.entry(withValue: matchValue) as? ILMutableSoupEntry {
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
        return object.value(forKeyPath: keyPath)
    }
}

public extension NSArray {
    @objc(allValuesDigest)
    func il_allValuesDigest() -> Data {
        SoupDigest.allValuesDigest(self as? [Any] ?? [])
    }

    @objc(deepMutableCopy)
    func il_deepMutableCopy() -> NSMutableArray {
        SoupDeepCopy.mutableArrayCopy(self as? [Any] ?? [])
    }
}

public extension NSDictionary {
    @objc(allKeysDigest)
    func il_allKeysDigest() -> Data {
        SoupDigest.allKeysDigest(self as? [AnyHashable: Any] ?? [:])
    }

    @objc(allKeysAndValuesDigest)
    func il_allKeysAndValuesDigest() -> Data {
        SoupDigest.allKeysAndValuesDigest(self as? [AnyHashable: Any] ?? [:])
    }

    @objc(sha224AllKeys)
    func il_sha224AllKeys() -> String {
        il_allKeysDigest().base64EncodedString()
    }

    @objc(sha224AllKeysAndValues)
    func il_sha224AllKeysAndValues() -> String {
        il_allKeysAndValuesDigest().base64EncodedString()
    }

    @objc(deepMutableCopy)
    func il_deepMutableCopy() -> NSMutableDictionary {
        SoupDeepCopy.mutableDictionaryCopy(self as? [AnyHashable: Any] ?? [:])
    }
}
