#import <Foundation/Foundation.h>
#import <Soup/ILSoup.h>

/* @brief Performs all soup operations and delegate callbacks on particular queues with delegate callbacks made on */
@interface ILQueuedSoup : NSObject <ILSoup>
@property(retain) id<ILSoup> queued;
@property(retain) NSOperationQueue* soupOperations;

+ (instancetype) queuedSoup:(id<ILSoup>) queuedSoup soupQueue:(NSOperationQueue*) soupOps;

@end

#pragma mark -

/* @brief delegate calbacks for deferred operations */
@protocol ILQueuedSoupDelegate <ILSoupDelegate>

@end
