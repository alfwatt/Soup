import XCTest
@testable import Soup

final class SoupSwiftTests: XCTestCase {
    func testAllValuesDigestIsStable() {
        let values: [Any] = ["alpha", 42, true]
        let firstDigest = SoupDigest.allValuesDigest(values)
        let secondDigest = SoupDigest.allValuesDigest(values)
        XCTAssertEqual(firstDigest, secondDigest)
    }

    func testAllValuesDigestAvoidsSeparatorCollisions() {
        XCTAssertNotEqual(
            SoupDigest.allValuesDigest(["a+b"]),
            SoupDigest.allValuesDigest(["a", "b"])
        )
    }

    func testAllKeysAndValuesDigestChangesWithMutation() {
        var dictionary: [AnyHashable: Any] = ["name": "Soup", "version": 1]
        let firstDigest = SoupDigest.allKeysAndValuesDigest(dictionary)
        dictionary["version"] = 2
        let secondDigest = SoupDigest.allKeysAndValuesDigest(dictionary)
        XCTAssertNotEqual(firstDigest, secondDigest)
    }

    func testAllKeysAndValuesDigestIgnoresInsertionOrder() {
        let first: [AnyHashable: Any] = ["name": "Soup", "version": 1, "kind": "framework"]
        let second: [AnyHashable: Any] = ["kind": "framework", "version": 1, "name": "Soup"]
        XCTAssertEqual(SoupDigest.allKeysAndValuesDigest(first), SoupDigest.allKeysAndValuesDigest(second))
    }

    func testEntryAliasIsFixedLengthDigest() {
        let entry = StockEntry(keys: ["name": "Soup", "version": 1])
        let alias: SoupAlias = entry.entryHash
        let encodedAlias = String(alias.absoluteString.dropFirst("alias:".count))

        XCTAssertEqual(alias.scheme, "alias")
        XCTAssertEqual(encodedAlias.utf8.count, 22)
        XCTAssertTrue(encodedAlias.allSatisfy { "123456789ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz".contains($0) })
        XCTAssertEqual(alias, entry.entryHash)
    }

    func testMutableDictionaryCopyIsDeep() {
        let original: [AnyHashable: Any] = [
            "meta": [
                "name": "Soup"
            ],
            "tags": ["framework", "swift"]
        ]

        let mutable = SoupDeepCopy.mutableDictionaryCopy(original)
        let nestedMeta = mutable["meta"] as? NSMutableDictionary
        nestedMeta?["name"] = "Updated"

        let nestedTags = mutable["tags"] as? NSMutableArray
        nestedTags?.add("conversion")

        let originalMeta = original["meta"] as? [AnyHashable: Any]
        XCTAssertEqual(originalMeta?["name"] as? String, "Soup")

        let originalTags = original["tags"] as? [String]
        XCTAssertEqual(originalTags?.count, 2)
    }

    func testCursorIncludesAddedEntriesAndPrunedEntriesKeepTheirSequence() {
        let soup = SoupStock(name: "PruneTest")
        let index = soup.createIndex("name")
        let sequence = soup.createSequence("value") as? StockSequence
        sequence?.timeKeyPath = "date"

        let first = StockEntry(keys: [ILSoupEntryIdentityUUID: "radio", "name": "a", "value": NSNumber(value: 1), "date": Date(timeIntervalSince1970: 1)])
        let second = StockEntry(keys: [ILSoupEntryIdentityUUID: "radio", "name": "a", "value": NSNumber(value: 2), "date": Date(timeIntervalSince1970: 2)])
        _ = soup.addEntry(first)
        _ = soup.addEntry(second)
        XCTAssertEqual(soup.cursor.entries.count, 2)

        soup.pruneEntries([first])
        XCTAssertEqual(soup.cursor.entries.count, 1)
        XCTAssertNil(soup.gotoAlias(first.entryHash))
        XCTAssertFalse(index.includesEntry(first))
        XCTAssertTrue(index.includesEntry(second))

        var times: [Date] = [], values: [NSNumber] = []
        XCTAssertTrue(sequence?.fetchSequence(for: second, times: &times, values: &values) ?? false)
        XCTAssertEqual(values, [1, 2])
    }

