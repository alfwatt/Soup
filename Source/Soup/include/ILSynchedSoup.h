#import <Foundation/Foundation.h>

#ifdef SWIFT_PACKAGE
#import "ILSoup.h"
#else
#import <Soup/ILSoup.h>
#endif

NS_ASSUME_NONNULL_BEGIN

/// synchronizes all soup operations so you can easily access a soup from multiple threads or queues
@interface ILSynchedSoup : NSObject <ILSoup>
@property(atomic,retain) id<ILSoup> synchronized;

// MARK: -

+ (instancetype) synchronizedSoup:(id<ILSoup>) synched;

@end

NS_ASSUME_NONNULL_END
