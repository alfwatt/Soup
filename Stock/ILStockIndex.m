#import "ILStockIndex.h"
#import "ILSoup.h"
#import "ILSoupEntry.h"
#import "ILSoupTime.h"

NS_ASSUME_NONNULL_BEGIN

typedef NSString ILEntryKey;
typedef NSMutableSet<ILEntryKey*> ILEntryKeySet;

@interface ILStockIndex ()
@property(nonatomic, weak) id<ILSoup> indexedSoup; // weak reference to avoid loop, the soup owns the set of Indicies
@property(nonatomic, retain) NSString* indexPathStorage;
@property(nonatomic, retain) NSMutableDictionary* indexStorage;

@end

// MARK: -

@implementation ILStockIndex

+ (instancetype) indexWithPath:(NSString *)indexPath inSoup:(id<ILSoup>) containingSoup
{
    ILStockIndex* stockIndex = self.new;
    stockIndex.indexedSoup = containingSoup;
    stockIndex.indexPathStorage = indexPath;
    stockIndex.indexStorage = NSMutableDictionary.new;

    return stockIndex;
}

// MARK: - Properties

- (NSString*) indexPath
{
    return self.indexPathStorage;
}

- (NSUInteger) count
{
    return self.indexStorage.count;
}

// MARK: - Indexing

- (void) indexEntry:(id<ILSoupEntry>) entry
{
    id value = [entry.entryKeys valueForKeyPath:self.indexPath];

    if (value) {
        ILEntryKeySet* entrySet = self.indexStorage[value]; // set of entryHash strings
        if (!entrySet) {
            entrySet = NSMutableSet.new;
            self.indexStorage[value] = entrySet;
        }
        
        if (![entrySet containsObject:entry.entryHash]) {
            [entrySet addObject:entry.entryHash];
        }
    }
}

- (void) removeEntry:(id<ILSoupEntry>) entry
{
    id value = [entry.entryKeys valueForKeyPath:self.indexPath];
    if (value) {
        ILEntryKeySet* entrySet = self.indexStorage[value];
        if (entrySet) {
            [entrySet removeObject:entry.entryHash]; // TODO remove entryHash
        }
    }
}

- (BOOL) includesEntry:(id<ILSoupEntry>) entry
{
    BOOL included = NO;
    id value = [entry.entryKeys valueForKeyPath:self.indexPath]; // get the value of the entry for this index
    if (value) {
        ILEntryKeySet* entrySet = self.indexStorage[value]; // get the set of entires indexed for this value
        if (entrySet) {
            included = [entrySet containsObject:entry.entryHash]; // check to see if we're included in that set
        }
    }
    
    return included;
}

- (id<ILSoupCursor>) allEntries
{
    return [self entriesWithValue:nil];
}

- (id<ILSoupCursor>) entriesWithValue:(nullable id) value
{
    ILStockAliasCursor* cursor = nil;

    if (value) {
        ILEntryKeySet* entrySet = self.indexStorage[value];
        if (entrySet) {
            cursor = [ILStockAliasCursor.alloc initWithAliases:entrySet.allObjects inSoup:self.indexedSoup];
        } else {
            cursor = ILStockAliasCursor.emptyCursor;
        }
    }
    else {
        ILEntryKeySet* entrySet = NSMutableSet.set;
        for (ILEntryKeySet* entrySubset in self.indexStorage.allValues) {
            [entrySet addObjectsFromArray:entrySubset.allObjects];
        }
        cursor = [ILStockAliasCursor.alloc initWithAliases:entrySet.allObjects inSoup:self.indexedSoup];
    }
    
    return cursor;
}

// MARK: -

- (NSString*) description
{
    return [NSString stringWithFormat:@"<%@ %p \"%@\" %lu entries>",
            self.class, self, self.indexPath, self.indexStorage.allKeys.count];
}

@end

// MARK: -

@implementation ILStockIdentityIndex

// MARK: - ILSoupIndex

- (void) indexEntry:(id<ILSoupEntry>) entry
{
    id value = [entry.entryKeys valueForKeyPath:self.indexPath];
    if (value) {
        self.indexStorage[value] = entry;
    }
}

- (void) removeEntry:(id<ILSoupEntry>) entry
{
    id value = [entry.entryKeys valueForKeyPath:self.indexPath];
    if (value) {
        [self.indexStorage removeObjectForKey:value];
    }
}

- (BOOL) includesEntry:(id<ILSoupEntry>) entry
{
    BOOL includesEntry = NO;
    id value = [entry.entryKeys valueForKeyPath:self.indexPath];
    
    if (value) {
        if (self.indexStorage[value] != nil) {
            includesEntry = YES;
        }
    }
    
    return includesEntry;
}

