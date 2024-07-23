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
        let memory: ILMemorySoup? = ILMemorySoup(name: "Test Soup")
        XCTAssert(memory != nil, "Create Test Soup")
    }

    func testSoupDescription() throws {
        let memory: ILMemorySoup = ILMemorySoup(name: "Test Soup")
        memory.soupDescription = "Test Soup"
        XCTAssert(memory.soupDescription == "Test Soup", "make sure soup description is readable")
    }

    func testSoupCreateBlankEntry() throws {
        let memory: ILMemorySoup = ILMemorySoup(name: "Test Soup")
        let blankEntry: ILSoupEntry? = memory.createBlankEntry()
        XCTAssert(blankEntry != nil, "Created Blank Entry")
    }

    func testSoupIdentityIndexCreation() throws {
        let memory: ILMemorySoup = ILMemorySoup(name: "Test Soup")
        memory.createEntryIdentityIndex()
        XCTAssert(memory.queryEntryIdentityIndex() != nil, "Created Entry Identity Index")
    }

    func testSoupAncestryIndex() throws {
        let memory = ILMemorySoup(name: "Generations")
        memory.createAncestryIndex()

        let first = memory.createBlankEntry()
        memory.add(first!)
        XCTAssertFalse(memory.queryAncestryIndex()!.includesEntry(first!))

        let ancestor = memory.queryAncestryIndex()!.ancestor(of: first!)
        XCTAssert(ancestor == nil)

        let second = first!.mutatedCopy([
            ILName: "Second Generation"
        ])
        memory.add(second)
        XCTAssert(memory.queryAncestryIndex()!.includesEntry(second))
        XCTAssert(memory.queryAncestryIndex()!.ancestor(of: second) === first)
        XCTAssert(memory.queryAncestryIndex()!.ancestery(of: second).entries.count == 2)

        let third = second.mutatedCopy([
            ILName: "Third Generation"
        ])
        memory.add(third)
        XCTAssert(memory.queryAncestryIndex()!.includesEntry(third))
        XCTAssert(memory.queryAncestryIndex()!.ancestor(of: third) === second)
        XCTAssert(memory.queryAncestryIndex()!.ancestery(of: third).entries.count == 3)

        let fourth = third.mutatedCopy([
            ILName: "Fourth Generation"
        ])
        memory.add(fourth)
        XCTAssert(memory.queryAncestryIndex()!.includesEntry(fourth))
        XCTAssert(memory.queryAncestryIndex()!.ancestor(of: fourth) === third)
        XCTAssert(memory.queryAncestryIndex()!.ancestery(of: fourth).entries.count == 4)

        let fifth = fourth.mutatedCopy([
            ILName: "Fifth Generation"
        ])
        memory.add(fifth)
        XCTAssert(memory.queryAncestryIndex()!.includesEntry(fifth))
        XCTAssert(memory.queryAncestryIndex()!.ancestor(of: fifth) === fourth)
        XCTAssert(memory.queryAncestryIndex()!.ancestery(of: fifth).entries.count == 5)
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
        memory.add((memory.createBlankEntry()?.mutatedEntry(["number": 1]))!)
        memory.add((memory.createBlankEntry()?.mutatedEntry(["number": 2]))!)
        memory.add((memory.createBlankEntry()?.mutatedEntry(["number": 2]))!)
        memory.add((memory.createBlankEntry()?.mutatedEntry(["number": 3]))!)
        memory.add((memory.createBlankEntry()?.mutatedEntry(["number": 3]))!)
        memory.add((memory.createBlankEntry()?.mutatedEntry(["number": 3]))!)
        memory.add((memory.createBlankEntry()?.mutatedEntry(["number": 4]))!)
        memory.add((memory.createBlankEntry()?.mutatedEntry(["number": 5]))!)
        memory.add((memory.createBlankEntry()?.mutatedEntry(["number": 10]))!)
        memory.add((memory.createBlankEntry()?.mutatedEntry(["number": 100]))!)
        memory.add((memory.createBlankEntry()?.mutatedEntry(["number": 1000]))!)
        
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
        
        let fin2 = memory.createBlankEntry()!.mutatedCopy([
            ILName: "Fin Gru-Liu the 2nd",
            ILEmail: "fin.gl2@example.com"
        ])
        memory.add(fin2)
        
        let fin3 = memory.createBlankEntry()!.mutatedCopy([
            ILName: "Fin Gru-Liu the 3rd",
            ILEmail: "fin.gl2@example.com" // Same email, different name
        ])
        memory.add(fin3)

        // check the number of entires in the indicies
        XCTAssert(name.count == 2)
        XCTAssert(email.count == 2)

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

    // func testSoupIdentityIndex

    // func testPerformanceExample() throws {
    // This is an example of a performance test case.
    //    measure {
    // Put the code you want to measure the time of here.
    //    }
    // }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }


}
