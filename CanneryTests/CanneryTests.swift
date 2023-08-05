import XCTest
@testable import Soup
@testable import Cannery

class CanneryTests: XCTestCase {

    override func setUp() {}

    override func tearDown() {}

    func testSoupClockEarlier() {
        let now: Date = Date()
        XCTAssert(ILSoupClock.earlier().compare(now) == .orderedSame)
    }
    
    func testSoupClockLater() {
        let now: Date = Date()
        XCTAssert(ILSoupClock.later().compare(now) == .orderedAscending)
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
    
    /*
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    */
}
