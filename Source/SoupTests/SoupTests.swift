import XCTest
import Soup

let ILName = "entryName"
let ILEmail = "entryEmail"
let ILPhone = "entryPhone"
let ILURL = "entryURL"
let ILNotes = "entryNotes"
let ILBirthday = "entryBirthday"
let ILParents = "entryParents"
let ILSpouse = "entrySpouse"


final class AddressBookEntry: StockEntry {
    dynamic var entryName: String? = nil
    dynamic var entryEmail: String? = nil
    dynamic var entryPhone: String? = nil
    dynamic var entryURL: URL? = nil
    dynamic var entryNotes: String? = nil
    dynamic var entryBirthday: Date? = nil
    dynamic var entryParents: Array<String>? = nil
    dynamic var entrySpouse: String? = nil
}

// MARK: - Overrides



// MARK: -

final class SoupTests: XCTestCase {

    override func setUpWithError() throws {}

    // MARK: - SoupClock

    func testSoupClockEarlier() {
        let earlier: Date = Date(timeIntervalSinceNow: -1) // a second earlier
        XCTAssert(SoupClock.earlier().compare(earlier) == .orderedSame)
    }

    func testSoupClockLater() {
        let later: Date = Date(timeIntervalSinceNow: 1) // a second later
        XCTAssert(SoupClock.later().compare(later) == .orderedSame)
    }

    func testSoupClockAnytime() {
        XCTAssert(SoupClock.anytime().compare(Date()) == .orderedSame)
    }

    func testSoupClockNever() {
        XCTAssert(SoupClock.never().compare(Date()) == .orderedAscending)
    }

    func testSoupClockWhenever() {
        XCTAssert(SoupClock.whenever().compare(Date()) == .orderedSame)
    }

    // MARK: - Soup

    // TODO: make these test cases functions which take the soup as an argument
    // add driver methods to test various soup types (memory/file/remote/&c.)

    func testSoupCreation() throws {
        let memory: MemorySoup? = MemorySoup(name: "Soup Creation Test")
        XCTAssert(memory != nil, "Create Test Soup")
    }

    func testSoupDescription() throws {
        let memory: MemorySoup = MemorySoup(name: "Soup Description Test")
        memory.soupDescription = "Test Soup"
        XCTAssert(memory.soupDescription == "Test Soup", "make sure soup description is readable")
    }

    func testSoupCreateBlankEntry() throws {
        let memory: MemorySoup = MemorySoup(name: "Create Blank Entry Test")
        let blankEntry: SoupEntry? = memory.createBlankEntry()
        XCTAssert(blankEntry != nil, "Created Blank Entry")
    }

    func testSoupIdentityIndexCreation() throws {
        let memory: MemorySoup = MemorySoup(name: "Identity Index Creation Test")
        _ = memory.createEntryIdentityIndex()
        XCTAssert(memory.queryIndex(ILSoupEntryIdentityUUID) != nil, "Created Entry Identity Index")
    }

    func testSoupValueIndexCreation() throws {
        let memory: MemorySoup = MemorySoup(name: "Value Index Creation Test")
        _ = memory.createValueIndex(ILName)
        XCTAssert(memory.queryIndex(ILName) != nil, "Created Value Index")
    }

    func testSoupValueIndexQueries() throws {
        let memory: MemorySoup = MemorySoup(name: "Value Index Creation Test")
        _ = memory.createValueIndex(ILName)
        XCTAssert(memory.queryIndex(ILName) != nil, "Created Value Index")

        _ = memory.createBlankEntry().mutatedEntry([ILName: "First Entry"])
    }

    func testSoupIdentityIndex() throws {
        let memory = MemorySoup(name: "Identity Index Test")
        _ = memory.createEntryIdentityIndex()

        let first = memory.createBlankEntry()
        _ = memory.add(first)
        let firstUUID = first.entryKeys[ILSoupEntryIdentityUUID] as! String
        let firstFound = memory.queryEntryIdentityIndex(firstUUID)
        XCTAssert(first === firstFound, "First entry is firstFound")

        // copies
        let copy = first.copy() as! MutableSoupEntry
        _ = memory.add(copy)
        let copyFound = memory.queryEntryIdentityIndex(firstUUID)
        XCTAssert(first !== copyFound, "copyFound is not the first")
        XCTAssert(copy === copyFound, "copyFound is the copy")

        // duplicates
        let duplicate = first.duplicate()
        _ = memory.add(duplicate)
        let duplicateUUID = duplicate.entryKeys[ILSoupEntryIdentityUUID] as! String
        XCTAssert(duplicate !== first, "duplicate is a new entry")
        XCTAssert(duplicateUUID != firstUUID, "duplicate has a new UUID")

        let duplicateFound = memory.queryEntryIdentityIndex(duplicateUUID)
        XCTAssert(duplicateFound === duplicate, "duplicate found is duplicate")

        // mutants
        let mutant = first.mutatedEntry(["mutant": true])
        let mutantUUID = mutant.entryKeys[ILSoupEntryIdentityUUID] as! String
        XCTAssert(mutant !== first, "mutant is a new entry")
        XCTAssert(mutantUUID == firstUUID, "mutant has new UUID")

        _ = memory.add(mutant)
        let mutantFound = memory.queryEntryIdentityIndex(firstUUID)
        XCTAssert(mutantFound === mutant)
    }

