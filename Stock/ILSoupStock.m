#import "ILSoupStock.h"
#import "ILStockEntry.h"
#import "ILStockIndex.h"
#import "ILStockSequence.h"

@interface ILSoupStock ()
@property(nonatomic, retain) NSString* soupUUIDStorage;
@property(nonatomic, retain) NSMutableDictionary<NSString*, id<ILSoupEntry>>* soupEntryStorage;
@property(nonatomic, retain) NSMutableDictionary<NSString*, id<ILSoupIndex>>* soupIndiciesStorage;
@property(nonatomic, retain) NSMutableDictionary<NSString*, id<ILSoupSequence>>* soupSequencesStorage;
@property(nonatomic, retain) id<ILSoupCursor> soupCursor;

- (instancetype) initWithSoupName:(NSString*) soupName;

@end

#pragma mark -

@implementation ILSoupStock
@synthesize soupName;
@synthesize soupDescription;
@synthesize soupQuery;
@synthesize defaultEntry;
@synthesize delegate;

#pragma mark -

+ (id<ILSoup>)makeSoup:(NSString*)soupName
{
    return [[ILSoupStock alloc] initWithSoupName:soupName];
}

#pragma mark -

- (instancetype) initWithSoupName:(NSString*) soupName
{
    if (self = [super init]) {
        self.soupName = soupName;
        self.soupUUIDStorage = [[NSUUID UUID] UUIDString];
        self.soupEntryStorage = [NSMutableDictionary new];
        self.soupIndiciesStorage = [NSMutableDictionary new];
        self.soupSequencesStorage = [NSMutableDictionary new];
    }
    return self;
}

#pragma mark - Properties

- (NSString*) soupUUID
{
    return self.soupUUIDStorage;
}

#pragma mark - Entries

- (id<ILSoupEntry>)createBlankEntry
{
    id<ILSoupEntry> entry = [ILStockEntry soupEntryFromKeys:self.defaultEntry];

    if ([self.delegate respondsToSelector:@selector(soup:createdEntry:)]) { // notify
        [self.delegate soup:self createdEntry:entry];
    }
    return entry;
}

- (NSString*)addEntry:(id<ILSoupEntry>)entry
{
    self.soupEntryStorage[entry.entryHash] = entry;
    NSDate* date = entry.entryKeys[ILSoupEntryMutationDate]; // try to get the mutation date

    if (!date) { // try for the creation date
        date = entry.entryKeys[ILSoupEntryCreationDate];
    }

    if (!date) { // now's the time
        date = [NSDate new];
    }
    
    for (id<ILSoupIndex> index in self.soupIndicies) { // add item to the indexes
        [index indexEntry:entry];
    }
    
    for (id<ILSoupSequence> sequence in self.soupSequences) { // add item to the sequences
        [sequence sequenceEntry:entry atTime:date];
    }
    
    if ([self.delegate respondsToSelector:@selector(soup:addedEntry:)]) { // notify
        [self.delegate soup:self addedEntry:entry];
    }
    
    return [self entryAlias:entry];
}

- (id<ILSoupEntry>)duplicateEntry:(id<ILSoupEntry>)entry
{
    NSMutableDictionary* duplicateKeys = [entry.entryKeys mutableCopy];
    [duplicateKeys removeObjectForKey:ILSoupEntryUUID];
    id<ILSoupEntry> duplicate = [ILStockEntry soupEntryFromKeys:duplicateKeys];

    if ([self.delegate respondsToSelector:@selector(soup:createdEntry:)]) { // notify
        [self.delegate soup:self createdEntry:duplicate];
    }

    return duplicate;
}

- (void)deleteEntry:(id<ILSoupEntry>)entry
{
    [self.soupEntryStorage removeObjectForKey:entry.entryHash];

    if ([self.delegate respondsToSelector:@selector(soup:deletedEntry:)]) { // notify
        [self.delegate soup:self deletedEntry:entry];
    }
}

#pragma mark - Aliases

- (NSString*)entryAlias:(id<ILSoupEntry>)entry
{
    return entry.entryHash;
}

- (id<ILSoupEntry>)gotoAlias:(id)alias
{
    return self.soupEntryStorage[alias];
}

#pragma mark - Queries

- (id<ILSoupCursor>)querySoup:(NSPredicate *)query
{
    NSArray* allEntries = self.soupEntryStorage.allValues;
    return [[ILStockCursor alloc] initWithEntries:[allEntries filteredArrayUsingPredicate:query]];
}

#pragma mark - Indicies

