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

public typealias SoupAlias = URL

public protocol SoupEntry: AnyObject, NSCopying, NSMutableCopying {
    var entryHash: SoupAlias { get }
    var dataHash: String { get }
    var keysHash: String { get }
    var entryKeys: [String: Any] { get }
    var sortedEntryKeys: [String] { get }
}

public protocol MutableSoupEntry: SoupEntry {
    init()
    init(keys: [String: Any])
    func mutatedEntry(_ mutatedValues: [String: Any]) -> Self
    func duplicateEntry() -> Self
}

public extension MutableSoupEntry {
    func duplicate() -> Self {
        duplicateEntry()
    }
}

public protocol SoupTime: AnyObject {
    static func earlier() -> SoupTime
    static func earlierThan(_ latest: Date) -> SoupTime
    static func later() -> SoupTime
    static func laterThan(_ earliest: Date) -> SoupTime
    static func anytime() -> SoupTime
    static func whenever() -> SoupTime
    static func never() -> SoupTime
    static func interval(_ seconds: TimeInterval, before latest: Date) -> SoupTime
    static func interval(_ seconds: TimeInterval, around center: Date) -> SoupTime
    static func interval(_ seconds: TimeInterval, after earliest: Date) -> SoupTime
    static func recently() -> SoupTime
    static func nowish() -> SoupTime
    static func soonish() -> SoupTime
    static func today() -> SoupTime
    static func thisMonth() -> SoupTime
    static func thisYear() -> SoupTime
    static func lastYear() -> SoupTime
    static func lastDecade() -> SoupTime
    static func lastCentury() -> SoupTime
    static func lastMillennium() -> SoupTime
    static func nextYear() -> SoupTime
    static func nextDecade() -> SoupTime
    static func nextCentury() -> SoupTime
    static func nextMillennium() -> SoupTime
    var earliest: Date { get }
    var latest: Date { get }
    init(earliest: Date, andLatest latest: Date)
    func interval() -> TimeInterval
    func compare(_ date: Date) -> ComparisonResult
}

public protocol SoupSequence: AnyObject {
    var sequencePath: String { get }
    static func sequence(withPath sequencePath: String) -> Self
    func sequenceEntry(_ entry: SoupEntry, atTime timeIndex: Date)
    func removeEntry(_ entry: SoupEntry)
    func includesEntry(_ entry: SoupEntry) -> Bool
    func fetchSequence(for entry: SoupEntry, times: inout [Date], values: inout [NSNumber]) -> Bool
    func fetchSequenceSource(for entry: SoupEntry) -> SoupSequenceSource?
}

public protocol SoupSequenceSource: AnyObject {
    var sampleDates: [Date] { get }
    func sampleValue(at index: UInt) -> CGFloat
}

public protocol SoupDelegate: AnyObject {
    func soup(_ deJour: Soup, createdEntry entry: SoupEntry)
    func soup(_ deJour: Soup, addedEntry entry: SoupEntry)
    func soup(_ deJour: Soup, deletedEntry entry: SoupEntry)
    func soup(_ deJour: Soup, createdIndex index: SoupIndex)
    func soup(_ deJour: Soup, updatedIndex index: SoupIndex)
    func soup(_ deJour: Soup, createdSequence sequence: SoupSequence)
    func soup(_ deJour: Soup, updatedSequence sequence: SoupSequence)
    func soupFilled(_ deJour: Soup)
    func soupDone(_ deJour: Soup)
}

public extension SoupDelegate {
    func soup(_ deJour: Soup, createdEntry entry: SoupEntry) {}
    func soup(_ deJour: Soup, addedEntry entry: SoupEntry) {}
    func soup(_ deJour: Soup, deletedEntry entry: SoupEntry) {}
    func soup(_ deJour: Soup, createdIndex index: SoupIndex) {}
    func soup(_ deJour: Soup, updatedIndex index: SoupIndex) {}
    func soup(_ deJour: Soup, createdSequence sequence: SoupSequence) {}
    func soup(_ deJour: Soup, updatedSequence sequence: SoupSequence) {}
    func soupFilled(_ deJour: Soup) {}
    func soupDone(_ deJour: Soup) {}
}

