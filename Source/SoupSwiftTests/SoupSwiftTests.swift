import XCTest
@testable import SoupSwift

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
}