- (void) loadIndex:(NSString*) indexPath index:(id<ILSoupIndex>) stockIndex
{
    self.soupIndiciesStorage[indexPath] = stockIndex;
    
    for (id<ILSoupEntry> entry in self.soupEntryStorage.allKeys) {
        [stockIndex indexEntry:entry];
    }

    if ([self.delegate respondsToSelector:@selector(soup:createdIndex:)]) { // notify
        [self.delegate soup:self createdIndex:stockIndex];
    }
}

- (NSArray<id<ILSoupIndex>>*) soupIndicies
{
    return [self.soupIndiciesStorage allValues];
}

- (id<ILSoupIndex>)createIndex:(NSString *)indexPath
{
    ILStockIndex* stockIndex = [ILStockIndex indexWithPath:indexPath];
    [self loadIndex:indexPath index:stockIndex];
    return stockIndex;
}

- (id<ILSoupIndex>)queryIndex:(NSString *)indexPath
{
    return self.soupIndiciesStorage[indexPath];
}

- (id<ILSoupTextIndex>)createTextIndex:(NSString *)indexPath {
    ILStockTextIndex* stockIndex = [ILStockTextIndex indexWithPath:indexPath];
    [self loadIndex:indexPath index:stockIndex];
    return stockIndex;
}

- (id<ILSoupTextIndex>)queryTextIndex:(NSString *)indexPath
{
    return (id<ILSoupTextIndex>)self.soupIndiciesStorage[indexPath];
}

- (id<ILSoupDateIndex>)createDateIndex:(NSString *)indexPath {
    ILStockDateIndex* stockIndex = [ILStockDateIndex indexWithPath:indexPath];
    [self loadIndex:indexPath index:stockIndex];
    return stockIndex;
}

- (id<ILSoupTextIndex>)queryDateIndex:(NSString *)indexPath
{
    return (id<ILSoupTextIndex>)self.soupIndiciesStorage[indexPath];
}

- (id<ILSoupNumberIndex>)createNumberIndex:(NSString *)indexPath {
    ILStockNumberIndex* stockIndex = [ILStockNumberIndex indexWithPath:indexPath];
    [self loadIndex:indexPath index:stockIndex];
    return stockIndex;
}

- (id<ILSoupNumberIndex>)queryNumberIndex:(NSString *)indexPath
{
    return (id<ILSoupNumberIndex>)self.soupIndiciesStorage[indexPath];
}

#pragma mark - Cursor

- (id<ILSoupCursor>)getCursor
{
    return self.soupCursor;
}

- (id<ILSoupCursor>)setupCursor
{
    if (self.soupQuery) {
        self.soupCursor = [self querySoup:self.soupQuery];
    }
    else { // create a cursor with all the items
        self.soupCursor = [[ILStockCursor alloc] initWithEntries:self.soupEntryStorage.allValues];
    }
    
    return self.soupCursor;
}

#pragma mark - Sequences

- (NSArray<id<ILSoupSequence>>*)soupSequences
{
    return self.soupSequencesStorage.allValues;
}

- (id<ILSoupSequence>)createSequence:(NSString *)sequencePath
{
    ILStockSequence* stockSequence = [ILStockSequence sequenceWithPath:sequencePath];
    self.soupSequencesStorage[sequencePath] = stockSequence;

    for (id<ILSoupEntry> entry in self.soupEntryStorage.allKeys) {
        NSDate* date = entry.entryKeys[ILSoupEntryMutationDate]; // try to get the mutation date

        if (!date) { // try for the creation date
            date = entry.entryKeys[ILSoupEntryCreationDate];
        }

        if (!date) { // now's the time
            date = [NSDate new];
        }
        
        [stockSequence sequenceEntry:entry atTime:date];
    }

    return stockSequence;
}

- (id<ILSoupSequence>)querySequence:(NSString *)sequencePath
{
    return self.soupSequencesStorage[sequencePath];
}

#pragma mark - Soup Managment

- (void)fillNewSoup {
    // ??? create some default indexes (UUID, for e.g.)
}

- (void)doneWithSoup:(NSString *)appIdentifier
{
    // ??? delete all the indexes?
}

#pragma mark - NSObject

- (NSString*) description
{
    return [NSString stringWithFormat:@"%@: \"%@\" %@ %@ %lu entries\nindicies:\n%@\nsequences:\n%@",
            self.className, self.soupName, self.soupDescription, self.soupUUID, self.soupEntryStorage.allKeys.count,
            self.soupIndicies, self.soupSequences];
}

@end