public protocol Soup: AnyObject {
    var soupUUID: UUID { get }
    var soupName: String { get set }
    var soupDescription: String { get set }
    var soupQuery: NSPredicate { get set }
    var cursor: SoupCursor { get }
    var defaultEntry: [String: Any] { get set }
    var delegate: SoupDelegate? { get set }
    static func makeSoup(_ soupName: String) -> Self?
    init(name soupName: String)
    func createBlankEntry() -> MutableSoupEntry
    func createBlankEntry(ofClass conformsToMutableSoupEntry: MutableSoupEntry.Type) -> MutableSoupEntry?
    func addEntry(_ entry: SoupEntry) -> SoupAlias
    func deleteEntry(_ entry: SoupEntry)
    func entryAlias(_ entry: SoupEntry) -> SoupAlias
    func gotoAlias(_ alias: SoupAlias) -> MutableSoupEntry?
    func querySoup(_ query: NSPredicate) -> SoupCursor
    @discardableResult func resetCursor() -> SoupCursor
    var soupIndices: [SoupIndex] { get }
    func indexForPath(_ indexPath: String) -> SoupIndex
    func createIndex(_ indexPath: String) -> SoupIndex
    func queryIndex(_ indexPath: String) -> SoupIndex?
    func createEntryIdentityIndex() -> SoupIdentityIndex
    func queryEntryIdentityIndex(_ entryIdentityUUID: String) -> SoupEntry?
    func createAncestryIndex() -> SoupAncestryIndex
    func queryAncestryIndex() -> SoupAncestryIndex?
    func createValueIndex(_ indexPath: String) -> SoupIndex
    func queryValueIndex(_ indexPath: String) -> SoupIndex?
    func createIdentityIndex(_ indexPath: String) -> SoupIdentityIndex
    func queryIdentityIndex(_ indexPath: String) -> SoupIdentityIndex?
    func createTextIndex(_ indexPath: String) -> SoupTextIndex
    func queryTextIndex(_ indexPath: String) -> SoupTextIndex?
    func createNumberIndex(_ indexPath: String) -> SoupNumberIndex
    func queryNumberIndex(_ indexPath: String) -> SoupNumberIndex?
    func createDateIndex(_ indexPath: String) -> SoupDateIndex
    func queryDateIndex(_ indexPath: String) -> SoupDateIndex?
    var soupSequences: [SoupSequence] { get }
    func createSequence(_ sequencePath: String) -> SoupSequence
    func querySequence(_ sequencePath: String) -> SoupSequence?
    func fillNewSoup()
    func doneWithSoup(_ appIdentifier: String)
}

public protocol SoupIndex: AnyObject {
    var indexPath: String { get }
    var valueCount: Int { get }
    func allValues() -> [Any]
    func allValues(orderedBy descriptor: NSSortDescriptor) -> [Any]
    var entryCount: Int { get }
    func indexEntry(_ entry: SoupEntry)
    func removeEntry(_ entry: SoupEntry)
    func includesEntry(_ entry: SoupEntry) -> Bool
    func allEntries() -> SoupCursor
    func entries(withValue value: Any?) -> SoupCursor
}

public protocol SoupIdentityIndex: SoupIndex {
    func entry(withValue value: Any) -> SoupEntry?
}

public protocol SoupAncestryIndex: SoupIdentityIndex {
    func ancestor(of descendant: SoupEntry) -> SoupEntry?
    func ancestry(of descendant: SoupEntry) -> SoupCursor
    func descendants(of ancestor: SoupEntry) -> SoupCursor
    func progenitors() -> SoupCursor
}

public protocol SoupTextIndex: SoupIndex {
    func entries(matching pattern: String) -> SoupCursor
}

public protocol SoupNumberIndex: SoupIndex {
    func entriesBetween(_ min: NSNumber, and max: NSNumber) -> SoupCursor
}

public protocol SoupDateIndex: SoupIndex {
    func entriesBetween(_ early: Date, and late: Date) -> SoupCursor
    func entries(in timeRange: SoupTime) -> SoupCursor
}

public extension NSArray {
    func allValuesDigest() -> Data {
        SoupDigest.allValuesDigest(self as? [Any] ?? [])
    }

    func deepMutableCopy() -> NSMutableArray {
        SoupDeepCopy.mutableArrayCopy(self as? [Any] ?? [])
    }
}

public extension NSDictionary {
    func allKeysDigest() -> Data {
        SoupDigest.allKeysDigest(self as? [AnyHashable: Any] ?? [:])
    }

    func allKeysAndValuesDigest() -> Data {
        SoupDigest.allKeysAndValuesDigest(self as? [AnyHashable: Any] ?? [:])
    }

    func sha224AllKeys() -> String {
        allKeysDigest().base64EncodedString()
    }

    func sha224AllKeysAndValues() -> String {
        allKeysAndValuesDigest().base64EncodedString()
    }

    func deepMutableCopy() -> NSMutableDictionary {
        SoupDeepCopy.mutableDictionaryCopy(self as? [AnyHashable: Any] ?? [:])
    }
}
