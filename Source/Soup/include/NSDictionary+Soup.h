#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSDictionary (Soup)

// MARK: - Digests

- (NSData*) allKeysDigest;
- (NSData*) allKeysAndValuesDigest;

// TODO: ~ (NSData*) deepKeysAndValuesDigest

// MARK: - Hashcodes

- (NSString*) sha224AllKeys;
- (NSString*) sha224AllKeysAndValues;

// MARK: - Deep Copy

- (NSMutableDictionary*) deepMutableCopy;

@end

NS_ASSUME_NONNULL_END
