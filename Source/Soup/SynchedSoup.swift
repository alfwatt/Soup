import Foundation

@objc(ILSynchedSoup)
@objcMembers
open class SynchedSoup: SoupStock {
    public var synchronized: Soup
    private let lock = NSRecursiveLock()

    public required init(name soupName: String) {
        self.synchronized = MemorySoup(name: soupName)
        super.init(name: soupName)
    }

    public init(synched: Soup) {
        self.synchronized = synched
        super.init(name: synched.soupName)
    }

    public class func synchronizedSoup(_ synched: Soup) -> SynchedSoup {
        SynchedSoup(synched: synched)
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

    override open var cursor: SoupCursor {
        lock.lock()
        defer { lock.unlock() }
        return synchronized.cursor
    }

    override open func createBlankEntry() -> MutableSoupEntry {
        lock.lock()
        defer { lock.unlock() }
        return synchronized.createBlankEntry()
    }

    override open func createBlankEntry(ofClass conformsToMutableSoupEntry: MutableSoupEntry.Type) -> MutableSoupEntry? {
        lock.lock()
        defer { lock.unlock() }
        return synchronized.createBlankEntry(ofClass: conformsToMutableSoupEntry)
    }

    override open func addEntry(_ entry: SoupEntry) -> SoupAlias {
        lock.lock()
        defer { lock.unlock() }
        return synchronized.addEntry(entry)
    }

    override open func deleteEntry(_ entry: SoupEntry) {
        lock.lock()
        defer { lock.unlock() }
        synchronized.deleteEntry(entry)
    }

    override open func gotoAlias(_ alias: SoupAlias) -> MutableSoupEntry? {
        lock.lock()
        defer { lock.unlock() }
        return synchronized.gotoAlias(alias)
    }

    override open func querySoup(_ query: NSPredicate) -> SoupCursor {
        lock.lock()
        defer { lock.unlock() }
        return synchronized.querySoup(query)
    }

    override open func resetCursor() -> SoupCursor {
        lock.lock()
        defer { lock.unlock() }
        return synchronized.resetCursor()
    }

    override open func createIndex(_ indexPath: String) -> SoupIndex {
        lock.lock()
        defer { lock.unlock() }
        return synchronized.createIndex(indexPath)
    }

    override open func createSequence(_ sequencePath: String) -> SoupSequence {
        lock.lock()
        defer { lock.unlock() }
        return synchronized.createSequence(sequencePath)
    }
}
