#import <CommonCrypto/CommonDigest.h>

#import "NSData+Hashcodes.h"

@implementation NSData (Hashcodes)

- (NSString*) md5 {
    unsigned char digest[16];
    
    CC_MD5( self.bytes, (unsigned)self.length, digest);
    
    NSMutableString *output = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    
    for(int i = 0; i < CC_MD5_DIGEST_LENGTH; i++) {
        [output appendFormat:@"%02x", digest[i]];
    }
    
    return output;
}


- (NSString*) sha1 {
    uint8_t digest[CC_SHA1_DIGEST_LENGTH];

    CC_SHA1(self.bytes, (unsigned)self.length, digest);

    NSMutableString* output = [NSMutableString stringWithCapacity:CC_SHA1_BLOCK_BYTES];

    for(int i = 0; i < CC_SHA1_DIGEST_LENGTH; i++) {
        [output appendFormat:@"%02x", digest[i]];
    }

    return output;
}

- (NSString*) sha224 {
    uint8_t digest[CC_SHA224_DIGEST_LENGTH];
    
    CC_SHA224(self.bytes, (unsigned)self.length, digest);
    
    NSMutableString* output = [NSMutableString stringWithCapacity:CC_SHA224_BLOCK_BYTES];
    
    for(int i = 0; i < CC_SHA224_DIGEST_LENGTH; i++) {
        [output appendFormat:@"%02x", digest[i]];
    }
    
    return output;
}

- (NSString*) sha384 {
    uint8_t digest[CC_SHA384_DIGEST_LENGTH];
    
    CC_SHA512(self.bytes, (unsigned)self.length, digest);
    
    NSMutableString* output = [NSMutableString stringWithCapacity:CC_SHA384_BLOCK_BYTES];
    
    for(int i = 0; i < CC_SHA384_DIGEST_LENGTH; i++) {
        [output appendFormat:@"%02x", digest[i]];
    }
    
    return output;
}

- (NSString*) sha512 {
    uint8_t digest[CC_SHA512_DIGEST_LENGTH];
    
    CC_SHA512(self.bytes, (unsigned)self.length, digest);
    
    NSMutableString* output = [NSMutableString stringWithCapacity:CC_SHA512_BLOCK_BYTES];
    
    for(int i = 0; i < CC_SHA512_DIGEST_LENGTH; i++) {
        [output appendFormat:@"%02x", digest[i]];
    }
    
    return output;
}

@end
