@import Foundation;

#import <Soup/ILSoupEntry.h>

NS_ASSUME_NONNULL_BEGIN

/// Stock in-memory implementaion of the ILSoupEntry protocol
@interface ILStockEntry : NSObject <ILMutableSoupEntry>

- (instancetype) initWithKeys:(NSDictionary*) entryKeys NS_DESIGNATED_INITIALIZER;

// MARK: - Mutations

/// returns a dictionary of mutated values on this entry
- (nullable NSDictionary*) propertyMutations;

/// returns a new entry contaiing all the mutations on this entry
- (instancetype) entryWithPropertyMutations;

@end

NS_ASSUME_NONNULL_END
