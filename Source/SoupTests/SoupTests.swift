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


final class AddressBookEntry: ILStockEntry {
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

    // MARK: - ILSoupClock

    func testSoupClockEarlier() {
        let earlier: Date = Date(timeIntervalSinceNow: -1) // a second earlier
        XCTAssert(ILSoupClock.earlier().compare(earlier) == .orderedSame)
    }

    func testSoupClockLater() {
        let later: Date = Date(timeIntervalSinceNow: 1) // a second later
        XCTAssert(ILSoupClock.later().compare(later) == .orderedSame)
    }

    func testSoupClockAnytime() {
        XCTAssert(ILSoupClock.anytime().compare(Date()) == .orderedSame)
    }

    func testSoupClockNever() {
        XCTAssert(ILSoupClock.never().compare(Date()) == .orderedAscending)
    }

    func testSoupClockWhenever() {
        XCTAssert(ILSoupClock.whenever().compare(Date()) == .orderedSame)
    }

    // MARK: - ILSoup

    // TODO: make these test cases functions which take the soup as an argument
    // add driver methods to test various soup types (memory/file/remote/&c.)

    func testSoupCreation() throws {
        let memory: ILMemorySoup? = ILMemorySoup(name: "Soup Creation Test")
        XCTAssert(memory != nil, "Create Test Soup")
    }

    func testSoupDescription() throws {
        let memory: ILMemorySoup = ILMemorySoup(name: "Soup Description Test")
        memory.soupDescription = "Test Soup"
        XCTAssert(memory.soupDescription == "Test Soup", "make sure soup description is readable")
    }

    func testSoupCreateBlankEntry() throws {
        let memory: ILMemorySoup = ILMemorySoup(name: "Create Blank Entry Test")
        let blankEntry: ILSoupEntry? = memory.createBlankEntry()
        XCTAssert(blankEntry != nil, "Created Blank Entry")
    }

    func testSoupIdentityIndexCreation() throws {
        let memory: ILMemorySoup = ILMemorySoup(name: "Identity Index Creation Test")
        memory.createEntryIdentityIndex()
        XCTAssert(memory.queryIndex(ILSoupEntryIdentityUUID) != nil, "Created Entry Identity Index")
    }

    func testSoupValueIndexCreation() throws {
        let memory: ILMemorySoup = ILMemorySoup(name: "Value Index Creation Test")
        memory.createValueIndex(ILName)
        XCTAssert(memory.queryIndex(ILName) != nil, "Created Value Index")
    }

    func testSoupValueIndexQueries() throws {
        let memory: ILMemorySoup = ILMemorySoup(name: "Value Index Creation Test")
        memory.createValueIndex(ILName)
        XCTAssert(memory.queryIndex(ILName) != nil, "Created Value Index")

        _ = memory.createBlankEntry().mutatedEntry([ILName: "First Entry"])
    }

    func testSoupIdentityIndex() throws {
        let memory = ILMemorySoup(name: "Identity Index Test")
        memory.createEntryIdentityIndex()

        let first = memory.createBlankEntry()
        memory.add(first)
        let firstUUID = first.entryKeys[ILSoupEntryIdentityUUID] as! String
        let firstFound = memory.queryEntryIdentityIndex(firstUUID)
        XCTAssert(first === firstFound, "First entry is firstFound")

        // copies
        let copy = first.copy()
        memory.add(copy)
        let copyFound = memory.queryEntryIdentityIndex(firstUUID)
        XCTAssert(first !== copyFound, "copyFound is not the first")
        XCTAssert(copy === copyFound, "copyFound is the copy")

        // duplicates
        let duplicate = first.duplicate()
        memory.add(duplicate)
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

        memory.add(mutant)
        let mutantFound = memory.queryEntryIdentityIndex(firstUUID)
        XCTAssert(mutantFound === mutant)
    }

