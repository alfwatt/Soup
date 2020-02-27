@import Foundation;

#import <Soup/ILSoupStock.h>

@protocol ILUnionSoupDelegate;

/// ILUnionSoup provides a single query interface to multiple soups
@interface ILUnionSoup : ILSoupStock

/// the soups in the union, in priority order
@property(readonly) NSArray<id<ILSoup>>* loadedSoups;

/// the delegate of the union
@property(assign) id<ILUnionSoupDelegate> delegate;

// MARK: - Managing Soups

/// adds a soup to the union
- (void) addSoup:(id<ILSoup>) soup;

/// insert at index in the stack
- (void) insertSoup:(id<ILSoup>) soup atIndex:(NSUInteger) index;

/// removes a soup from the union
- (void) removeSoup:(id<ILSoup>) soup;

// MARK: - Managing Entries

/// copy an entry from one soup to another
- (void) copyEntry:(NSString*) entryHash fromSoup:(id<ILSoup>) fromSoup toSoup:(id<ILSoup>) toSoup;

/// move an entry from on soup to another
- (void) moveEntry:(NSString*) entryHash fromSoup:(id<ILSoup>) fromSoup toSoup:(id<ILSoup>) toSoup;

/// search the stack from the top for the entry and move it down one soup
- (void) pushEntry:(NSString*) entryHash;

/// search the stack from the bottom for the entry and move it up one soup
- (void) popEntry:(NSString*) entryHash;

@end

// MARK: -

/// union multiple soups behind a single query interface
@protocol ILUnionSoupDelegate <ILSoupDelegate>

/// added a soup to the union
- (void) unionSoup:(ILUnionSoup*) unionSoup addedSoup:(id<ILSoup>) soup;

/// removed a soup from the union
- (void) unionSoup:(ILUnionSoup*) unionSoup removedSoup:(id<ILSoup>) soup;

// MARK: - 

/// union copied entry from one soup to another
- (void) unionSoup:(ILUnionSoup*) unionSoup copiedEntry:(id<ILSoupEntry>) entry fromSoup:(id<ILSoupEntry>) fromSoup toSoup:(id<ILSoupEntry>) toSoup;

/// union moved entry from one soup to another
- (void) unionSoup:(ILUnionSoup*) unionSoup movedEntry:(id<ILSoupEntry>) entry fromSoup:(id<ILSoupEntry>) fromSoup toSoup:(id<ILSoupEntry>) toSoup;

/// union pushed entry from one soup to another
- (void) unionSoup:(ILUnionSoup*) unionSoup pushedEntry:(id<ILSoupEntry>) entry fromSoup:(id<ILSoupEntry>) fromSoup toSoup:(id<ILSoupEntry>) toSoup;

/// union poped entry from one soup to another
- (void) unionSoup:(ILUnionSoup*) unionSoup popedEntry:(id<ILSoupEntry>) entry fromSoup:(id<ILSoupEntry>) fromSoup toSoup:(id<ILSoupEntry>) toSoup;

@end
