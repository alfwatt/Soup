#import "ILUnionSoup.h"
#import "ILSoupEntry.h"

NS_ASSUME_NONNULL_BEGIN

@interface ILUnionSoup ()
@property(retain) NSMutableArray<id<ILSoup>>* loadedSoupsStorage;

@end

// MARK: -

@implementation ILUnionSoup
@synthesize delegate;

- (instancetype) init
{
    if ((self = super.init)) {
        self.loadedSoupsStorage = [NSMutableArray new];
    }
    
    return self;
}

// MARK: - Properties

- (NSString*) soupName {
    return self.loadedSoupsStorage[0].soupName;
}

- (NSString*) soupDescription {
    NSMutableString* unionDescription = [NSMutableString stringWithFormat:@"%@ members:\n", self.class];
    NSUInteger index = 0;
    for (id<ILSoup> member in self.loadedSoupsStorage) {
        [unionDescription appendFormat:@"\t%li %@", index++, member];
    }
    return unionDescription;
}

- (NSArray<id<ILSoup>>*) loadedSoups
{
    return [self.loadedSoupsStorage copy];
}

// MARK: - Managing Soups


- (void) addSoup:(id<ILSoup>) soup
{
    if (![self.loadedSoupsStorage containsObject:soup]) {
        [self.loadedSoupsStorage addObject:soup];
    }
}

- (void) insertSoup:(id<ILSoup>) soup atIndex:(NSUInteger) index
{
    if ([self.loadedSoupsStorage containsObject:soup]) {
        [self.loadedSoupsStorage removeObject:soup];
    }
    
    [self.loadedSoupsStorage insertObject:soup atIndex:index];
}

- (void) removeSoup:(id<ILSoup>) soup
{
    [self.loadedSoupsStorage removeObject:soup];
}

// MARK: - Managing Entries

- (bool) copyEntry:(NSString*) entryHash fromSoup:(id<ILSoup>) fromSoup toSoup:(id<ILSoup>) toSoup
{
    bool success = false;
    id<ILSoupEntry> fromEntry = [fromSoup gotoAlias:entryHash];
    if (fromEntry) {
        NSString* toAlias = [toSoup addEntry:fromEntry];
        if (toAlias) {
            success = true;
        }
    }
    return success;
}

- (bool) moveEntry:(NSString*) entryHash fromSoup:(id<ILSoup>) fromSoup toSoup:(id<ILSoup>) toSoup
{
    bool success = false;
    id<ILSoupEntry> fromEntry = [fromSoup gotoAlias:entryHash];
    if (fromEntry) {
        NSString* toAlias = [toSoup addEntry:fromEntry];
        if (toAlias) { // make sure the entry was added and a new alias assigned
            [fromSoup deleteEntry:fromEntry];
            success = true;
        }
    }
    return success;
}

- (bool) pushEntry:(NSString*) entryHash
{
    bool success = false;
    NSArray* loadedSoups = self.loadedSoups; // get a snapshot
    id<ILSoup> topSoup;
    id<ILSoupEntry> entry;
    for (topSoup in loadedSoups) {
        entry = [topSoup gotoAlias:entryHash];
        if (entry) break; // for
    }
    
    if (entry) {
        id<ILSoup> bottomSoup;
        NSUInteger topIndex = [loadedSoups indexOfObject:topSoup];
        NSUInteger bottomIndex = topIndex + 1;
        if (bottomIndex < loadedSoups.count) {
            bottomSoup = loadedSoups[bottomIndex];
            NSString* bottomAlias = [bottomSoup addEntry:entry];
            if (bottomAlias) {
                [topSoup deleteEntry:entry];
                // TODO call delegate with move message
                success = true;
            }
        }
        else NSLog(@"can't push entry off bottom of stack: %@ in %@", entryHash, topSoup);
    }
    else NSLog(@"can't find entry to push: %@ in %@", entryHash, topSoup);
    // TODO call delegate with error message
    return success;
}

- (bool) popEntry:(NSString*) entryHash
{
    bool success = false;
    NSArray* loadedSoups = self.loadedSoups; // get a snapshot and search bottom up for the entryHash
    id<ILSoup> bottomSoup;
    id<ILSoupEntry> entry;
    for (bottomSoup in loadedSoups.reverseObjectEnumerator) {
        entry = [bottomSoup gotoAlias:entryHash];
        if (entry) break; // for
    }
    
    if (entry) { // we may not have found anything
        NSUInteger topIndex = [loadedSoups indexOfObject:bottomSoup] - 1;
        if (topIndex < loadedSoups.count) {
            id<ILSoup> topSoup = loadedSoups[topIndex];
            NSString* popedHash = [topSoup addEntry:entry];
            if (popedHash) { // don't delete unless it's added successfully
                [bottomSoup deleteEntry:entry];
                success = true;
                // TODO call delegate with success
            }
        }
        else NSLog(@"can't pop entry off top of stack: %@ in %@", entryHash, bottomSoup);
    }
    else NSLog(@"can't find entry to pop: %@ in %@", entryHash, bottomSoup);
    // TODO call delegate with error
    return success;
}

// MARK: - ILSoupStock Overrides

- (NSString*)addEntry:(id<ILSoupEntry>)entry
{
    for (id<ILSoup> member in self.loadedSoups) {
        [member addEntry:entry];
    }
    
    return entry.entryHash;
}

- (void) deleteEntry:(id<ILSoupEntry>) entry
{
    for (id<ILSoup> member in self.loadedSoups) {
        [member deleteEntry:entry];
    }
}

- (nullable NSString*) getAlias:(id<ILSoupEntry>) entry
{
    NSString* alias;
    for (id<ILSoup> member in self.loadedSoups) {
        alias = [member entryAlias:entry];
        if (alias) break; // for
    }
    return alias;
}

- (nullable id<ILSoupEntry>) gotoAlias:(NSString*) alias
{
    id<ILSoupEntry> entry;
    for (id<ILSoup> member in self.loadedSoups) {
        entry = [member gotoAlias:alias];
        if (entry) break; // for
    }
    return entry;
}

@end

NS_ASSUME_NONNULL_END
