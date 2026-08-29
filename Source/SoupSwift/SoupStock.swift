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
            .sorted { $0.key < $1.key }
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
    public private(set) var index: UInt = 0
    public var count: Int { aliases.count }
    public var entries: [ILSoupEntry] {
        aliases.compactMap { sourceSoup?.gotoAlias($0) }
    }

    public init(aliases: [String], inSoup sourceSoup: ILSoup?) {
        self.aliases = aliases
        self.sourceSoup = sourceSoup
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
        let currentEntries = entries
        guard entryRange.location < currentEntries.count else { return [] }
        let end = min(currentEntries.count, entryRange.location + entryRange.length)
        return Array(currentEntries[entryRange.location..<end])
    }
}
open class ILStockSequenceSource: NSObject, ILSoupSequenceSource {
    public let sampleDates: [Date]
    private let sequenceValues: [NSNumber]

    public init(times: [Date], andValues values: [NSNumber]) {
        sampleDates = times
        sequenceValues = values
    }

    public class func sequenceSource(withTimes times: [Date], andValues values: [NSNumber]) -> ILStockSequenceSource {
        ILStockSequenceSource(times: times, andValues: values)
    }

    public func sampleValue(at index: UInt) -> CGFloat {
        guard Int(index) < sequenceValues.count else { return 0 }
        return CGFloat(sequenceValues[Int(index)].doubleValue)
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
        let unique = Set(valueByAlias.values.map { stockCanonicalOrderingString(for: $0) })
        return unique.sorted()
    }

    open func allValues(orderedBy descriptor: NSSortDescriptor) -> [Any] {
        (allValues() as NSArray).sortedArray(using: [descriptor])
    }

    open func indexEntry(_ entry: ILSoupEntry) {
        removeEntry(entry)
        let alias = entry.entryHash
        entriesByAlias[alias] = entry
        guard let value = entry.entryKeys[indexPath] else { return }
        let valueKey = stockCanonicalOrderingString(for: value)
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
        let valueKey = stockCanonicalOrderingString(for: value)
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

open class ILStockAncestryIndex: ILStockIdentityIndex, ILSoupAncestryIndex {
    private var rootEntries: [String: ILSoupEntry] = [:]

    override open func indexEntry(_ entry: ILSoupEntry) {
        guard entry.entryKeys[ILSoupEntryAncestorEntryHash] is String else {
            rootEntries[entry.entryHash] = entry
            return
        }
        rootEntries.removeValue(forKey: entry.entryHash)
        super.indexEntry(entry)
    }

    override open func removeEntry(_ entry: ILSoupEntry) {
        rootEntries.removeValue(forKey: entry.entryHash)
        super.removeEntry(entry)
    }

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
        var roots: [String: ILSoupEntry] = rootEntries
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
        values[ILSoupEntryClassName] = String(describing: conformsToMutableSoupEntry)
        let entry = conformsToMutableSoupEntry.init(keys: values)
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
        preconditionFailure("Entry must conform to ILSoupEntry")
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
