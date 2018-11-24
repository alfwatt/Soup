@import Foundation;

@interface NSDictionary (Hashcodes)

- (NSData*) allKeysData;
- (NSData*) allKeysAndValuesData;

- (NSString*) sha224AllKeys;
- (NSString*) sha224AllKeysAndValues;

@end
