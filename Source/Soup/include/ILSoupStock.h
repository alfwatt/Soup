#import <Foundation/Foundation.h>

#ifdef SWIFT_PACKAGE
#import "ILSoup.h"
#else
#import <Soup/ILSoup.h>
#endif

NS_ASSUME_NONNULL_BEGIN

/// Stock in-memory implementation of the ILSoup protocol
@interface ILSoupStock : NSObject <ILSoup>

// MARK: - Index Operations

/// Add the entry to all existing indices
- (void) indexEntry:(id<ILSoupEntry>) entry;

/// Remove the entry from all existing indices
- (void) removeFromIndices:(id<ILSoupEntry>) entry;

// MARK: - Sequence Operations

/// Add the entry to all exiting sequences
- (void) sequenceEntry:(id<ILSoupEntry>) entry;

/// Remote the entry from all existing sequences
- (void) removeFromSequences:(id<ILSoupEntry>) entry;

@end

NS_ASSUME_NONNULL_END