- (id<ILSoupCursor>) allEntries
{
    return [ILStockCursor.alloc initWithEntries:self.indexStorage.allValues];
}

- (id<ILSoupCursor>) entriesWithValue:(nullable id) value
{
    ILStockCursor* valueCursor = nil;
    id<ILSoupEntry> entry = [self entryWithValue:value];
    if (entry) {
        valueCursor = [ILStockCursor.alloc initWithEntries:@[entry]];
    } else {
        valueCursor = ILStockCursor.emptyCursor;
    }
    
    return valueCursor;
}

// MARK: - ILSoupIdentityIndex

- (id<ILSoupEntry>) entryWithValue:(id) value
{
    id<ILSoupEntry> entry = nil;
    
    if (value) {
        entry = self.indexStorage[value];
    }
    
    return entry;
}

@end

// MARK: - 

@interface ILStockAncestryIndex (ILStockIdentityIndex)

@end

// MARK: -

@implementation ILStockAncestryIndex

- (nullable id<ILSoupEntry>) ancestorOf:(id<ILSoupEntry>) descendant {
    id <ILSoupEntry> ancestor = nil;
    NSString* ancestorAlias = descendant.entryKeys[ILSoupEntryAncestorEntryHash];
    if (ancestorAlias) {
        ancestor = [self.indexedSoup gotoAlias:ancestorAlias];
    }
    return ancestor;
}

/// Index will be ILSoupEntryAncestorEntryHash -> ILSoupEntry[]
- (id<ILSoupCursor>) ancesteryOf:(id<ILSoupEntry>) descendant {
    NSMutableArray<id<ILSoupEntry>>* ancestery = NSMutableArray.new;
    [ancestery addObject:descendant]; // start with the descendant as they are part of this
    
    id<ILSoupEntry> nextAncestor = descendant;
    while ((nextAncestor = [self ancestorOf:nextAncestor])) {
        [ancestery addObject:nextAncestor];
    }
    
    return [ILStockCursor.alloc initWithEntries:[NSArray arrayWithArray:ancestery]];;
}

- (id<ILSoupCursor>) descendantsOf:(id<ILSoupEntry>) ancestor {
    id<ILSoupCursor> descendantCursor = nil;
    NSString* ancestorHash = ancestor.entryHash;
    if (ancestorHash) {
        descendantCursor = [self entriesWithValue:ancestorHash];
    } else {
        descendantCursor = ILStockCursor.emptyCursor;
    }
    return descendantCursor;
}

@end


// MARK: - ILStockTextIndex

@implementation ILStockTextIndex

- (id<ILSoupCursor>) entriesMatching:(NSString*) pattern;
{
    NSError* patternError = nil;
    NSRegularExpression* patternExpression = [NSRegularExpression regularExpressionWithPattern:pattern options:0 error:&patternError];

    if (!patternExpression && patternError) {
        NSLog(@"ERROR %@ compiling expression %@", patternError, pattern);
        return ILStockCursor.emptyCursor;
    }
    
    NSMutableSet* matching = [NSMutableSet new];
    
    for (NSString* keyString in self.indexStorage.allKeys) {
        if ([patternExpression matchesInString:keyString options:0 range:NSMakeRange(0, keyString.length)].count > 0) {
            [matching addObjectsFromArray:[[self entriesWithValue:keyString] entries]];
        }
    }
    
    return [ILStockCursor.alloc initWithEntries:matching.allObjects];
}

@end

// MARK: - ILStockNumberIndex

@implementation ILStockNumberIndex

- (id<ILSoupCursor>) entriesBetween:(NSNumber*) min and:(NSNumber*) max
{
    NSMutableSet* matching = NSMutableSet.new;

    for (NSNumber* keyNumber in self.indexStorage.allKeys) {
        if ((keyNumber.doubleValue >= min.doubleValue) && (keyNumber.doubleValue <= max.doubleValue)) {
            [matching addObjectsFromArray:self.indexStorage[keyNumber]];
        }
    }

    return [ILStockCursor.alloc initWithEntries:matching.allObjects];
}

@end

// MARK: - ILStockDateIndex

@implementation ILStockDateIndex

- (id<ILSoupCursor>) entriesBetween:(NSDate*) earliest and:(NSDate*) latest
{
    NSMutableSet* matching = NSMutableSet.new;

    for (NSDate* keyDate in self.indexStorage.allKeys) {
        if ((keyDate.timeIntervalSince1970 >= earliest.timeIntervalSince1970) && (keyDate.timeIntervalSince1970 <= latest.timeIntervalSince1970)) {
            [matching addObjectsFromArray:self.indexStorage[keyDate]];
        }
    }

    return [ILStockCursor.alloc initWithEntries:matching.allObjects];
}

