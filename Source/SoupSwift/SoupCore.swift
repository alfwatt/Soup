import Foundation

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


open class ILFileSoup: ILSoupStock {
    public let filePath: String

    public required init(name soupName: String) {
        self.filePath = soupName
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

    public class func queuedSoup(_ queuedSoup: ILSoup, soupQueue soupOps: OperationQueue?) -> ILQueuedSoup {
        ILQueuedSoup(queuedSoup: queuedSoup, soupQueue: soupOps)
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

    public class func synchronizedSoup(_ synched: ILSoup) -> ILSynchedSoup {
        ILSynchedSoup(synched: synched)
    }

    override open var soupName: String {
        get { synchronized.soupName }
        set {
            lock.lock()
            synchronized.soupName = newValue
            lock.unlock()
        }
    }

    override open var soupDescription: String {
        get { synchronized.soupDescription }
        set {
            lock.lock()
            synchronized.soupDescription = newValue
            lock.unlock()
        }
    }

    override open var soupQuery: NSPredicate {
        get { synchronized.soupQuery }
        set {
            lock.lock()
            synchronized.soupQuery = newValue
            lock.unlock()
        }
    }

    override open var cursor: ILSoupCursor {
        lock.lock()
        defer { lock.unlock() }
        return synchronized.cursor
    }

    override open func createBlankEntry() -> ILMutableSoupEntry {
        lock.lock()
        defer { lock.unlock() }
        return synchronized.createBlankEntry()
    }

    override open func createBlankEntry(ofClass conformsToMutableSoupEntry: ILMutableSoupEntry.Type) -> ILMutableSoupEntry? {
        lock.lock()
        defer { lock.unlock() }
        return synchronized.createBlankEntry(ofClass: conformsToMutableSoupEntry)
    }

    override open func addEntry(_ entry: ILSoupEntry) -> String {
        lock.lock()
        defer { lock.unlock() }
        return synchronized.addEntry(entry)
    }

    override open func deleteEntry(_ entry: ILSoupEntry) {
        lock.lock()
        defer { lock.unlock() }
        synchronized.deleteEntry(entry)
    }

    override open func gotoAlias(_ alias: String) -> ILMutableSoupEntry? {
        lock.lock()
        defer { lock.unlock() }
        return synchronized.gotoAlias(alias)
    }

    override open func querySoup(_ query: NSPredicate) -> ILSoupCursor {
        lock.lock()
        defer { lock.unlock() }
        return synchronized.querySoup(query)
    }

    override open func resetCursor() -> ILSoupCursor {
        lock.lock()
        defer { lock.unlock() }
        return synchronized.resetCursor()
    }

    override open func createIndex(_ indexPath: String) -> ILSoupIndex {
        lock.lock()
        defer { lock.unlock() }
        return synchronized.createIndex(indexPath)
    }

    override open func createSequence(_ sequencePath: String) -> ILSoupSequence {
        lock.lock()
        defer { lock.unlock() }
        return synchronized.createSequence(sequencePath)
    }
}

public protocol ILUnionSoupDelegate: ILSoupDelegate {
    func unionSoup(_ unionSoup: ILUnionSoup, addedSoup soup: ILSoup)
    func unionSoup(_ unionSoup: ILUnionSoup, removedSoup soup: ILSoup)
    func unionSoup(_ unionSoup: ILUnionSoup, copiedEntry entry: ILSoupEntry, fromSoup: ILSoup, toSoup: ILSoup)
    func unionSoup(_ unionSoup: ILUnionSoup, movedEntry entry: ILSoupEntry, fromSoup: ILSoup, toSoup: ILSoup)
    func unionSoup(_ unionSoup: ILUnionSoup, pushedEntry entry: ILSoupEntry, fromSoup: ILSoup, toSoup: ILSoup)
    func unionSoup(_ unionSoup: ILUnionSoup, poppedEntry entry: ILSoupEntry, fromSoup: ILSoup, toSoup: ILSoup)
}

public extension ILUnionSoupDelegate {
    func unionSoup(_ unionSoup: ILUnionSoup, addedSoup soup: ILSoup) {}
    func unionSoup(_ unionSoup: ILUnionSoup, removedSoup soup: ILSoup) {}
    func unionSoup(_ unionSoup: ILUnionSoup, copiedEntry entry: ILSoupEntry, fromSoup: ILSoup, toSoup: ILSoup) {}
    func unionSoup(_ unionSoup: ILUnionSoup, movedEntry entry: ILSoupEntry, fromSoup: ILSoup, toSoup: ILSoup) {}
    func unionSoup(_ unionSoup: ILUnionSoup, pushedEntry entry: ILSoupEntry, fromSoup: ILSoup, toSoup: ILSoup) {}
    func unionSoup(_ unionSoup: ILUnionSoup, poppedEntry entry: ILSoupEntry, fromSoup: ILSoup, toSoup: ILSoup) {}
    @available(*, deprecated, message: "Use poppedEntry (this misspelled API is retained only for compatibility)")
    func unionSoup(_ unionSoup: ILUnionSoup, popedEntry entry: ILSoupEntry, fromSoup: ILSoup, toSoup: ILSoup) {
        self.unionSoup(unionSoup, poppedEntry: entry, fromSoup: fromSoup, toSoup: toSoup)
    }
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
                    unionDelegate?.unionSoup(self, poppedEntry: moved, fromSoup: loadedSoups[i], toSoup: loadedSoups[i - 1])
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
            if let value {
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
        let mirror = Mirror(reflecting: object)
        return mirror.children.first(where: { $0.label == keyPath })?.value
    }
}

public extension NSArray {
    func il_allValuesDigest() -> Data {
        SoupDigest.allValuesDigest(self as? [Any] ?? [])
    }

    func il_deepMutableCopy() -> NSMutableArray {
        SoupDeepCopy.mutableArrayCopy(self as? [Any] ?? [])
    }
}

public extension NSDictionary {
    func il_allKeysDigest() -> Data {
        SoupDigest.allKeysDigest(self as? [AnyHashable: Any] ?? [:])
    }

    func il_allKeysAndValuesDigest() -> Data {
        SoupDigest.allKeysAndValuesDigest(self as? [AnyHashable: Any] ?? [:])
    }

    func il_sha224AllKeys() -> String {
        il_allKeysDigest().base64EncodedString()
    }

    func il_sha224AllKeysAndValues() -> String {
        il_allKeysAndValuesDigest().base64EncodedString()
    }

    func il_deepMutableCopy() -> NSMutableDictionary {
        SoupDeepCopy.mutableDictionaryCopy(self as? [AnyHashable: Any] ?? [:])
    }
}
