#import "ILStockIndex.h"
#import "ILSoupEntry.h"


@interface ILStockIndex ()
@property(nonatomic, retain) NSString* indexPathStorage;
@property(nonatomic, retain) NSMutableDictionary* indexStorage;

@end

#pragma mark -

@implementation ILStockIndex

+ (instancetype) indexWithPath:(NSString *)indexPath
{
    ILStockIndex* stockIndex = [self new];
    stockIndex.indexPathStorage = indexPath;
    stockIndex.indexStorage = [NSMutableDictionary new];

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
            entrySet = [NSMutableSet new];
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

- (id<ILSoupCursor>) entriesWithValue:(id) value
{
    ILStockCursor* cursor = nil;

    if (value) {
        NSMutableSet<id<ILSoupEntry>>* entrySet = self.indexStorage[value];
        cursor = [[ILStockCursor alloc] initWithEntries:entrySet.allObjects];
    }
    else {
        NSArray<id<ILSoupEntry>>* entryList = self.indexStorage.allValues;
        cursor = [[ILStockCursor alloc] initWithEntries:entryList];
    }
    
    return cursor;
}

#pragma mark - NSObject

- (NSString*) description
{
    return [NSString stringWithFormat:@"%@ %@ %lu entries", self.className, self.indexPath, self.indexStorage.allKeys.count];
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
    
    return [[ILStockCursor alloc] initWithEntries:matching.allObjects];
}

@end

#pragma mark -

@implementation ILStockNumberIndex

- (id<ILSoupCursor>) entriesWithValuesBetween:(NSNumber*) min and:(NSNumber*) max
{
    return nil;
}

@end

#pragma mark -

@implementation ILStockDateIndex

- (id<ILSoupCursor>) entriesWithDatesBetween:(NSDate*) earliest and:(NSDate*) latest
{
    return nil;
}

@end

#pragma mark - ILSoupStockCursor Private

@interface ILStockCursor ()
@property(nonatomic, retain) NSArray<id<ILSoupEntry>>* entriesStorage;
@property(nonatomic, assign) NSUInteger indexStorage;

@end

#pragma mark -

@implementation ILStockCursor

- (instancetype) initWithEntries:(NSArray<id<ILSoupEntry>>*) entries
{
    if (self = [super init]) {
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
    if (self.indexStorage < self.entriesStorage.count) {
        next = self.entriesStorage[self.indexStorage];
        self.indexStorage++;
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
    return [NSString stringWithFormat:@"%@ %lu items, index %lu", self.className, self.entries.count, self.index];
}

@end
