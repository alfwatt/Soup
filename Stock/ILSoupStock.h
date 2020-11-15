@import Foundation;

#import <Soup/ILSoup.h>

/// Stock in-memory implementation of the ILSoup protocol
@interface ILSoupStock : NSObject <ILSoup>

// MARK: - Index Operations

/// Add the entry to all existing indicies
- (void) indexEntry:(id<ILSoupEntry>) entry;

/// Remove the entry from all existing indicies
- (void) removeFromIndicies:(id<ILSoupEntry>) entry;

// MARK: - Sequence Operations

/// Add the entry to all exiting sequences
- (void) sequenceEntry:(id<ILSoupEntry>) entry;

/// Remote the entry from all existing sequences
- (void) removeFromSequences:(id<ILSoupEntry>) entry;

@end