- (id<ILSoupCursor>) entriesInRange:(id<ILSoupTime>) timeRange {
    return [self entriesBetween:timeRange.earliest and:timeRange.latest];
}

@end

// MARK: - ILStockCursor

@interface ILStockCursor ()
@property(nonatomic, retain) NSArray<id<ILSoupEntry>>* entriesStorage;
@property(nonatomic, assign) NSUInteger cursorIndex;

@end

// MARK: -

static ILStockCursor* EMPTY_STOCK_CURSOR;

@implementation ILStockCursor

+ (instancetype) emptyCursor
{
    if (!EMPTY_STOCK_CURSOR) {
        EMPTY_STOCK_CURSOR = [ILStockCursor.alloc initWithEntries:NSArray.new];
    }
    return EMPTY_STOCK_CURSOR;
}

// MARK: -

- (instancetype) initWithEntries:(NSArray<id<ILSoupEntry>>*) entries
{
    if ((self = super.init)) {
        self.entriesStorage = [NSArray arrayWithArray:entries]; // don't want someone sneaking in a mutable array here
        self.cursorIndex = 0;
    }
    
    return self;
}

// MARK: - Properties

- (NSArray<id<ILSoupEntry>>*) entries
{
    return self.entriesStorage;
}

- (NSUInteger) index
{
    return self.cursorIndex;
}

// MARK: -

- (id<ILSoupEntry> _Nullable) nextEntry
{
    id<ILSoupEntry> next = nil;
    NSUInteger index = self.cursorIndex;
    if (index < self.entriesStorage.count) {
        next = self.entriesStorage[self.cursorIndex];
        self.cursorIndex = (index + 1);
    }
    return next;
}

- (void) resetCursor
{
    self.cursorIndex = 0;
}

// MARK: -

- (NSString*) description
{
    return [NSString stringWithFormat:@"<%@ %lu items, index %lu>", self.class, self.entries.count, self.index];
}

@end

// MARK: - ILStockAliasCursor

@interface ILStockAliasCursor()
@property(nonatomic, retain) NSArray<NSString*>* aliasStorage;
@property(nonatomic, assign) NSUInteger cursorIndex;
@property(nonatomic, assign) id<ILSoup> soupStorage;
@end

// MARK: -

@implementation ILStockAliasCursor

static ILStockAliasCursor* EMPTY_ALIAS_CURSOR;

+ (instancetype) emptyCursor
{
    if (!EMPTY_ALIAS_CURSOR) {
        EMPTY_ALIAS_CURSOR = [ILStockAliasCursor.alloc initWithAliases:NSArray.new inSoup:nil];
    }
    return EMPTY_ALIAS_CURSOR;
}

// MARK: -

- (instancetype) initWithAliases:(NSArray<NSString*>*) aliases inSoup:(id<ILSoup> _Nullable) sourceSoup
{
    if ((self = super.init)) {
        self.aliasStorage = [NSArray arrayWithArray:aliases]; // no mutants
        self.cursorIndex = 0;
        self.soupStorage = sourceSoup;
    }
    
    return self;
}

- (instancetype)initWithEntries:(NSArray<id<ILSoupEntry>> *)entries
{
    return nil;
}

// MARK: - Properties

- (NSArray<id<ILSoupEntry>>*) entries
{
    NSMutableArray<id<ILSoupEntry>>* entries = NSMutableArray.new;
    if (self.soupStorage) {
        for (NSString* alias in self.aliasStorage) {
            id<ILSoupEntry> entry = [self.soupStorage gotoAlias:alias];
            [entries addObject:entry];
        }
    }
    return entries;
}

- (NSUInteger) count
{
    return self.aliasStorage.count;
}

- (NSUInteger) index
{
    return self.cursorIndex;
}

// MARK: -

- (nullable NSString*) nextAlias
{
    NSString* next = nil;
    NSUInteger index = self.cursorIndex;
    if (index < self.aliasStorage.count) {
        next = self.aliasStorage[self.cursorIndex];
        self.cursorIndex = (index + 1);
    }
    return next;
}

// MARK: -

- (id<ILSoupEntry> _Nullable) nextEntry
{
    id<ILSoupEntry> nextEntry = nil;
    NSString* nextAlias = self.nextAlias;
    if (nextAlias && self.soupStorage) {
        nextEntry = [self.soupStorage gotoAlias:nextAlias];
    }
    return nextEntry;
}

- (void) resetCursor
{
    self.cursorIndex = 0;
}

@end

NS_ASSUME_NONNULL_END
