@import Foundation;

NS_ASSUME_NONNULL_BEGIN

@interface NSString (Hashcodes)

- (NSString*) md5;
- (NSString*) sha1;
- (NSString*) sha224;
- (NSString*) sha384;
- (NSString*) sha512;

@end

NS_ASSUME_NONNULL_END
