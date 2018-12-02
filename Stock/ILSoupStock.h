@import Foundation;

#import <Soup/ILSoup.h>

/*! @brief Stock in-memory implementation of the ILSoup protocol */
@interface ILSoupStock : NSObject <ILSoup>

- (void) indexEntry:(id<ILSoupEntry>) entry;
- (void) removeFromIndicies:(id<ILSoupEntry>) entry;

- (void) sequenceEntry:(id<ILSoupEntry>) entry;
- (void) removeFromSequences:(id<ILSoupEntry>) entry;

@end
