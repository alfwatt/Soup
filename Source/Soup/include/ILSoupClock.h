#import <Foundation/Foundation.h>

#ifdef SWIFT_PACKAGE
#import "ILSoupTime.h"
#else
#import <Soup/ILSoupTime.h>
#endif

NS_ASSUME_NONNULL_BEGIN

/// Stock implementation of the ILSoupTime protocol
@interface ILSoupClock : NSObject <ILSoupTime>

@end

NS_ASSUME_NONNULL_END
