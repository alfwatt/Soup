@import Foundation;

#import <Soup/ILSoupIndex.h>

@protocol ILSoup;

// MARK: -

@interface ILStockIndex : NSObject <ILSoupIndex>

@end

// MARK: -

@interface ILStockIdentityIndex : ILStockIndex <ILSoupIdentityIndex>

@end

// MARK:-

@interface ILStockTextIndex : ILStockIndex <ILSoupTextIndex>

@end

// MARK: -

@interface ILStockNumberIndex : ILStockIndex <ILSoupNumberIndex>

@end

// MARK: -

@interface ILStockDateIndex : ILStockIndex <ILSoupDateIndex>

@end

// MARK: -

/*! @brief a stock cursor, which contains the entries provided */
@interface ILStockCursor : NSObject <ILSoupCursor>

- (instancetype) initWithEntries:(NSArray<id<ILSoupEntry>>*) entries;

@end

// MARK: -

/*! @brief a cursor of Aliases, and the soup from which they can be fetched */
@interface ILStockAliasCursor : NSObject <ILSoupCursor>

- (instancetype) initWithAliases:(NSArray<NSString*>*) aliases inSoup:(id<ILSoup>) sourceSoup;

// MARK: -

/*! @brief get the next alias in the cursor */
- (NSString*) nextAlias;

@end
