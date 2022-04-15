@import Foundation;

NS_ASSUME_NONNULL_BEGIN

@interface NSDictionary (Hashcodes)

- (NSData*) allKeysDigest;
- (NSData*) allKeysAndValuesDigest;

- (NSString*) sha224AllKeys;
- (NSString*) sha224AllKeysAndValues;

@end

NS_ASSUME_NONNULL_END
