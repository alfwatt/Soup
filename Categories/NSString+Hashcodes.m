#import <CommonCrypto/CommonDigest.h>

#import "NSString+Hashcodes.h"
#import "NSData+Hashcodes.h"

@implementation NSString (Hashcodes)

- (NSString*) md5 {
    const char *cstr = self.UTF8String;
    NSData *data = [NSData dataWithBytesNoCopy:(void*)cstr length:strlen(cstr) freeWhenDone:NO];
    return data.md5;
}

- (NSString*) sha1 {
    const char *cstr = self.UTF8String;
    NSData *data = [NSData dataWithBytesNoCopy:(void*)cstr length:strlen(cstr) freeWhenDone:NO];
    return data.sha1;
}

- (NSString*) sha224 {
    const char *cstr = self.UTF8String;
    NSData *data = [NSData dataWithBytesNoCopy:(void*)cstr length:strlen(cstr) freeWhenDone:NO];
    return data.sha224;
}

- (NSString*) sha384 {
    const char *cstr = self.UTF8String;
    NSData *data = [NSData dataWithBytesNoCopy:(void*)cstr length:strlen(cstr) freeWhenDone:NO];
    return data.sha384;
}

- (NSString*) sha512 {
    const char *cstr = self.UTF8String;
    NSData *data = [NSData dataWithBytesNoCopy:(void*)cstr length:strlen(cstr) freeWhenDone:NO];
    return data.sha512;
}

@end
