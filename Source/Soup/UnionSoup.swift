import Foundation

public protocol UnionSoupDelegate: SoupDelegate {
    func unionSoup(_ unionSoup: UnionSoup, addedSoup soup: Soup)
    func unionSoup(_ unionSoup: UnionSoup, removedSoup soup: Soup)
    func unionSoup(_ unionSoup: UnionSoup, copiedEntry entry: SoupEntry, fromSoup: Soup, toSoup: Soup)
    func unionSoup(_ unionSoup: UnionSoup, movedEntry entry: SoupEntry, fromSoup: Soup, toSoup: Soup)
    func unionSoup(_ unionSoup: UnionSoup, pushedEntry entry: SoupEntry, fromSoup: Soup, toSoup: Soup)
    func unionSoup(_ unionSoup: UnionSoup, poppedEntry entry: SoupEntry, fromSoup: Soup, toSoup: Soup)
}

public extension UnionSoupDelegate {
    func unionSoup(_ unionSoup: UnionSoup, addedSoup soup: Soup) {}
    func unionSoup(_ unionSoup: UnionSoup, removedSoup soup: Soup) {}
    func unionSoup(_ unionSoup: UnionSoup, copiedEntry entry: SoupEntry, fromSoup: Soup, toSoup: Soup) {}
    func unionSoup(_ unionSoup: UnionSoup, movedEntry entry: SoupEntry, fromSoup: Soup, toSoup: Soup) {}
    func unionSoup(_ unionSoup: UnionSoup, pushedEntry entry: SoupEntry, fromSoup: Soup, toSoup: Soup) {}
    func unionSoup(_ unionSoup: UnionSoup, poppedEntry entry: SoupEntry, fromSoup: Soup, toSoup: Soup) {}
    @available(*, deprecated, message: "Use poppedEntry (this misspelled API is retained only for compatibility)")
    func unionSoup(_ unionSoup: UnionSoup, popedEntry entry: SoupEntry, fromSoup: Soup, toSoup: Soup) {
        self.unionSoup(unionSoup, poppedEntry: entry, fromSoup: fromSoup, toSoup: toSoup)
    }
}

open class UnionSoup: SoupStock {
    public private(set) var loadedSoups: [Soup] = []
    public weak var unionDelegate: UnionSoupDelegate?

    open override func querySoup(_ query: NSPredicate) -> SoupCursor {
        let all = loadedSoups.flatMap { $0.querySoup(query).entries }
        return StockCursor(entries: all)
    }

    open func addSoup(_ soup: Soup) {
        loadedSoups.append(soup)
        unionDelegate?.unionSoup(self, addedSoup: soup)
    }

    open func insertSoup(_ soup: Soup, at index: UInt) {
        loadedSoups.insert(soup, at: min(Int(index), loadedSoups.count))
        unionDelegate?.unionSoup(self, addedSoup: soup)
    }

    open func removeSoup(_ soup: Soup) {
        loadedSoups.removeAll { $0 === soup }
        unionDelegate?.unionSoup(self, removedSoup: soup)
    }

    open func copyEntry(_ entryHash: String, fromSoup: Soup, toSoup: Soup) -> Bool {
        guard let entry = fromSoup.gotoAlias(entryHash) else { return false }
        let copy = entry.copy() as? SoupEntry ?? entry
        _ = toSoup.addEntry(copy)
        unionDelegate?.unionSoup(self, copiedEntry: copy, fromSoup: fromSoup, toSoup: toSoup)
        return true
    }

    open func moveEntry(_ entryHash: String, fromSoup: Soup, toSoup: Soup) -> Bool {
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
