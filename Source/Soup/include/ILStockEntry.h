#import <Foundation/Foundation.h>

#if SWIFT_PACKAGE
#import "ILSoupEntry.h"
#else
#import <Soup/ILSoupEntry.h>
#endif

NS_ASSUME_NONNULL_BEGIN

/// Stock in-memory implementation of the ILSoupEntry protocol
@interface ILStockEntry : NSObject <ILMutableSoupEntry>

- (instancetype) initWithKeys:(NSDictionary<NSString*, id>*) entryKeys NS_DESIGNATED_INITIALIZER;

// MARK: - Mutations

/// returns a dictionary of mutated values on this entry
- (nullable NSDictionary*) propertyMutations;

/// returns a new entry containing all the mutations on this entry
- (instancetype) entryWithPropertyMutations;

@end

NS_ASSUME_NONNULL_END
