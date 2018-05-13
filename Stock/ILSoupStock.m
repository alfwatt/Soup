#import "ILSoupStock.h"
#import "ILSoupStockEntry.h"
#import "ILSoupStockIndex.h"
#import "ILSoupStockSequence.h"

@interface ILSoupStock ()
@property(nonatomic, retain) NSString* soupUUIDStorage;
@property(nonatomic, retain) NSMutableDictionary<NSString*,id<ILSoupEntry>>* soupEntryStorage;
@property(nonatomic, retain) NSMutableArray<id<ILSoupIndex>>* soupIndiciesStorage;
@property(nonatomic, retain) NSMutableArray<id<ILSoupSequence>>* soupSequencesStorage;

- (instancetype) initWithSoupName:(NSString*) soupName;

@end

#pragma mark -

@implementation ILSoupStock
@synthesize defaultEntry;
@synthesize soupDescription;
@synthesize soupName;
@synthesize soupQuery;
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
        self.soupIndiciesStorage = [NSMutableArray new];
        self.soupSequencesStorage = [NSMutableArray new];
    }
    return self;
}

- (NSArray<id<ILSoupIndex>>*) soupIndicies
{
    return self.soupIndiciesStorage;
}

- (NSString*) soupUUID
{
    return self.soupUUIDStorage;
}

#pragma mark - Entries

- (void)addEntry:(id<ILSoupEntry>)entry
{
    self.soupEntryStorage[entry.entryHash] = entry;
    NSDate* date = entry.entryKeys[ILMutableSoupEntryMutationDate]; // try to get the mutation date

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
}

- (id<ILSoupEntry>)createBlankEntry
{
    return [ILSoupStockEntry soupEntryFromKeys:self.defaultEntry];
}

- (void)deleteEntry:(id<ILSoupEntry>)entry
{
    [self.soupEntryStorage removeObjectForKey:entry.entryHash];
}

- (id<ILSoupEntry>)duplicateEntry:(id<ILSoupEntry>)entry
{
    NSMutableDictionary* duplicateKeys = [entry.entryKeys mutableCopy];
    [duplicateKeys removeObjectForKey:ILSoupEntryUUID];
    return [ILSoupStockEntry soupEntryFromKeys:duplicateKeys];
}

#pragma mark - Indicies

- (id<ILSoupIndex>)createIndex:(NSString *)indexPath
{
    ILSoupStockIndex* stockIndex = [ILSoupStockIndex indexWithPath:indexPath];
    [self.soupIndiciesStorage addObject:stockIndex];
    return stockIndex;
}

- (void)doneWithSoup:(NSString *)appIdentifier
{
}

- (void)fillNewSoup {
}

- (id)getAlias:(id<ILSoupEntry>)entry
{
    return entry.entryHash;
}

- (id<ILSoupCursor>)getCursor
{
    return nil;
}

- (id)getCursorPosition
{
    return nil;
}

- (id<ILSoupEntry>)gotoAlias:(id)alias
{
    return nil;
}

- (id<ILSoupCursor>)quey:(NSPredicate *)query
{
    return nil;
}

- (void)setupCursor
{
}

- (id<ILSoupSequence>)createSequence:(NSString *)sequencePath
{
    ILSoupStockSequence* stockSequence = [ILSoupStockSequence sequenceWithPath:sequencePath];
    [self.soupSequencesStorage addObject:stockSequence];
    return stockSequence;
}

- (NSArray<id<ILSoupSequence>>*)soupSequences
{
    return self.soupSequencesStorage;
}

#pragma mark - NSObject

- (NSString*) description
{
    return [NSString stringWithFormat:@"%@: \"%@\" %@ %@ %lu entries\nindicies:\n%@\nsequences:\n%@",
            self.className, self.soupName, self.soupDescription, self.soupUUID, self.soupEntryStorage.allKeys.count,
            self.soupIndicies, self.soupSequences];
}

@end
