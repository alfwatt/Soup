#import "NSDictionary+Hashcodes.h"
#import "NSData+Hashcodes.h"

@implementation NSDictionary (Hashcodes)

- (NSData*) allKeysData
{
    return [[[self allKeys] componentsJoinedByString:@"+"] dataUsingEncoding:NSUTF8StringEncoding];
}

- (NSData*) allKeysAndValuesData
{
    NSMutableData* keysAndValuesData = [[self allKeysData] mutableCopy];
    NSData* valuesData = [[[self allValues] componentsJoinedByString:@"-"] dataUsingEncoding:NSUTF8StringEncoding];
    [keysAndValuesData appendData:valuesData];
    return keysAndValuesData;
}

- (NSString*) sha224AllKeys
{
    return [[self allKeysData] sha224];
}

- (NSString*) sha224AllKeysAndValues
{
    return [[self allKeysAndValuesData] sha224];
}

@end
