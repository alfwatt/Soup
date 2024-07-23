#import <Foundation/Foundation.h>
#import <Soup/ILSoupStock.h>

NS_ASSUME_NONNULL_BEGIN

@interface ILFileSoup : ILSoupStock
@property(nonatomic, readonly) NSString* filePath;

// MARK: -

+ (ILFileSoup*) fileSoupAtPath:(NSString*) filePath;

@end

NS_ASSUME_NONNULL_END
