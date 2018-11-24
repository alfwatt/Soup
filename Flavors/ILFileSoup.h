@import Foundation;

#import <Soup/ILSoupStock.h>

@interface ILFileSoup : ILSoupStock
@property(nonatomic, readonly) NSString* filePath;

#pragma mark -

+ (ILFileSoup*) fileSoupAtPath:(NSString*) filePath;

@end
