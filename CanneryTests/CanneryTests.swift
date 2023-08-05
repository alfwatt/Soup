import XCTest
@testable import Soup
@testable import Cannery

class CanneryTests: XCTestCase {

    override func setUp() {}

    override func tearDown() {}

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
    
    /*
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    */
}
