#import "ILUnionSoup.h"

@interface ILUnionSoup ()
@property(retain) NSMutableArray<id<ILSoup>>* loadedSoupsStorage;

@end

#pragma mark -

@implementation ILUnionSoup
@synthesize delegate;

- (instancetype) init
{
    if (self = [super init]) {
        self.loadedSoupsStorage = [NSMutableArray new];
    }
    
    return self;
}

#pragma mark - Properties

- (NSArray<id<ILSoup>>*) loadedSoups
{
    return [self.loadedSoupsStorage copy];
}

#pragma mark - Managing Soups


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

#pragma mark - Managing Entries

- (void) copyEntry:(NSString*) entryHash fromSoup:(id<ILSoup>) fromSoup toSoup:(id<ILSoup>) toSoup
{
}

- (void) moveEntry:(NSString*) entryHash fromSoup:(id<ILSoup>) fromSoup toSoup:(id<ILSoup>) toSoup
{
}

- (void) pushEntry:(NSString*) entryHash
{
    NSArray* loadedSoups = self.loadedSoups; // get a snapshot
    id<ILSoup> topSoup;
    id<ILSoupEntry> entry;
    for (topSoup in loadedSoups) {
        entry = [topSoup gotoAlias:entryHash];
        if (entry) break; // for
    }
    
    id<ILSoup> bottomSoup;
    NSUInteger topIndex = [loadedSoups indexOfObject:topSoup];
    NSUInteger bottomIndex = topIndex + 1;
    if (bottomIndex < loadedSoups.count) {
        bottomSoup = loadedSoups[bottomIndex];
        [bottomSoup addEntry:entry];
        [topSoup deleteEntry:entry];
        
        // TODO call delegate with move message
    }
    else NSLog(@"can't push entry off bottom of stack: %@ in %@", entryHash, topSoup);
    // TODO call delegate with error message
}

- (void) popEntry:(NSString*) entryHash
{
    NSArray* loadedSoups = self.loadedSoups; // get a snapshot
    id<ILSoup> bottomSoup;
    id<ILSoupEntry> entry;
    for (bottomSoup in loadedSoups.reverseObjectEnumerator) {
        entry = [bottomSoup gotoAlias:entryHash];
        if (entry) break; // for
    }
    
    id<ILSoup> topSoup;
    NSUInteger bottomIndex = [loadedSoups indexOfObject:bottomSoup];
    NSUInteger topIndex = bottomIndex - 1;
    if (topIndex < loadedSoups.count) {
        topSoup = loadedSoups[topIndex];
        [bottomSoup deleteEntry:entry];
        [topSoup addEntry:entry];
        
        // TODO call delegate with success
    }
    else NSLog(@"can't pop entry off top of stack: %@ in %@", entryHash, bottomSoup);
    // TODO call delegate with error
}

#pragma mark - ILSoupStock Overrides

- (void)addEntry:(id<ILSoupEntry>)entry
{
    for (id<ILSoup> member in self.loadedSoups) {
        [member addEntry:entry];
    }
}

- (void) deleteEntry:(id<ILSoupEntry>) entry
{
    for (id<ILSoup> member in self.loadedSoups) {
        [member deleteEntry:entry];
    }
}

- (NSString*) getAlias:(id<ILSoupEntry>) entry
{
    NSString* alias;
    for (id<ILSoup> member in self.loadedSoups) {
        alias = [member getAlias:entry];
        if (alias) break; // for
    }
    return alias;
}

- (id<ILSoupEntry>) gotoAlias:(NSString*) alias
{
    id<ILSoupEntry> entry;
    for (id<ILSoup> member in self.loadedSoups) {
        entry = [member gotoAlias:alias];
        if (entry) break; // for
    }
    return entry;
}

@end
