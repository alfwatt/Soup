#import <Foundation/Foundation.h>

#if SWIFT_PACKAGE
#import "ILSoupStock.h"
#else
#import <Soup/ILSoupStock.h>
#endif

NS_ASSUME_NONNULL_BEGIN

@interface ILFileSoup : ILSoupStock
@property(nonatomic, readonly) NSString* filePath;

// MARK: -

+ (ILFileSoup*) fileSoupAtPath:(NSString*) filePath;

@end

NS_ASSUME_NONNULL_END
