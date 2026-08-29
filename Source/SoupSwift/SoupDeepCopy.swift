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
        let mutableCopy = NSMutableDictionary(capacity: dictionary.count)
        for (key, value) in dictionary {
            mutableCopy[key] = mutableObjectCopy(value)
        }
        return mutableCopy
    }
}

private func mutableObjectCopy(_ value: Any) -> Any {
    if let dictionary = value as? [AnyHashable: Any] {
        return SoupDeepCopy.mutableDictionaryCopy(dictionary)
    }

    if let array = value as? [Any] {
        return SoupDeepCopy.mutableArrayCopy(array)
    }

    return value
}
