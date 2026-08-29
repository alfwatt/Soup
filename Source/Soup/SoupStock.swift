import Foundation

private func stockCanonicalOrderingString(for value: Any) -> String {
    if let value = value as? String {
        return value
    }
    if let value = value as? NSNumber {
        return value.stringValue
    }
    if let value = value as? Date {
        return String(value.timeIntervalSinceReferenceDate)
    }
    if let value = value as? Data {
        return value.base64EncodedString()
    }
    return String(describing: value)
}

@objc(ILStockEntry)
@objcMembers
open class StockEntry: NSObject, MutableSoupEntry {
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
            .sorted { $0.key < $1.key }
            .map { $0.value }
        return SoupDigest.allValuesDigest(dataKeys).base64EncodedString()
    }

    open var entryHash: SoupAlias {
        SoupDigest.alias(for: SoupDigest.allKeysAndValuesDigest(storage))
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

@objc(ILSoupCursor)
public protocol SoupCursor: AnyObject {
    var entries: [SoupEntry] { get }
    var index: UInt { get }
    var count: Int { get }
    func nextEntry() -> SoupEntry?
    func resetCursor()
    func entry(at entryIndex: UInt) -> SoupEntry
    func entries(in entryRange: NSRange) -> [SoupEntry]
}

@objc(ILStockCursor)
@objcMembers
open class StockCursor: NSObject, SoupCursor {
    public static let sharedEmpty = StockCursor(entries: [])
    public private(set) var entries: [SoupEntry]
    public private(set) var index: UInt = 0
    public var count: Int { entries.count }

    public class func emptyCursor() -> Self {
        self.init(entries: [])
    }

    public required init(entries: [SoupEntry]) {
        self.entries = entries
        super.init()
    }

    open func nextEntry() -> SoupEntry? {
        let i = Int(index)
        guard i < entries.count else { return nil }
        defer { index += 1 }
        return entries[i]
    }

    open func resetCursor() {
        index = 0
    }

    open func entry(at entryIndex: UInt) -> SoupEntry {
        entries[Int(entryIndex)]
    }

    open func entries(in entryRange: NSRange) -> [SoupEntry] {
        guard entryRange.location < entries.count else { return [] }
        let end = min(entries.count, entryRange.location + entryRange.length)
        return Array(entries[entryRange.location..<end])
    }
}

@objc(ILStockAliasCursor)
@objcMembers
open class StockAliasCursor: NSObject, SoupCursor {
    private let aliases: [SoupAlias]
    private weak var sourceSoup: Soup?
    public private(set) var index: UInt = 0
    public var count: Int { aliases.count }
    public var entries: [SoupEntry] {
        aliases.compactMap { sourceSoup?.gotoAlias($0) }
    }

    public init(aliases: [SoupAlias], inSoup sourceSoup: Soup?) {
        self.aliases = aliases
        self.sourceSoup = sourceSoup
        super.init()
    }

    public func nextAlias() -> SoupAlias? {
        let i = Int(index)
        guard i < aliases.count else { return nil }
        defer { index += 1 }
        return aliases[i]
    }

    open func nextEntry() -> SoupEntry? {
        if let alias = nextAlias() {
            return sourceSoup?.gotoAlias(alias)
        }
        return nil
    }

    open func resetCursor() {
        index = 0
    }

    open func entry(at entryIndex: UInt) -> SoupEntry {
        entries[Int(entryIndex)]
    }

    open func entries(in entryRange: NSRange) -> [SoupEntry] {
        let currentEntries = entries
        guard entryRange.location < currentEntries.count else { return [] }
        let end = min(currentEntries.count, entryRange.location + entryRange.length)
        return Array(currentEntries[entryRange.location..<end])
    }
}
@objc(ILStockSequenceSource)
@objcMembers
open class StockSequenceSource: NSObject, SoupSequenceSource {
    public let sampleDates: [Date]
    private let sequenceValues: [NSNumber]

    public init(times: [Date], andValues values: [NSNumber]) {
        sampleDates = times
        sequenceValues = values
    }

    public class func sequenceSource(withTimes times: [Date], andValues values: [NSNumber]) -> StockSequenceSource {
        StockSequenceSource(times: times, andValues: values)
    }

    public func sampleValue(at index: UInt) -> CGFloat {
        guard Int(index) < sequenceValues.count else { return 0 }
        return CGFloat(sequenceValues[Int(index)].doubleValue)
    }
}

@objc(ILStockSequence)
@objcMembers
open class StockSequence: NSObject, SoupSequence {
    public let sequencePath: String
    private var timelineByAlias: [SoupAlias: [(Date, NSNumber)]] = [:]

    public required init(path: String) {
        self.sequencePath = path
    }

    public class func sequence(withPath sequencePath: String) -> Self {
        self.init(path: sequencePath)
    }

    public func sequenceEntry(_ entry: SoupEntry, atTime timeIndex: Date = Date()) {
        guard let rawValue = entry.entryKeys[sequencePath] else { return }
        let value = rawValue as? NSNumber ?? NSNumber(value: 0)
        timelineByAlias[sequenceKey(for: entry), default: []].append((timeIndex, value))
    }

    public func removeEntry(_ entry: SoupEntry) {
        timelineByAlias.removeValue(forKey: sequenceKey(for: entry))
    }

    public func includesEntry(_ entry: SoupEntry) -> Bool {
        timelineByAlias[sequenceKey(for: entry)] != nil
    }

    @nonobjc public func fetchSequence(for entry: SoupEntry, times: inout [Date], values: inout [NSNumber]) -> Bool {
        guard let sequence = timelineByAlias[sequenceKey(for: entry)] else { return false }
        times = sequence.map { $0.0 }
        values = sequence.map { $0.1 }
        return true
    }

    @objc(fetchSequenceFor:times:values:)
    public func fetchSequence(for entry: SoupEntry, times: NSMutableArray, values: NSMutableArray) -> Bool {
        var sequenceTimes: [Date] = []
        var sequenceValues: [NSNumber] = []
        guard fetchSequence(for: entry, times: &sequenceTimes, values: &sequenceValues) else { return false }
        times.addObjects(from: sequenceTimes)
        values.addObjects(from: sequenceValues)
        return true
    }

    public func fetchSequenceSource(for entry: SoupEntry) -> SoupSequenceSource? {
        var times: [Date] = []
        var values: [NSNumber] = []
        guard fetchSequence(for: entry, times: &times, values: &values) else { return nil }
        return StockSequenceSource(times: times, andValues: values)
    }

    private func sequenceKey(for entry: SoupEntry) -> SoupAlias {
        entry.entryHash
    }
}
@objc(ILStockIndex)
@objcMembers
open class StockIndex: NSObject, SoupIndex {
    public let indexPath: String
    public weak var containingSoup: Soup?
    fileprivate var entriesByAlias: [SoupAlias: SoupEntry] = [:]
    fileprivate var aliasesByValue: [String: [SoupAlias]] = [:]
    fileprivate var valueByAlias: [SoupAlias: Any] = [:]
    fileprivate var keyByAlias: [SoupAlias: String] = [:]

    public required init(path indexPath: String, inSoup containingSoup: Soup) {
        self.indexPath = indexPath
        self.containingSoup = containingSoup
    }

    public class func index(withPath indexPath: String, inSoup containingSoup: Soup) -> Self {
        self.init(path: indexPath, inSoup: containingSoup)
    }

    open var valueCount: Int { aliasesByValue.keys.count }
    open var entryCount: Int { entriesByAlias.count }

    open func allValues() -> [Any] {
        let unique = Set(valueByAlias.values.map { stockCanonicalOrderingString(for: $0) })
        return unique.sorted()
    }

    open func allValues(orderedBy descriptor: NSSortDescriptor) -> [Any] {
        (allValues() as NSArray).sortedArray(using: [descriptor])
    }

    open func indexEntry(_ entry: SoupEntry) {
        removeEntry(entry)
        let alias = entry.entryHash
        entriesByAlias[alias] = entry
        guard let value = entry.entryKeys[indexPath] else { return }
        let valueKey = stockCanonicalOrderingString(for: value)
        valueByAlias[alias] = value
        keyByAlias[alias] = valueKey
        aliasesByValue[valueKey, default: []].append(alias)
    }

    open func removeEntry(_ entry: SoupEntry) {
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

    open func includesEntry(_ entry: SoupEntry) -> Bool {
        entriesByAlias[entry.entryHash] != nil
    }

    open func allEntries() -> SoupCursor {
        StockCursor(entries: Array(entriesByAlias.values))
    }

    open func entries(withValue value: Any?) -> SoupCursor {
        guard let value else { return StockCursor(entries: []) }
        let valueKey = stockCanonicalOrderingString(for: value)
        let aliases = aliasesByValue[valueKey] ?? []
        let entries = aliases.compactMap { entriesByAlias[$0] }
        return StockCursor(entries: entries)
    }
}

@objc(ILStockIdentityIndex)
@objcMembers
open class StockIdentityIndex: StockIndex, SoupIdentityIndex {
    open func entry(withValue value: Any) -> SoupEntry? {
        entries(withValue: value).entries.last
    }

    override open func indexEntry(_ entry: SoupEntry) {
        removeEntry(entry)
        let alias = entry.entryHash
        entriesByAlias[alias] = entry
        guard let value = entry.entryKeys[indexPath] else { return }
        let valueKey = stockCanonicalOrderingString(for: value)
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

@objc(ILStockAncestryIndex)
@objcMembers
open class StockAncestryIndex: StockIdentityIndex, SoupAncestryIndex {
    private var rootEntries: [SoupAlias: SoupEntry] = [:]

    override open func indexEntry(_ entry: SoupEntry) {
        guard entry.entryKeys[ILSoupEntryAncestorEntryHash] is SoupAlias else {
            rootEntries[entry.entryHash] = entry
            return
        }
        rootEntries.removeValue(forKey: entry.entryHash)
        super.indexEntry(entry)
    }

    override open func removeEntry(_ entry: SoupEntry) {
        rootEntries.removeValue(forKey: entry.entryHash)
        super.removeEntry(entry)
    }

    open func ancestor(of descendant: SoupEntry) -> SoupEntry? {
        guard let ancestorAlias = descendant.entryKeys[ILSoupEntryAncestorEntryHash] as? SoupAlias else { return nil }
        return containingSoup?.gotoAlias(ancestorAlias)
    }

    open func ancestry(of descendant: SoupEntry) -> SoupCursor {
        var chain: [SoupEntry] = [descendant]
        var cursor = descendant
        while let next = ancestor(of: cursor) {
            chain.append(next)
            cursor = next
        }
        return StockCursor(entries: chain)
    }

    open func descendants(of ancestor: SoupEntry) -> SoupCursor {
        let aliases = aliasesByValue[stockCanonicalOrderingString(for: ancestor.entryHash)] ?? []
        return StockCursor(entries: aliases.compactMap { entriesByAlias[$0] })
    }

    open func progenitors() -> SoupCursor {
        StockCursor(entries: Array(rootEntries.values))
    }
}

@objc(ILStockTextIndex)
@objcMembers
open class StockTextIndex: StockIndex, SoupTextIndex {
    open func entries(matching pattern: String) -> SoupCursor {
        guard let regex = try? NSRegularExpression(pattern: pattern) else { return StockCursor(entries: []) }
        let matches = entriesByAlias.values.filter { entry in
            guard let string = entry.entryKeys[indexPath] as? String else { return false }
            let range = NSRange(location: 0, length: string.utf16.count)
            return regex.firstMatch(in: string, range: range) != nil
        }
        return StockCursor(entries: matches)
    }
}

@objc(ILStockNumberIndex)
@objcMembers
open class StockNumberIndex: StockIndex, SoupNumberIndex {
    open func entriesBetween(_ min: NSNumber, and max: NSNumber) -> SoupCursor {
        let values = entriesByAlias.values.filter { entry in
            guard let number = entry.entryKeys[indexPath] as? NSNumber else { return false }
            return number.doubleValue >= min.doubleValue && number.doubleValue <= max.doubleValue
        }
        return StockCursor(entries: values)
    }
}

@objc(ILStockDateIndex)
@objcMembers
open class StockDateIndex: StockIndex, SoupDateIndex {
    open func entriesBetween(_ early: Date, and late: Date) -> SoupCursor {
        let values = entriesByAlias.values.filter { entry in
            guard let date = entry.entryKeys[indexPath] as? Date else { return false }
            return date >= early && date <= late
        }
        return StockCursor(entries: values)
    }

    open func entries(in timeRange: SoupTime) -> SoupCursor {
        entriesBetween(timeRange.earliest, and: timeRange.latest)
    }
}

@objc(ILSoupStock)
@objcMembers
open class SoupStock: NSObject, Soup {
    public let soupUUID: UUID = UUID()
    public var soupName: String
    public var soupDescription: String = ""
    public var soupQuery: NSPredicate = NSPredicate(value: true) {
        didSet { _ = resetCursor() }
    }
    public var defaultEntry: [String: Any] = [:]
    public weak var delegate: SoupDelegate?

    private var entriesByAlias: [SoupAlias: MutableSoupEntry] = [:]
    private var indicesByPath: [String: SoupIndex] = [:]
    private var sequencesByPath: [String: SoupSequence] = [:]
    private var defaultCursor: SoupCursor = StockCursor(entries: [])

    public required init(name soupName: String) {
        self.soupName = soupName
        super.init()
        fillNewSoup()
        _ = resetCursor()
    }

    public class func makeSoup(_ soupName: String) -> Self? {
        self.init(name: soupName)
    }

    open var cursor: SoupCursor { defaultCursor }
    open var soupIndices: [SoupIndex] { indicesByPath.values.sorted { $0.indexPath < $1.indexPath } }
    open var soupSequences: [SoupSequence] { sequencesByPath.values.sorted { $0.sequencePath < $1.sequencePath } }

    open func createBlankEntry() -> MutableSoupEntry {
        createBlankEntry(ofClass: StockEntry.self) ?? StockEntry()
    }

    open func createBlankEntry(ofClass conformsToMutableSoupEntry: MutableSoupEntry.Type) -> MutableSoupEntry? {
        var values = defaultEntry
        values[ILSoupEntryIdentityUUID] = UUID().uuidString
        values[ILSoupEntryCreationDate] = Date()
        values[ILSoupEntryClassName] = String(describing: conformsToMutableSoupEntry)
        let entry = conformsToMutableSoupEntry.init(keys: values)
        delegate?.soup(self, createdEntry: entry)
        return entry
    }

    open func add(_ entry: SoupEntry) -> SoupAlias {
        addEntry(entry)
    }

    @nonobjc open func add(_ entry: Any) -> SoupAlias {
        if let soupEntry = entry as? SoupEntry {
            return addEntry(soupEntry)
        }
        preconditionFailure("Entry must conform to SoupEntry")
    }

    open func addEntry(_ entry: SoupEntry) -> SoupAlias {
        let alias = entryAlias(entry)
        if let mutable = entry as? MutableSoupEntry {
            entriesByAlias[alias] = mutable
        } else if let copied = entry.mutableCopy() as? MutableSoupEntry {
            entriesByAlias[alias] = copied
        }
        indexEntry(entry)
        sequenceEntry(entry)
        delegate?.soup(self, addedEntry: entry)
        _ = resetCursor()
        return alias
    }

    open func deleteEntry(_ entry: SoupEntry) {
        let alias = entryAlias(entry)
        entriesByAlias.removeValue(forKey: alias)
        removeFromIndices(entry)
        removeFromSequences(entry)
        delegate?.soup(self, deletedEntry: entry)
        _ = resetCursor()
    }

    open func entryAlias(_ entry: SoupEntry) -> SoupAlias {
        entry.entryHash
    }

    open func gotoAlias(_ alias: SoupAlias) -> MutableSoupEntry? {
        entriesByAlias[alias]
    }

    open func querySoup(_ query: NSPredicate) -> SoupCursor {
        let values = entriesByAlias.values.filter { entry in
            query.evaluate(with: entry.entryKeys)
        }
        return StockCursor(entries: values)
    }

    @discardableResult
    open func resetCursor() -> SoupCursor {
        defaultCursor = querySoup(soupQuery)
        return defaultCursor
    }

    open func indexForPath(_ indexPath: String) -> SoupIndex {
        queryIndex(indexPath) ?? createIndex(indexPath)
    }

    open func createIndex(_ indexPath: String) -> SoupIndex {
        let index = StockIndex(path: indexPath, inSoup: self)
        indicesByPath[indexPath] = index
        entriesByAlias.values.forEach { index.indexEntry($0) }
        delegate?.soup(self, createdIndex: index)
        return index
    }

    open func queryIndex(_ indexPath: String) -> SoupIndex? {
        indicesByPath[indexPath]
    }

    open func createEntryIdentityIndex() -> SoupIdentityIndex {
        if let index = queryIdentityIndex(ILSoupEntryIdentityUUID) { return index }
        let index = StockIdentityIndex(path: ILSoupEntryIdentityUUID, inSoup: self)
        indicesByPath[ILSoupEntryIdentityUUID] = index
        entriesByAlias.values.forEach { index.indexEntry($0) }
        delegate?.soup(self, createdIndex: index)
        return index
    }

    open func queryEntryIdentityIndex(_ entryIdentityUUID: String) -> SoupEntry? {
        queryIdentityIndex(ILSoupEntryIdentityUUID)?.entry(withValue: entryIdentityUUID)
    }

    open func createAncestryIndex() -> SoupAncestryIndex {
        if let index = queryAncestryIndex() { return index }
        let index = StockAncestryIndex(path: ILSoupEntryAncestorEntryHash, inSoup: self)
        indicesByPath[ILSoupEntryAncestorEntryHash] = index
        entriesByAlias.values.forEach { index.indexEntry($0) }
        delegate?.soup(self, createdIndex: index)
        return index
    }

    open func queryAncestryIndex() -> SoupAncestryIndex? {
        indicesByPath[ILSoupEntryAncestorEntryHash] as? SoupAncestryIndex
    }

    open func createValueIndex(_ indexPath: String) -> SoupIndex {
        if let existing = queryValueIndex(indexPath) { return existing }
        let index = StockIndex(path: indexPath, inSoup: self)
        indicesByPath[indexPath] = index
        entriesByAlias.values.forEach { index.indexEntry($0) }
        delegate?.soup(self, createdIndex: index)
        return index
    }

    open func queryValueIndex(_ indexPath: String) -> SoupIndex? {
        indicesByPath[indexPath]
    }

    open func createIdentityIndex(_ indexPath: String) -> SoupIdentityIndex {
        if let existing = queryIdentityIndex(indexPath) { return existing }
        let index = StockIdentityIndex(path: indexPath, inSoup: self)
        indicesByPath[indexPath] = index
        entriesByAlias.values.forEach { index.indexEntry($0) }
        delegate?.soup(self, createdIndex: index)
        return index
    }

    open func queryIdentityIndex(_ indexPath: String) -> SoupIdentityIndex? {
        indicesByPath[indexPath] as? SoupIdentityIndex
    }

    open func createTextIndex(_ indexPath: String) -> SoupTextIndex {
        if let existing = queryTextIndex(indexPath) { return existing }
        let index = StockTextIndex(path: indexPath, inSoup: self)
        indicesByPath[indexPath] = index
        entriesByAlias.values.forEach { index.indexEntry($0) }
        delegate?.soup(self, createdIndex: index)
        return index
    }

    open func queryTextIndex(_ indexPath: String) -> SoupTextIndex? {
        indicesByPath[indexPath] as? SoupTextIndex
    }

    open func createNumberIndex(_ indexPath: String) -> SoupNumberIndex {
        if let existing = queryNumberIndex(indexPath) { return existing }
        let index = StockNumberIndex(path: indexPath, inSoup: self)
        indicesByPath[indexPath] = index
        entriesByAlias.values.forEach { index.indexEntry($0) }
        delegate?.soup(self, createdIndex: index)
        return index
    }

    open func queryNumberIndex(_ indexPath: String) -> SoupNumberIndex? {
        indicesByPath[indexPath] as? SoupNumberIndex
    }

    open func createDateIndex(_ indexPath: String) -> SoupDateIndex {
        if let existing = queryDateIndex(indexPath) { return existing }
        let index = StockDateIndex(path: indexPath, inSoup: self)
        indicesByPath[indexPath] = index
        entriesByAlias.values.forEach { index.indexEntry($0) }
        delegate?.soup(self, createdIndex: index)
        return index
    }

    open func queryDateIndex(_ indexPath: String) -> SoupDateIndex? {
        indicesByPath[indexPath] as? SoupDateIndex
    }

    open func createSequence(_ sequencePath: String) -> SoupSequence {
        if let existing = querySequence(sequencePath) { return existing }
        let sequence = StockSequence(path: sequencePath)
        sequencesByPath[sequencePath] = sequence
        entriesByAlias.values.forEach { sequence.sequenceEntry($0, atTime: Date()) }
        delegate?.soup(self, createdSequence: sequence)
        return sequence
    }

    open func querySequence(_ sequencePath: String) -> SoupSequence? {
        sequencesByPath[sequencePath]
    }

    open func indexEntry(_ entry: SoupEntry) {
        for index in indicesByPath.values {
            index.indexEntry(entry)
            delegate?.soup(self, updatedIndex: index)
        }
    }

    open func removeFromIndices(_ entry: SoupEntry) {
        for index in indicesByPath.values {
            index.removeEntry(entry)
            delegate?.soup(self, updatedIndex: index)
        }
    }

    open func sequenceEntry(_ entry: SoupEntry) {
        for sequence in sequencesByPath.values {
            sequence.sequenceEntry(entry, atTime: Date())
            delegate?.soup(self, updatedSequence: sequence)
        }
    }

    open func removeFromSequences(_ entry: SoupEntry) {
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

@objc(ILMemorySoup)
@objcMembers
open class MemorySoup: SoupStock {}
