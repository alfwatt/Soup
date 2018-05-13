#import <Foundation/Foundation.h>
#import <Soup/ILSoupStock.h>

@protocol ILUnionSoupDelegate;

@interface ILUnionSoup : ILSoupStock
@property(readonly) NSArray<id<ILSoup>>* loadedSoups;
@property(assign) id<ILUnionSoupDelegate> delegate;

#pragma mark - Managing Soups

/* @brief adds a soup to the union */
- (void) addSoup:(id<ILSoup>) soup;

/* @brief insert at index in the stack */
- (void) insertSoup:(id<ILSoup>) soup atIndex:(NSUInteger) index;

/* @brief removes a soup from the union */
- (void) removeSoup:(id<ILSoup>) soup;

#pragma mark - Managing Entries

/* @brief copy an entry from one soup to another */
- (void) copyEntry:(NSString*) entryHash fromSoup:(id<ILSoup>) fromSoup toSoup:(id<ILSoup>) toSoup;

/* @brief move an entry from on soup to another */
- (void) moveEntry:(NSString*) entryHash fromSoup:(id<ILSoup>) fromSoup toSoup:(id<ILSoup>) toSoup;

/* @brief search the stack from the top for the entry and move it down one soup */
- (void) pushEntry:(NSString*) entryHash;

/* @brief search the stack from the bottom for the entry and move it up one soup */
- (void) popEntry:(NSString*) entryHash;

@end

#pragma mark -

@protocol ILUnionSoupDelegate <ILSoupDelegate>

/* @brief added a soup to the union */
- (void) unionSoup:(ILUnionSoup*) unionSoup addedSoup:(id<ILSoup>) soup;

/* @brief removed a soup from the union */
- (void) unionSoup:(ILUnionSoup*) unionSoup removedSoup:(id<ILSoup>) soup;

#pragma mark - Entry Managment

/* @brief union copied entry from one soup to another */
- (void) unionSoup:(ILUnionSoup*) unionSoup copiedEntry:(id<ILSoupEntry>) entry fromSoup:(id<ILSoupEntry>) fromSoup toSoup:(id<ILSoupEntry>) toSoup;

/* @brief union moved entry from one soup to another */
- (void) unionSoup:(ILUnionSoup*) unionSoup movedEntry:(id<ILSoupEntry>) entry fromSoup:(id<ILSoupEntry>) fromSoup toSoup:(id<ILSoupEntry>) toSoup;

/* @brief union pushed entry from one soup to another */
- (void) unionSoup:(ILUnionSoup*) unionSoup pushedEntry:(id<ILSoupEntry>) entry fromSoup:(id<ILSoupEntry>) fromSoup toSoup:(id<ILSoupEntry>) toSoup;

/* @brief union poped entry from one soup to another */
- (void) unionSoup:(ILUnionSoup*) unionSoup popedEntry:(id<ILSoupEntry>) entry fromSoup:(id<ILSoupEntry>) fromSoup toSoup:(id<ILSoupEntry>) toSoup;

@end
