#import "NSDictionary+Soup.h"
#import "NSArray+Soup.h"

#ifdef SWIFT_PACKAGE
@import ILFoundation;
#else
#import <ILFoundation/ILFoundation.h>
#endif

NS_ASSUME_NONNULL_BEGIN

@implementation NSDictionary (Soup)

// MARK: - Digests

- (NSData*) allKeysDigest {
    NSMutableArray* keyHashes = NSMutableArray.new;
    for (NSObject* key in self.allKeys) {
        [keyHashes addObject:[NSString stringWithFormat:@"%li-%li", key.class.hash, key.hash]];
    }

    return [[keyHashes componentsJoinedByString:@"+"] dataUsingEncoding:NSUTF8StringEncoding];
}

- (NSData*) allKeysAndValuesDigest {
    NSMutableData* keysDigest = self.allKeysDigest.mutableCopy;
    NSMutableArray* valueHashes = NSMutableArray.new;
    for (NSObject* value in self.allValues) {
        [valueHashes addObject:[NSString stringWithFormat:@"%li-%li", value.class.hash, value.hash]];
    }

    NSString* valuesDigest = @":";
    valuesDigest = [valuesDigest stringByAppendingString:[valueHashes componentsJoinedByString:@"+"]];

    [keysDigest appendData:[valuesDigest dataUsingEncoding:NSUTF8StringEncoding]];

    return keysDigest;
}

// MARK: - Hashcode

- (NSString*) sha224AllKeys {
    return self.allKeysDigest.sha2_224.hexString;
}

- (NSString*) sha224AllKeysAndValues {
    return self.allKeysAndValuesDigest.sha2_224.hexString;
}

// MARK: - Deep Copy

- (NSMutableDictionary*) deepMutableCopy {
    NSMutableDictionary *mutableCopy = [NSMutableDictionary dictionaryWithDictionary:self];
    for (NSString* key in self.allKeys) {
        NSObject* obj = self[key];
        if ([obj isKindOfClass:NSDictionary.class]) {
            NSMutableDictionary *subDict = ((NSDictionary*)obj).deepMutableCopy;
            mutableCopy[key] = subDict;
        }
        else if ([obj isKindOfClass:NSArray.class]) {
            NSMutableArray *subArray = ((NSArray*)obj).deepMutableCopy;
            mutableCopy[key] = subArray;
        }
        else {
            mutableCopy[key] = obj;
        }
    }

    return mutableCopy;

}

@end

NS_ASSUME_NONNULL_END
