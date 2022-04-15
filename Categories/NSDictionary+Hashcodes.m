#import "NSDictionary+Hashcodes.h"
#import "NSData+Hashcodes.h"

NS_ASSUME_NONNULL_BEGIN

@implementation NSDictionary (Hashcodes)

- (NSData*) allKeysDigest
{
    NSString* keysDigest = [self.allKeys componentsJoinedByString:@"+"];
    return [keysDigest dataUsingEncoding:NSUTF8StringEncoding];
}

- (NSData*) allKeysAndValuesDigest
{
    NSString* keysDigest = [self.allKeys componentsJoinedByString:@"+"];
    NSString* valuesDigest = [self.allValues componentsJoinedByString:@"-"];
    NSString* dictionaryDigest = nil;
    if (keysDigest && valuesDigest) {
        dictionaryDigest = [@[keysDigest, valuesDigest] componentsJoinedByString:@":"];
    }
    return [dictionaryDigest dataUsingEncoding:NSUTF8StringEncoding];
}

- (NSString*) sha224AllKeys
{
    return self.allKeysDigest.sha224;
}

- (NSString*) sha224AllKeysAndValues
{
    return self.allKeysAndValuesDigest.sha224;
}

@end

NS_ASSUME_NONNULL_END