    func testSoupAncestryIndex() throws {
        let memory = ILMemorySoup(name: "Ancestry Index Test")
        memory.createAncestryIndex()

        if let ancestery = memory.queryAncestryIndex() {
            let first = memory.createBlankEntry()
            memory.add(first)
            XCTAssertFalse(ancestery.includesEntry(first))

            let ancestor = ancestery.ancestor(of: first)
            XCTAssert(ancestor == nil)

            let second = first.mutatedEntry([
                ILName: "Second Generation"
            ])
            memory.add(second)

            XCTAssert(ancestery.includesEntry(second))
            XCTAssert(ancestery.ancestor(of: second) === first)
            XCTAssert(ancestery.ancestry(of: second).entries.count == 2)

            let third = second.mutatedEntry([
                ILName: "Third Generation"
            ])
            memory.add(third)
            XCTAssert(ancestery.includesEntry(third))
            XCTAssert(ancestery.ancestor(of: third) === second)
            XCTAssert(ancestery.ancestry(of: third).entries.count == 3)

            let fourth = third.mutatedEntry([
                ILName: "Fourth Generation"
            ])
            memory.add(fourth)
            XCTAssert(ancestery.includesEntry(fourth))
            XCTAssert(ancestery.ancestor(of: fourth) === third)
            XCTAssert(ancestery.ancestry(of: fourth).entries.count == 4)

            let fifth = fourth.mutatedEntry([
                ILName: "Fifth Generation"
            ])
            memory.add(fifth)
            XCTAssert(ancestery.includesEntry(fifth))
            XCTAssert(ancestery.ancestor(of: fifth) === fourth)
            XCTAssert(ancestery.ancestry(of: fifth).entries.count == 5)

            let progenators = ancestery.progenitors()
            XCTAssert(progenators.count == 1)
        }
    }

    // tests the uses of dynamic properties from a swfit defined subclass of ILStockEntry
    func testSoupAddressBookEntry() throws {
        var testEntry: AddressBookEntry? = AddressBookEntry()
        testEntry!.entryName = "test entry name"
        XCTAssert(testEntry!.entryName == "test entry name")

        testEntry = nil // test dealloc

        var nextEntry: AddressBookEntry? = AddressBookEntry()
        nextEntry!.entryName = "next entry"
        nextEntry!.entryEmail = "test@example.com"
        nextEntry!.entryNotes = "on to the next one"

        let memory: ILMemorySoup = ILMemorySoup(name: "Test Soup");
        let nextEntryAlias = memory.add(nextEntry!)
        nextEntry = nil // should still exist in the soup, let's look it up

        let storedEntry: AddressBookEntry = memory.gotoAlias(nextEntryAlias) as! AddressBookEntry
        XCTAssert(storedEntry.entryName == "next entry")
    }

    func testSoupNumberIndex() throws {
        let memory = ILMemorySoup(name: "Numbers")
        memory.createNumberIndex("number")

        // create some numbers to populate the index
        memory.add((memory.createBlankEntry().mutatedEntry(["number": 1])))
        memory.add((memory.createBlankEntry().mutatedEntry(["number": 2])))
        memory.add((memory.createBlankEntry().mutatedEntry(["number": 2])))
        memory.add((memory.createBlankEntry().mutatedEntry(["number": 3])))
        memory.add((memory.createBlankEntry().mutatedEntry(["number": 3])))
        memory.add((memory.createBlankEntry().mutatedEntry(["number": 3])))
        memory.add((memory.createBlankEntry().mutatedEntry(["number": 4])))
        memory.add((memory.createBlankEntry().mutatedEntry(["number": 5])))
        memory.add((memory.createBlankEntry().mutatedEntry(["number": 10])))
        memory.add((memory.createBlankEntry().mutatedEntry(["number": 100])))
        memory.add((memory.createBlankEntry().mutatedEntry(["number": 1000])))

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
        let memory = ILMemorySoup(name: "Identity")
        let name = memory.createTextIndex(ILName)
        let email = memory.createTextIndex(ILEmail)

        let fin2 = memory.createBlankEntry().mutatedEntry([
            ILName: "Fin Gru-Liu the 2nd",
            ILEmail: "fin.gl2@example.com"
        ])
        memory.add(fin2)

        let fin3 = memory.createBlankEntry().mutatedEntry([
            ILName: "Fin Gru-Liu the 3rd",
            ILEmail: "fin.gl2@example.com" // Same email, different name
        ])
        memory.add(fin3)

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

    // MARK: - ILSoupSnapshot

    func testSoupSnapShot() throws {
        let memory: ILMemorySoup = ILMemorySoup(name: "Snappy Soup")
        memory.createEntryIdentityIndex()
        memory.createIdentityIndex(ILEmail)

        let snapshot = ILSoupSnapshot(map: [
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
            XCTAssert((firstVersion.entryKeys[ILSoupEntryIdentityUUID] as! any Any.Type) == (secondVersion.entryKeys[ILSoupEntryIdentityUUID] as! any Any.Type), "UUIDs match")
            XCTAssert((firstVersion.entryKeys[ILEmail] as! any Any.Type) == (secondVersion.entryKeys[ILEmail] as! any Any.Type), "Emails match")
            XCTAssert((firstVersion.entryKeys["NameStorage"] as! any Any.Type) != (secondVersion.entryKeys["NameStorage"] as! any Any.Type), "Names Changed")
            XCTAssert((firstVersion.entryKeys["LastUpdated"] as! any Any.Type) != (secondVersion.entryKeys["LastUpdated"] as! any Any.Type), "Date Changed")
        }
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
