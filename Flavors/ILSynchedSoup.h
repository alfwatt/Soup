@import Foundation;

#import <Soup/ILSoup.h>

/// synchronizes all soup operations so you can easily access a soup from multiple threads or queues
@interface ILSynchedSoup : NSObject <ILSoup>
@property(retain) id<ILSoup> synchronized;

// MARK: -

+ (instancetype) synchronizedSoup:(id<ILSoup>) synched;

@end
