@import Foundation;

#import <Soup/ILSoup.h>

/*! @brief synchronizes all soup operations so you can easily access a soup from multiple threads or queues */
@interface ILSynchedSoup : NSObject <ILSoup>
@property(retain) id<ILSoup> synchronized;

+ (instancetype) synchronizedSoup:(id<ILSoup>) synched;

@end
