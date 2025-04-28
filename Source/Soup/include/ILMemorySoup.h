#import <Foundation/Foundation.h>

#ifdef SWIFT_PACKAGE
#import "ILSoupStock.h"
#else
#import <Soup/ILSoupStock.h>
#endif

NS_ASSUME_NONNULL_BEGIN

/// in memory soup, made with stock ingredients
@interface ILMemorySoup : ILSoupStock

@end

NS_ASSUME_NONNULL_END
