#import "NSArray+Soup.h"

// #import "NSData+Soup.h"
#import "NSDictionary+Soup.h"

NS_ASSUME_NONNULL_BEGIN

@implementation NSArray (Soup)

// MARK: - Digests

- (NSData*) allValuesDigest {
    NSMutableArray* valueHashes = NSMutableArray.new;
    for (NSObject* value in self) {
        [valueHashes addObject:[NSString stringWithFormat:@"%li-%li", value.class.hash, value.hash]];
    }

    return [[valueHashes componentsJoinedByString:@"+"] dataUsingEncoding:NSUTF8StringEncoding];
}

// MARK: - Deep Copy

- (NSMutableArray*) deepMutableCopy {
    NSMutableArray *mutableCopy = [NSMutableArray arrayWithCapacity:self.count];
    for (NSObject* obj in self) {
        if ([obj isKindOfClass:NSDictionary.class]) {
            [mutableCopy addObject:((NSDictionary*)obj).deepMutableCopy];
        }
        else if ([obj isKindOfClass:[NSArray class]]) {
            [mutableCopy addObject:((NSArray*)obj).deepMutableCopy];
        }
        else {
            [mutableCopy addObject:obj];
        }
    }

    return mutableCopy;
}

@end

NS_ASSUME_NONNULL_END