    func testPruneAncestorsKeepsTheMostRecentVersion() {
        let soup = SoupStock(name: "AncestorTest")
        let sequence = soup.createSequence("value") as? StockSequence
        sequence?.timeKeyPath = "date"

        let first = StockEntry(keys: [ILSoupEntryIdentityUUID: "radio", "value": NSNumber(value: 1), "date": Date(timeIntervalSince1970: 1)])
        let second = first.mutatedEntry(["value": NSNumber(value: 2), "date": Date(timeIntervalSince1970: 2)])
        let third = second.mutatedEntry(["value": NSNumber(value: 3), "date": Date(timeIntervalSince1970: 3)])
        let other = StockEntry(keys: [ILSoupEntryIdentityUUID: "other", "value": NSNumber(value: 9)])
        let otherNext = other.mutatedEntry(["value": NSNumber(value: 10)])
        [first, second, third, other, otherNext].forEach { _ = soup.addEntry($0) }

        soup.pruneAncestors(of: third)
        XCTAssertNil(soup.gotoAlias(first.entryHash))
        XCTAssertNil(soup.gotoAlias(second.entryHash))
        XCTAssertNotNil(soup.gotoAlias(third.entryHash))
        XCTAssertNotNil(soup.gotoAlias(other.entryHash)) // another entry's versions are kept

        soup.pruneAncestors()
        XCTAssertNil(soup.gotoAlias(other.entryHash))
        XCTAssertEqual(Set(soup.cursor.entries.map { $0.entryHash }), [third.entryHash, otherNext.entryHash])

        var times: [Date] = [], values: [NSNumber] = []
        XCTAssertTrue(sequence?.fetchSequence(for: third, times: &times, values: &values) ?? false)
        XCTAssertEqual(values, [1, 2, 3]) // the history of the versions is kept
    }

    func testPruneAncestorsKeepingAndMatching() {
        let soup = SoupStock(name: "UndoTest")
        var versions = [StockEntry(keys: [ILSoupEntryIdentityUUID: "radio", "date": Date(timeIntervalSince1970: 0)])]
        for second in 1...5 {
            versions.append(versions.last!.mutatedEntry(["date": Date(timeIntervalSince1970: TimeInterval(second))]))
        }
        versions.forEach { _ = soup.addEntry($0) }
        let present = { versions.map { soup.gotoAlias($0.entryHash) != nil } }

        // ancestors older than 2 seconds, beyond the nearest one, the undo limit
        soup.pruneAncestors(keeping: 1, matching: NSPredicate(format: "date < %@", Date(timeIntervalSince1970: 2) as NSDate))
        XCTAssertEqual(present(), [false, false, true, true, true, true])

        // an undo limit of two keeps the two nearest ancestors of the latest version
        soup.pruneAncestors(of: versions[5], keeping: 2)
        XCTAssertEqual(present(), [false, false, false, true, true, true])

        soup.pruneEntries(matching: NSPredicate(format: "date < %@", Date(timeIntervalSince1970: 4) as NSDate))
        XCTAssertEqual(present(), [false, false, false, false, true, true])
    }

    // MARK: - Persistence

    /// a soup with an identity index and a sequence, as the reader of a saved soup sets itself up
    private func persistentSoup() -> SoupStock {
        let soup = SoupStock(name: "persistent")
        _ = soup.createIdentityIndex("mac")
        (soup.createSequence("value") as? StockSequence)?.timeKeyPath = "date"
        return soup
    }