    func testSoupAncestryIndex() throws {
        let memory = MemorySoup(name: "Ancestry Index Test")
        _ = memory.createAncestryIndex()

        if let ancestery = memory.queryAncestryIndex() {
            let first = memory.createBlankEntry()
            _ = memory.add(first)
            XCTAssertFalse(ancestery.includesEntry(first))

            let ancestor = ancestery.ancestor(of: first)
            XCTAssert(ancestor == nil)

            let second = first.mutatedEntry([
                ILName: "Second Generation"
            ])
            _ = memory.add(second)

            XCTAssert(ancestery.includesEntry(second))
            XCTAssert(ancestery.ancestor(of: second) === first)
            XCTAssert(ancestery.ancestry(of: second).entries.count == 2)

            let third = second.mutatedEntry([
                ILName: "Third Generation"
            ])
            _ = memory.add(third)
            XCTAssert(ancestery.includesEntry(third))
            XCTAssert(ancestery.ancestor(of: third) === second)
            XCTAssert(ancestery.ancestry(of: third).entries.count == 3)

            let fourth = third.mutatedEntry([
                ILName: "Fourth Generation"
            ])
            _ = memory.add(fourth)
            XCTAssert(ancestery.includesEntry(fourth))
            XCTAssert(ancestery.ancestor(of: fourth) === third)
            XCTAssert(ancestery.ancestry(of: fourth).entries.count == 4)

            let fifth = fourth.mutatedEntry([
                ILName: "Fifth Generation"
            ])
            _ = memory.add(fifth)
            XCTAssert(ancestery.includesEntry(fifth))
            XCTAssert(ancestery.ancestor(of: fifth) === fourth)
            XCTAssert(ancestery.ancestry(of: fifth).entries.count == 5)

            let progenators = ancestery.progenitors()
            XCTAssert(progenators.count == 1)
        }
    }

    // tests the uses of dynamic properties from a swfit defined subclass of StockEntry
    func testSoupAddressBookEntry() throws {
        var testEntry: AddressBookEntry? = AddressBookEntry()
        testEntry!.entryName = "test entry name"
        XCTAssert(testEntry!.entryName == "test entry name")

        testEntry = nil // test dealloc

        var nextEntry: AddressBookEntry? = AddressBookEntry()
        nextEntry!.entryName = "next entry"
        nextEntry!.entryEmail = "test@example.com"
        nextEntry!.entryNotes = "on to the next one"

        let memory: MemorySoup = MemorySoup(name: "Test Soup");
        let nextEntryAlias: SoupAlias = memory.add(nextEntry!)
        nextEntry = nil // should still exist in the soup, let's look it up

        let storedEntry: AddressBookEntry = memory.gotoAlias(nextEntryAlias) as! AddressBookEntry
        XCTAssert(storedEntry.entryName == "next entry")
    }

    func testSoupNumberIndex() throws {
        let memory = MemorySoup(name: "Numbers")
        _ = memory.createNumberIndex("number")

        // create some numbers to populate the index
        _ = memory.add((memory.createBlankEntry().mutatedEntry(["number": 1])))
        _ = memory.add((memory.createBlankEntry().mutatedEntry(["number": 2])))
        _ = memory.add((memory.createBlankEntry().mutatedEntry(["number": 2])))
        _ = memory.add((memory.createBlankEntry().mutatedEntry(["number": 3])))
        _ = memory.add((memory.createBlankEntry().mutatedEntry(["number": 3])))
        _ = memory.add((memory.createBlankEntry().mutatedEntry(["number": 3])))
        _ = memory.add((memory.createBlankEntry().mutatedEntry(["number": 4])))
        _ = memory.add((memory.createBlankEntry().mutatedEntry(["number": 5])))
        _ = memory.add((memory.createBlankEntry().mutatedEntry(["number": 10])))
        _ = memory.add((memory.createBlankEntry().mutatedEntry(["number": 100])))
        _ = memory.add((memory.createBlankEntry().mutatedEntry(["number": 1000])))

        let oneCursor = memory.queryNumberIndex("number")!.entries(withValue: 1)
        XCTAssert(oneCursor.entries.count == 1)

        let twoCursor = memory.queryNumberIndex("number")!.entries(withValue: 2)
        XCTAssert(twoCursor.entries.count == 2)

        let threeCursor = memory.queryNumberIndex("number")!.entries(withValue: 3)
        XCTAssert(threeCursor.entries.count == 3)

        let zeroTwoCursor = memory.queryNumberIndex("number")!.entriesBetween(0, and: 2)
        XCTAssert(zeroTwoCursor.entries.count == 3)

        let zeroInfCursor = memory.queryNumberIndex("number")!.entriesBetween(0, and: 999999999)
        XCTAssert(zeroInfCursor.entries.count == 11)
    }

