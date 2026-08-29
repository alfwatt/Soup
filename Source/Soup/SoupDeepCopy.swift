import Foundation

public enum SoupDeepCopy {
    public static func mutableArrayCopy(_ array: [Any]) -> NSMutableArray {
        let mutableCopy = NSMutableArray(capacity: array.count)
        for element in array {
            mutableCopy.add(mutableObjectCopy(element))
        }
        return mutableCopy
    }

    public static func mutableDictionaryCopy(_ dictionary: [AnyHashable: Any]) -> NSMutableDictionary {
        var swiftCopy: [AnyHashable: Any] = [:]
        for (key, value) in dictionary {
            swiftCopy[key] = mutableObjectCopy(value)
        }
        return NSMutableDictionary(dictionary: swiftCopy)
    }
}

private func mutableObjectCopy(_ value: Any) -> Any {
    if let dictionary = value as? [AnyHashable: Any] {
        return SoupDeepCopy.mutableDictionaryCopy(dictionary)
    }

    if let array = value as? [Any] {
        return SoupDeepCopy.mutableArrayCopy(array)
    }

    if let dictionary = value as? NSDictionary {
        var swiftCopy: [AnyHashable: Any] = [:]
        for (key, nestedValue) in dictionary {
            if let key = key as? AnyHashable {
                swiftCopy[key] = mutableObjectCopy(nestedValue)
            }
        }
        return NSMutableDictionary(dictionary: swiftCopy)
    }

    if let array = value as? NSArray {
        let mutableCopy = NSMutableArray(capacity: array.count)
        for element in array {
            mutableCopy.add(mutableObjectCopy(element))
        }
        return mutableCopy
    }

    return value
}