    func testSoupFileRoundTripsEntriesVersionsAndSequences() throws {
        let soup = persistentSoup()
        let first = StockEntry().mutatedEntry(["mac": "00:11", "value": NSNumber(value: 1), "date": Date(timeIntervalSince1970: 1),
                                               "link": URL(string: "https://istumbler.net")!])
        let second = first.mutatedEntry(["value": NSNumber(value: 2), "date": Date(timeIntervalSince1970: 2)])
        let third = second.mutatedEntry(["value": NSNumber(value: 3), "date": Date(timeIntervalSince1970: 3)])
        [first, second, third].forEach { _ = soup.addEntry($0) }
        soup.pruneAncestors(of: third) // the sequence keeps the history of the pruned versions

        let read = persistentSoup()
        try read.read(soup.soupData().data)
        let latest = try XCTUnwrap(read.queryIdentityIndex("mac")?.entry(withValue: "00:11"))
        XCTAssertEqual(latest.entryKeys["value"] as? NSNumber, 3)
        XCTAssertEqual(latest.entryKeys["link"] as? URL, URL(string: "https://istumbler.net"))
        XCTAssertTrue(latest.entryKeys[ILSoupEntryAncestorEntryHash] is SoupAlias)
        XCTAssertTrue(type(of: latest) == StockEntry.self)

        var times: [Date] = [], values: [NSNumber] = []
        XCTAssertTrue(try XCTUnwrap(read.querySequence("value")).fetchSequence(for: latest, times: &times, values: &values))
        XCTAssertEqual(values, [1, 2, 3])
        XCTAssertEqual(times, [1, 2, 3].map { Date(timeIntervalSince1970: $0) })
    }

    func testSoupFileLeavesOutValuesAPropertyListCantHave() throws {
        let soup = persistentSoup()
        _ = soup.addEntry(StockEntry(keys: ["mac": "00:22", "object": NSObject(), "missing": NSNull()]))
        let (data, omitted) = try soup.soupData()
        XCTAssertEqual(omitted, 2)

        let read = persistentSoup()
        try read.read(data)
        let entry = try XCTUnwrap(read.queryIdentityIndex("mac")?.entry(withValue: "00:22"))
        XCTAssertNil(entry.entryKeys["object"])
        XCTAssertNil(entry.entryKeys["missing"])
    }

    func testSoupFileAdjustsDatesAsItsRead() throws {
        let soup = persistentSoup()
        let first = StockEntry().mutatedEntry(["mac": "00:33", "value": NSNumber(value: 1), "date": Date(timeIntervalSince1970: 10)])
        _ = soup.addEntry(first)
        _ = soup.addEntry(first.mutatedEntry(["value": NSNumber(value: 2), "date": Date(timeIntervalSince1970: 20)]))
        let data = try soup.soupData().data

        // moved so the newest date, a version's mutation date, is an hour from now
        let now = Date().addingTimeInterval(3600)
        let newest = try XCTUnwrap(SoupStock.newestDate(in: data))
        let shift = now.timeIntervalSince(newest)
        let read = persistentSoup()
        try read.read(data) { $0.addingTimeInterval(shift) }
        let latest = try XCTUnwrap(read.queryIdentityIndex("mac")?.entry(withValue: "00:33"))
        XCTAssertEqual(latest.entryKeys["date"] as? Date, Date(timeIntervalSince1970: 20 + shift))
        var times: [Date] = [], values: [NSNumber] = []
        _ = read.querySequence("value")?.fetchSequence(for: latest, times: &times, values: &values)
        XCTAssertEqual(times.count, 2)
        XCTAssertEqual(times.last?.timeIntervalSince(times.first ?? .distantPast), 10)
    }

    func testFileSoupSavesAndLoads() throws {
        let path = NSTemporaryDirectory() + UUID().uuidString + ".soup"
        defer { try? FileManager.default.removeItem(atPath: path) }
        let soup = FileSoup(filePath: path)
        _ = soup.createIdentityIndex("mac")
        _ = soup.addEntry(StockEntry(keys: ["mac": "00:44", ILSoupEntryIdentityUUID: "four"]))
        try soup.save()

        let loaded = FileSoup(filePath: path)
        _ = loaded.createIdentityIndex("mac")
        try loaded.load()
        XCTAssertNotNil(loaded.queryIdentityIndex("mac")?.entry(withValue: "00:44"))
        XCTAssertThrowsError(try loaded.read(Data("not a soup".utf8)))
    }
}
