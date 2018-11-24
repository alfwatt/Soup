@import Foundation;

#import <Soup/ILSoupIndex.h>

@protocol ILSoup;

#pragma mark -

@interface ILStockIndex : NSObject <ILSoupIndex>

@end

#pragma mark -

@interface ILStockIdentityIndex : ILStockIndex <ILSoupIdentityIndex>

@end

#pragma mark-

@interface ILStockTextIndex : ILStockIndex <ILSoupTextIndex>

@end

#pragma mark -

@interface ILStockNumberIndex : ILStockIndex <ILSoupNumberIndex>

@end

#pragma mark -

@interface ILStockDateIndex : ILStockIndex <ILSoupDateIndex>

@end

#pragma mark -

/*  @brief a stock cursor, which contains the entries provided */
@interface ILStockCursor : NSObject <ILSoupCursor>

- (instancetype) initWithEntries:(NSArray<id<ILSoupEntry>>*) entries;

@end

#pragma mark -

/*  @brief a cursor of Aliases, and the soup from which they can be fetched */
@interface ILStockAliasCursor : NSObject <ILSoupCursor>

- (instancetype) initWithAliases:(NSArray<NSString*>*) aliases inSoup:(id<ILSoup>) sourceSoup;

#pragma mark -

/*  @brief get the next alias in the cursor */
- (NSString*) nextAlias;

@end
