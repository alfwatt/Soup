@import Foundation;

#import <Soup/ILSoupStock.h>

@interface ILFileSoup : ILSoupStock
@property(nonatomic, readonly) NSString* filePath;

// MARK: -

+ (ILFileSoup*) fileSoupAtPath:(NSString*) filePath;

@end