    func testSoupTextIndexDuplicates() throws {
        let memory = MemorySoup(name: "Identity")
        let name = memory.createTextIndex(ILName)
        let email = memory.createTextIndex(ILEmail)

        let fin2 = memory.createBlankEntry().mutatedEntry([
            ILName: "Fin Gru-Liu the 2nd",
            ILEmail: "fin.gl2@example.com"
        ])
        _ = memory.add(fin2)

        let fin3 = memory.createBlankEntry().mutatedEntry([
            ILName: "Fin Gru-Liu the 3rd",
            ILEmail: "fin.gl2@example.com" // Same email, different name
        ])
        _ = memory.add(fin3)

        // check the number of entires in the indicies
        XCTAssert(name.entryCount == 2)
        XCTAssert(email.entryCount == 2)

        // check for an exact match of one records
        let fin2ndMatches = name.entries(matching: "Fin Gru-Liu the 2nd")
        XCTAssert(fin2ndMatches.entries.count == 1)

        // check for a regex match of two records
        let finMatches = name.entries(matching: "Fin Gru-Liu.*")
        XCTAssert(finMatches.entries.count == 2)

        // check for an email match of two records
        let emailIterator = email.entries(matching: "fin\\.gl2@example\\.com")
        XCTAssert(emailIterator.entries.count == 2)

    }

    // MARK: - SoupSnapshot

    func testSoupSnapShot() throws {
        let memory: MemorySoup = MemorySoup(name: "Snappy Soup")
        _ = memory.createEntryIdentityIndex()
        _ = memory.createIdentityIndex(ILEmail)

        let snapshot = SoupSnapshot(map: [
            ILSoupSnapshotProperties: [
                ILName: [
                    ILSoupSnapshotStorageKey: "NameStorage"
                ],
                ILEmail: [:],
                "LastUpdated": [:]
                // TODO value transformer for the date
            ],
            ILSoupSnapshotMatchKeyPath: ILEmail // match on the email address, we'll change the name for each snapshot
        ])

        let object = [
            ILName: "Test Name",
            ILEmail: "name@example.com",
            "LastUpdated": Date(),
        ] as NSMutableDictionary

        let firstVersion = snapshot.snapshot(object, in:memory)
        XCTAssert(firstVersion != nil, "Snapshot created")

        object[ILName] = "First, Las"
        object["LastUpdated"] = Date()
        let secondVersion = snapshot.snapshot(object, in:memory)
        XCTAssert(secondVersion != nil, "2nd Snapshot created")

        if let firstVersion = firstVersion, let secondVersion = secondVersion {
            XCTAssert((firstVersion.entryKeys[ILSoupEntryIdentityUUID] as? String) == (secondVersion.entryKeys[ILSoupEntryIdentityUUID] as? String), "UUIDs match")
            XCTAssert((firstVersion.entryKeys[ILEmail] as? String) == (secondVersion.entryKeys[ILEmail] as? String), "Emails match")
            XCTAssert((firstVersion.entryKeys["NameStorage"] as? String) != (secondVersion.entryKeys["NameStorage"] as? String), "Names Changed")
            XCTAssert((firstVersion.entryKeys["LastUpdated"] as? Date) != (secondVersion.entryKeys["LastUpdated"] as? Date), "Date Changed")
        }
    }

