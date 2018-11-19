#import "ILStockIndex.h"
#import "ILSoup.h"
#import "ILSoupEntry.h"


@interface ILStockIndex ()
@property(nonatomic, retain) NSString* indexPathStorage;
@property(nonatomic, retain) NSMutableDictionary* indexStorage;

@end

#pragma mark -

@implementation ILStockIndex

+ (instancetype) indexWithPath:(NSString *)indexPath
{
    ILStockIndex* stockIndex = self.new;
    stockIndex.indexPathStorage = indexPath;
    stockIndex.indexStorage = NSMutableDictionary.new;

    return stockIndex;
}

#pragma mark - Properties

- (NSString*) indexPath
{
    return self.indexPathStorage;
}

#pragma mark - Indexing

- (void) indexEntry:(id<ILSoupEntry>) entry
{
    id value = [entry.entryKeys valueForKeyPath:self.indexPath];
    if (value) {
        NSMutableSet<id<ILSoupEntry>>* entrySet = self.indexStorage[value];
        if (!entrySet) {
            entrySet = NSMutableSet.new;
            self.indexStorage[value] = entrySet;
        }
        
        if (![entrySet containsObject:entry]) {
            [entrySet addObject:entry];
        }
    }
}

- (void) removeEntry:(id<ILSoupEntry>) entry
{
    id value = [entry.entryKeys valueForKeyPath:self.indexPath];
    if (value) {
        NSMutableSet<id<ILSoupEntry>>* entrySet = self.indexStorage[value];
        if (entrySet) {
            [entrySet removeObject:entry];
        }
    }
}

- (BOOL) includesEntry:(id<ILSoupEntry>) entry
{
    BOOL included = NO;
    id value = [entry.entryKeys valueForKeyPath:self.indexPath];
    if (value) {
        NSMutableSet<id<ILSoupEntry>>* entrySet = self.indexStorage[value];
        if (entrySet) {
            [entrySet removeObject:entry];
        }
    }
    
    return included;
}

- (id<ILSoupCursor>) allEntries
{
    return [self entriesWithValue:nil];
}

- (id<ILSoupCursor>) entriesWithValue:(id) value
{
    ILStockCursor* cursor = nil;

    if (value) {
        NSMutableSet<id<ILSoupEntry>>* entrySet = self.indexStorage[value];
        cursor = [ILStockCursor.alloc initWithEntries:entrySet.allObjects];
    }
    else {
        NSArray<id<ILSoupEntry>>* entryList = self.indexStorage.allValues;
        cursor = [ILStockCursor.alloc initWithEntries:entryList];
    }
    
    return cursor;
}

#pragma mark - NSObject

- (NSString*) description
{
    return [NSString stringWithFormat:@"%@ %@ %lu entries", self.class, self.indexPath, self.indexStorage.allKeys.count];
}

@end

#pragma mark -

@implementation ILStockTextIndex

- (id<ILSoupCursor>) entriesWithStringValueMatching:(NSString*) pattern;
{
    NSError* patternError = nil;
    NSRegularExpression* patternExpression = [NSRegularExpression regularExpressionWithPattern:pattern options:0 error:&patternError];

    if (!patternExpression && patternError) {
        NSLog(@"ERROR %@ compiling expression %@", patternError, pattern);
        return nil;
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

#pragma mark -

@implementation ILStockNumberIndex

- (id<ILSoupCursor>) entriesWithValuesBetween:(NSNumber*) min and:(NSNumber*) max
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

#pragma mark -

@implementation ILStockDateIndex

- (id<ILSoupCursor>) entriesWithDatesBetween:(NSDate*) earliest and:(NSDate*) latest
{
    NSMutableSet* matching = NSMutableSet.new;

    for (NSDate* keyDate in self.indexStorage.allKeys) {
        if ((keyDate.timeIntervalSince1970 >= earliest.timeIntervalSince1970) && (keyDate.timeIntervalSince1970 <= latest.timeIntervalSince1970)) {
            [matching addObjectsFromArray:self.indexStorage[keyDate]];
        }
    }

    return [ILStockCursor.alloc initWithEntries:matching.allObjects];
}

@end

#pragma mark -

@interface ILStockCursor ()
@property(nonatomic, retain) NSArray<id<ILSoupEntry>>* entriesStorage;
@property(nonatomic, assign) NSUInteger indexStorage;

@end

#pragma mark -

@implementation ILStockCursor

- (instancetype) initWithEntries:(NSArray<id<ILSoupEntry>>*) entries
{
    if ((self = super.init)) {
        self.entriesStorage = [NSArray arrayWithArray:entries]; // don't want someone sneaking in a mutable array here
        self.indexStorage = 0;
    }
    
    return self;
}

#pragma mark - Properties

- (NSArray<id<ILSoupEntry>>*) entries
{
    return self.entriesStorage;
}

- (NSUInteger) index
{
    return self.indexStorage;
}

#pragma mark -

- (id<ILSoupEntry>) nextEntry
{
    id<ILSoupEntry> next = nil;
    NSUInteger index = self.indexStorage;
    if (index < self.entriesStorage.count) {
        next = self.entriesStorage[self.indexStorage];
        self.indexStorage = (index + 1);
    }
    return next;
}

- (void) resetCursor
{
    self.indexStorage = 0;
}

#pragma mark - NSObject

- (NSString*) description
{
    return [NSString stringWithFormat:@"%@ %lu items, index %lu", self.class, self.entries.count, self.index];
}

@end

#pragma mark -

@interface ILStockAliasCursor()
@property(nonatomic, retain) NSArray<NSString*>* aliasStorage;
@property(nonatomic, assign) NSUInteger indexStorage;
@property(nonatomic, assign) id<ILSoup> soupStorage;
@end

#pragma mark -

@implementation ILStockAliasCursor

- (instancetype) initWithAliases:(NSArray<NSString*>*) aliases inSoup:(id<ILSoup>) sourceSoup
{
    if ((self = super.init)) {
        self.aliasStorage = [NSArray arrayWithArray:aliases]; // no mutants
        self.indexStorage = 0;
        self.soupStorage = sourceSoup;
    }
    
    return self;
}

- (instancetype)initWithEntries:(NSArray<id<ILSoupEntry>> *)entries
{
    return nil;
}

#pragma mark - Properties

- (NSArray<id<ILSoupEntry>>*) entries
{
    return nil; // self.aliasStorage;
}

- (NSUInteger) index
{
    return self.indexStorage;
}

#pragma mark -

- (NSString*) nextAlias
{
    NSString* next = nil;
    NSUInteger index = self.indexStorage;
    if (index < self.aliasStorage.count) {
        next = self.aliasStorage[self.indexStorage];
        self.indexStorage = (index + 1);
    }
    return next;
}

#pragma mark -

- (id<ILSoupEntry>) nextEntry
{
    id<ILSoupEntry> nextEntry = nil;
    NSString* nextAlias = self.nextAlias;
    if (nextAlias) {
        nextEntry = [self.soupStorage gotoAlias:nextAlias];
    }
    return nextEntry;
}

- (void) resetCursor
{
    self.indexStorage = 0;
}

@end
