import XCTest
import Soup

let ILName = "name"
let ILEmail = "email"
let ILPhone = "phone"
let ILURL = "url"
let ILNotes = "notes"
let ILBirthday = "birthday"
let ILParents = "parents"
let ILSpouse = "spouse"

final class SoupTests: XCTestCase {

    override func setUpWithError() throws {
        /*
        let memory: ILMemorySoup = ILMemorySoup(name: "Test Soup")
        memory.createEntryIdentityIndex()
        memory.createAncestryIndex()
        memory.createIndex(ILSoupEntryDataHash)
        memory.createDateIndex(ILSoupEntryCreationDate)
        memory.createDateIndex(ILSoupEntryMutationDate)
        memory.createTextIndex(ILName)
        memory.createTextIndex(ILEmail)
        // memory.createTextIndex(ILNotes)
        
        // add some entries to the union
        memory.add(memory.createBlankEntry().mutatedEntry([
            ILName:  "iStumbler Labs",
            ILEmail: "support@istumbler.net",
            ILURL:   URL(string:"https://istumbler.net/labs") as Any,
            ILPhone: "415-449-0905"
        ]))
        
        let luca = memory.createBlankEntry().mutatedCopy([
            ILName: "LUCA",
            ILEmail: "luca@life.earth",
            ILNotes: "I live on the ocean floor"
        ])
        memory.add(luca); // BUG: the hash luca gets stored as isn't the same that the mutated entries get
        
        let john = luca.mutatedCopy([
            ILName:  "John Doe",
            ILEmail: "j.doe@example.com",
            ILNotes: NSNull()
        ])
        memory.add(john)

        let jane = luca.mutatedCopy([
            ILName:  "Jane Doe",
            ILEmail: "jane.d@example.com",
            ILNotes: NSNull()
        ])
        memory.add(jane)

        let kim = luca.mutatedCopy([
            ILName:  "Kim Gru",
            ILEmail: "kim.g@example.com",
            ILNotes: NSNull()
        ])
        memory.add(kim)
        
        let sam = luca.mutatedCopy([
            ILName:  "Sam Liu",
            ILEmail: "sam.l@example.com",
            ILNotes: NSNull()
        ])
        memory.add(sam)

        let fin = luca.mutatedCopy([
            ILName: "Fin Gru-Liu",
            ILEmail: "fin.gl@example.com",
            ILBirthday: Date(),
            ILParents: [kim.entryKeys[ILSoupEntryIdentityUUID],
                        sam.entryKeys[ILSoupEntryIdentityUUID]]
        ])
        memory.add(fin)
        
        let fin2 = fin.mutatedCopy([
            ILName: "Fin Gru-Liu the 2nd",
            ILEmail: "fin.gl2@example.com",
            ILBirthday: Date(),
            ILParents: [fin.entryKeys[ILSoupEntryIdentityUUID]] // cloned
        ])
        memory.add(fin2)
        
        let fin3 = fin2.mutatedCopy([
            ILName: "Fin Gru-Liu the 3rd",
            ILEmail: "fin.gl2@example.com",
            ILBirthday: Date(),
            ILParents: [fin2.entryKeys[ILSoupEntryIdentityUUID]]
        ])
        memory.add(fin3)
    */
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }


    // This is an example of a functional test case.
    // Use XCTAssert and related functions to verify your tests produce the correct results.
    // Any test you write for XCTest can be annotated as throws and async.
    // Mark your test throws to produce an unexpected failure when your test encounters an uncaught error.
    // Mark your test async to allow awaiting for asynchronous code to complete. Check the results with assertions afterwards.

    func testSoupCreation() throws {
        let memory: ILMemorySoup? = ILMemorySoup(name: "Test Soup")
        XCTAssert(memory != nil, "Create Test Soup")
    }
    
    func testSoupIdentityIndexCreation() throws {
        let memory: ILMemorySoup = ILMemorySoup(name: "Test Soup")
        memory.createEntryIdentityIndex()
        XCTAssert(memory.queryEntryIdentityIndex() != nil, "Created Entry Identity Index")
    }
    
    func testSoupDescription() throws {
        // setup memory soup
        let memory: ILMemorySoup = ILMemorySoup(name: "Test Soup")
        memory.soupDescription = "Test Soup"
        XCTAssert(memory.soupDescription == "Test Soup", "make sure soup description is readable")
    }

    func testSoupCreateBlank() throws {
        let memory: ILMemorySoup = ILMemorySoup(name: "Test Soup")
        let blankEntry: ILSoupEntry? = memory.createBlankEntry()
        XCTAssert(blankEntry != nil, "Created Blank Entry")
    }
    
    // func testPerformanceExample() throws {
    // This is an example of a performance test case.
    //    measure {
    // Put the code you want to measure the time of here.
    //    }
    // }

}