    func testSoupSnapShotOfObject() throws {
        let memory: MemorySoup = MemorySoup(name: "Snappy Object Soup")
        _ = memory.createIdentityIndex("uuid")

        let snapshot = SoupSnapshot(map: [
            ILSoupSnapshotProperties: [
                "identifier.UUIDString": [ILSoupSnapshotStorageKey: "uuid"], // KVC through a dotted key path
                "name": [ILSoupSnapshotValueTransformer: SnapshotUppercaseTransformer()],
                "missing.key": [:] // not KVC compliant, captures nothing
            ],
            ILSoupEntryClassName: NSStringFromClass(SnapshotEntry.self),
            ILSoupSnapshotMatchKeyPath: "identifier.UUIDString" // matched in the "uuid" storage key's index
        ])

        let object = SnapshotSubject()
        let capture = snapshot.capture(object)
        XCTAssertEqual(capture["uuid"] as? String, object.identifier.uuidString, "dotted key path captured")
        XCTAssertEqual(capture["name"] as? String, "SUBJECT", "value transformed")
        XCTAssertNil(capture["missing.key"], "unknown key captures nothing")

        let firstVersion = snapshot.snapshot(object, in: memory, with: ["rssi": NSNumber(value: -60)])
        XCTAssert(firstVersion is SnapshotEntry, "entry class from the map")
        XCTAssertEqual(firstVersion?.entryKeys["rssi"] as? NSNumber, NSNumber(value: -60), "additional values merged")

        object.name = "renamed"
        let secondVersion = snapshot.snapshot(object, in: memory, with: ["rssi": NSNumber(value: -50)])
        XCTAssertEqual(firstVersion?.entryKeys[ILSoupEntryIdentityUUID] as? String,
                       secondVersion?.entryKeys[ILSoupEntryIdentityUUID] as? String, "matched the previous version")
        XCTAssertEqual(secondVersion?.entryKeys["name"] as? String, "RENAMED", "name updated")
        XCTAssertEqual(memory.queryIdentityIndex("uuid")?.entryCount, 1, "one entry per identifier")
    }

    func testSnapshotEditsChainVersions() throws {
        let memory = MemorySoup(name: "Chained Soup")
        _ = memory.createIdentityIndex("uuid")
        let snapshot = SoupSnapshot(map: [
            ILSoupSnapshotProperties: ["identifier.UUIDString": [ILSoupSnapshotStorageKey: "uuid"], "name": [:]],
            ILSoupSnapshotMatchKeyPath: "identifier.UUIDString"
        ])

        let object = SnapshotSubject()
        let first = snapshot.snapshot(object, in: memory, with: ["kind": "keyboard"], edits: { previous, values in
            XCTAssertNil(previous, "no previous version")
        })
        XCTAssertNotNil(snapshot.previousEntry(matching: ["uuid": object.identifier.uuidString], in: memory), "found by identity")

        let second = snapshot.snapshot(object, in: memory, with: [:], edits: { previous, values in
            XCTAssertEqual(previous?.entryKeys["kind"] as? String, "keyboard", "edits get the previous version")
            values["kind"] = values["kind"] ?? previous?.entryKeys["kind"] // keep a value this snapshot doesn't have
        })
        XCTAssertEqual(second?.entryKeys["kind"] as? String, "keyboard", "kept by the edits")
        XCTAssertEqual(second?.entryKeys[ILSoupEntryAncestorEntryHash] as? SoupAlias, first?.entryHash, "chained to the previous version")
    }

    func testSequenceAcrossVersions() throws {
        let memory = MemorySoup(name: "Sequence Soup")
        guard let sequence = memory.createSequence("signal") as? StockSequence else { return XCTFail("stock sequence") }
        sequence.timeKeyPath = "sampleDate"
        sequence.maximumValues = 3

        let start = Date()
        var entry = memory.createBlankEntry().mutatedEntry(["signal": NSNumber(value: -60), "sampleDate": start])
        _ = memory.addEntry(entry)
        for step in 1...3 { // each sample is a new version of the entry
            entry = entry.mutatedEntry(["signal": NSNumber(value: -60 - step), "sampleDate": start.addingTimeInterval(TimeInterval(step))])
            _ = memory.addEntry(entry)
        }
        _ = memory.addEntry(entry.mutatedEntry(["name": "renamed"])) // same sample date, replaces the last value
        _ = memory.addEntry(entry.mutatedEntry(["signal": NSNull(), "sampleDate": start.addingTimeInterval(10)])) // no value, skipped

        var times: [Date] = []
        var values: [NSNumber] = []
        XCTAssertTrue(sequence.fetchSequence(for: entry, times: &times, values: &values), "sequence for the entry")
        XCTAssertEqual(values.map { $0.intValue }, [-61, -62, -63], "every version adds to one timeline, capped at 3")
        XCTAssertEqual(times.first, start.addingTimeInterval(1), "times from the sample date")
    }

    // MARK: - Teardown

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    // func testPerformanceExample() throws {
    // This is an example of a performance test case.
    //    measure {
    // Put the code you want to measure the time of here.
    //    }
    // }
}

// MARK: - Snapshot Fixtures

final class SnapshotEntry: StockEntry {}

final class SnapshotSubject: NSObject {
    @objc let identifier = NSUUID()
    @objc var name = "subject"
}

final class SnapshotUppercaseTransformer: ValueTransformer {
    override func transformedValue(_ value: Any?) -> Any? {
        (value as? String)?.uppercased()
    }
}
