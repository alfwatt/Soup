#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSArray (Soup)

// MARK: - Digests

- (NSData*) allValuesDigest;

// TODO: ~ (NSData*) deepValuesDigest

// MARK: - Deep Copy

- (NSMutableArray*) deepMutableCopy;

@end

NS_ASSUME_NONNULL_END
