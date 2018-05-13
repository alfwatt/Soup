#import <Foundation/Foundation.h>

@interface NSData (Hashcodes)

- (NSString*) md5;
- (NSString*) sha1;
- (NSString*) sha224;
- (NSString*) sha384;
- (NSString*) sha512;

@end
