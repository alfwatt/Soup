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
    ILStockIndex* stockIndex = [ILStockIndex new];
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
        self.entriesStorage = entries;
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
    id<ILSoupEntry> next = self.entriesStorage[self.indexStorage];
    self.indexStorage = (self.indexStorage + 1);
    return next;
}

- (void) resetCursor
{
    self.indexStorage = 0;
}

@end
