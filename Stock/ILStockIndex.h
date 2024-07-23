#import <Foundation/Foundation.h>
#import <Soup/ILSoupIndex.h>

NS_ASSUME_NONNULL_BEGIN

@protocol ILSoup;

// MARK: -

@interface ILStockIndex : NSObject <ILSoupIndex>
@end

// MARK: -

@interface ILStockIdentityIndex : ILStockIndex <ILSoupIdentityIndex>
@end

// MARK: -

@interface ILStockAncestryIndex : ILStockIdentityIndex <ILSoupAncestryIndex>
@end

// MARK: -

@interface ILStockTextIndex : ILStockIndex <ILSoupTextIndex>
@end

// MARK: -

@interface ILStockNumberIndex : ILStockIndex <ILSoupNumberIndex>

@end

// MARK: -

@interface ILStockDateIndex : ILStockIndex <ILSoupDateIndex>

@end

// MARK: -

/// a stock cursor, which contains the entries provided
@interface ILStockCursor : NSObject <ILSoupCursor>

- (instancetype) initWithEntries:(NSArray<id<ILSoupEntry>>*) entries;

@end

// MARK: -

/// a cursor of Aliases, and the soup from which they can be fetched
@interface ILStockAliasCursor : NSObject <ILSoupCursor>

/// @brief init the cursor with:
/// @param aliases - an array of entry aliiases in the provided
/// @param sourceSoup - if provided, use this soup to resolve aliases to entries, if not provided 
- (instancetype) initWithAliases:(NSArray<NSString*>*) aliases inSoup:(id<ILSoup> _Nullable) sourceSoup;

// MARK: -

/// - Returns: the next alias in the cursor
- (nullable NSString*) nextAlias;

@end

NS_ASSUME_NONNULL_END
