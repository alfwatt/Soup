@import Foundation;

@interface NSDictionary (Hashcodes)

- (NSData*) allKeysDigest;
- (NSData*) allKeysAndValuesDigest;

- (NSString*) sha224AllKeys;
- (NSString*) sha224AllKeysAndValues;

@end
