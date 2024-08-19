#import "ILSoupStock.h"
#import "ILStockEntry.h"
#import "ILStockIndex.h"
#import "ILStockSequence.h"

NS_ASSUME_NONNULL_BEGIN

@interface ILSoupStock ()
@property(nonatomic, retain) NSString* soupUUIDStorage;
@property(nonatomic, retain) NSMutableDictionary<NSString*, id<ILMutableSoupEntry>>* soupEntryStorage;
@property(nonatomic, retain) NSMutableDictionary<NSString*, id<ILSoupIndex>>* soupIndiciesStorage;
@property(nonatomic, retain) NSMutableDictionary<NSString*, id<ILSoupSequence>>* soupSequencesStorage;
@property(nonatomic, retain) NSPredicate* soupQueryStorage;
@property(nonatomic, retain) id<ILSoupCursor> soupCursorStorage;

@end

// MARK: -

@implementation ILSoupStock
@synthesize soupName;
@synthesize soupDescription;
@synthesize defaultEntry;
@synthesize delegate;

// MARK: -

+ (nullable id<ILSoup>)makeSoup:(NSString*)soupName {
    return [self.alloc initWithName:soupName];
}

// MARK: -

- (instancetype) init {
    if ((self = super.init)) {
        self.soupUUIDStorage = NSUUID.UUID.UUIDString;
        self.soupEntryStorage = NSMutableDictionary.new;
        self.soupIndiciesStorage = NSMutableDictionary.new;
        self.soupSequencesStorage = NSMutableDictionary.new;
    }
    
    return self;
}

- (instancetype) initWithName:(NSString*) soupName {
    if ((self = self.init)) {
        self.soupName = soupName;
    }
    
    return self;
}

// MARK: - Properties

- (NSString*) soupUUID {
    return self.soupUUIDStorage;
}

- (NSPredicate*) soupQuery {
    return self.soupQueryStorage;
}

- (void) setSoupQuery:(NSPredicate *)soupQuery {
    self.soupQueryStorage = soupQuery;
    [self resetCursor];
}

// MARK: - Entries

- (nullable id<ILMutableSoupEntry>) createBlankEntry {
    return [self createBlankEntryOfClass:ILStockEntry.class];
}

- (nullable id<ILMutableSoupEntry>) createBlankEntryOfClass:(Class)comformsToMutableSoupEntry {
    id<ILMutableSoupEntry> entry = nil;
    
    if ([comformsToMutableSoupEntry conformsToProtocol:@protocol(ILMutableSoupEntry)]) {
        entry = [(id<ILMutableSoupEntry>)comformsToMutableSoupEntry soupEntryWithKeys:self.defaultEntry];
    }

    if (entry && [self.delegate respondsToSelector:@selector(soup:createdEntry:)]) { // notify
        [self.delegate soup:self createdEntry:entry];
    }

    return entry;
}

- (NSString*) addEntry:(id<ILSoupEntry>) entry {
    [self.soupEntryStorage setObject:(id<ILMutableSoupEntry>)entry forKey:entry.entryHash]; // TODO resolve the mutable/immutable

    [self indexEntry:entry];
    [self sequenceEntry:entry];
    
    if ([self.delegate respondsToSelector:@selector(soup:addedEntry:)]) { // notify
        [self.delegate soup:self addedEntry:entry];
    }
    
    return [self entryAlias:entry];
}

- (id<ILSoupEntry>) duplicateEntry:(id<ILSoupEntry>) entry {
    NSMutableDictionary* duplicateKeys = entry.entryKeys.mutableCopy;
    [duplicateKeys removeObjectForKey:ILSoupEntryIdentityUUID];
    id<ILSoupEntry> duplicate = [ILStockEntry soupEntryWithKeys:duplicateKeys];

    if ([self.delegate respondsToSelector:@selector(soup:createdEntry:)]) { // notify
        [self.delegate soup:self createdEntry:duplicate];
    }

    return duplicate;
}

- (void) deleteEntry:(id<ILSoupEntry>) entry {
    [self.soupEntryStorage removeObjectForKey:entry.entryHash];

    if ([self.delegate respondsToSelector:@selector(soup:deletedEntry:)]) { // notify
        [self.delegate soup:self deletedEntry:entry];
    }
    
    [self removeFromIndicies:entry];
}

- (void) indexEntry:(id<ILSoupEntry>) entry {
    for (id<ILSoupIndex> index in self.soupIndicies) { // add item to the indexes
        [index indexEntry:entry];
        
        if ([self.delegate respondsToSelector:@selector(soup:updatedIndex:)]) {
            [self.delegate soup:self updatedIndex:index];
        }
    }
}

- (void) removeFromIndicies:(id<ILSoupEntry>) entry {
    for (id<ILSoupIndex> index in self.soupIndicies) {
        [index removeEntry:entry];

        if ([self.delegate respondsToSelector:@selector(soup:updatedIndex:)]) {
            [self.delegate soup:self updatedIndex:index];
        }
    }
}

- (void) sequenceEntry:(id<ILSoupEntry>) entry {
    NSDate* date = entry.entryKeys[ILSoupEntryMutationDate]; // try to get the mutation date

    if (!date) { // try for the creation date
        date = entry.entryKeys[ILSoupEntryCreationDate];
    }

    if (!date) { // now's the time
        date = NSDate.date;
    }
    
    for (id<ILSoupSequence> sequence in self.soupSequences) { // add item to the sequences
        [sequence sequenceEntry:entry atTime:date];

        if ([self.delegate respondsToSelector:@selector(soup:updatedSequence:)]) {
            [self.delegate soup:self updatedSequence:sequence];
        }
    }
}

- (void) removeFromSequences:(id<ILSoupEntry>) entry {
    for (id<ILSoupSequence> sequence in self.soupSequences) { // add item to the sequences
        [sequence removeEntry:entry];

        if ([self.delegate respondsToSelector:@selector(soup:updatedSequence:)]) {
            [self.delegate soup:self updatedSequence:sequence];
        }
    }
}

// MARK: - Aliases

- (NSString*) entryAlias:(id<ILSoupEntry>)entry {
    return entry.entryHash;
}

- (nullable id<ILMutableSoupEntry>) gotoAlias:(id)alias {
    return (id<ILMutableSoupEntry>) self.soupEntryStorage[alias]; // nothing better to do here until the mutabiliyt interface is resolved
}

// MARK: - Queries

- (id<ILSoupCursor>) querySoup:(NSPredicate *)query {
    NSArray* allEntries = self.soupEntryStorage.allValues;
    return [ILStockCursor.alloc initWithEntries:[allEntries filteredArrayUsingPredicate:query]];
}

// MARK: - Indicies

- (NSArray<id<ILSoupIndex>>*) soupIndicies {
    return [[self.soupIndiciesStorage allValues] sortedArrayUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"indexPath" ascending:YES]]];
}

- (void) loadIndex:(NSString*) indexPath index:(id<ILSoupIndex>) stockIndex {
    self.soupIndiciesStorage[indexPath] = stockIndex;
    
    for (id<ILSoupEntry> entry in self.soupEntryStorage.allKeys) {
        [stockIndex indexEntry:entry];
    }

    if ([self.delegate respondsToSelector:@selector(soup:createdIndex:)]) { // notify
        [self.delegate soup:self createdIndex:stockIndex];
    }
}

- (id<ILSoupIndex>) indexForPath:(NSString*)indexPath {
    return self.soupIndiciesStorage[indexPath];
}


- (id<ILSoupIndex>) createIndex:(NSString *)indexPath {
    ILStockIndex* stockIndex = [ILStockIndex indexWithPath:indexPath inSoup:self];
    [self loadIndex:indexPath index:stockIndex];
    return stockIndex;
}

- (id<ILSoupIndex>) queryIndex:(NSString *)indexPath {
    return self.soupIndiciesStorage[indexPath];
}

// MARK: - Default Indicies

- (id<ILSoupIdentityIndex>) createEntryIdentityIndex {
    ILStockIdentityIndex* stockIndex = [ILStockIdentityIndex indexWithPath:ILSoupEntryIdentityUUID inSoup:self];
    [self loadIndex:ILSoupEntryIdentityUUID index:stockIndex];
    return stockIndex;
}

- (id<ILSoupIdentityIndex> _Nullable) queryEntryIdentityIndex {
    return (id<ILSoupIdentityIndex>) self.soupIndiciesStorage[ILSoupEntryIdentityUUID];
}

- (id<ILSoupAncestryIndex>) createAncestryIndex {
    ILStockAncestryIndex* stockIndex = [ILStockAncestryIndex indexWithPath:ILSoupEntryAncestorEntryHash inSoup:self];
    [self loadIndex:ILSoupEntryAncestorEntryHash index:stockIndex];
    return stockIndex;
}

- (id<ILSoupAncestryIndex> _Nullable) queryAncestryIndex {
    return (id<ILSoupAncestryIndex>) self.soupIndiciesStorage[ILSoupEntryAncestorEntryHash];
}

// MARK: - User Indicies

- (id<ILSoupIdentityIndex>) createIdentityIndex:(NSString *)indexPath {
    ILStockIdentityIndex* stockIndex = [ILStockIdentityIndex indexWithPath:indexPath inSoup:self];
    [self loadIndex:indexPath index:stockIndex];
    return stockIndex;
}

- (id<ILSoupIdentityIndex> _Nullable) queryIdentityIndex:(NSString *)indexPath {
    return (id<ILSoupIdentityIndex>) self.soupIndiciesStorage[indexPath];
}

- (id<ILSoupTextIndex>) createTextIndex:(NSString *)indexPath {
    ILStockTextIndex* stockIndex = [ILStockTextIndex indexWithPath:indexPath inSoup:self];
    [self loadIndex:indexPath index:stockIndex];
    return stockIndex;
}

- (id<ILSoupTextIndex> _Nullable) queryTextIndex:(NSString *)indexPath {
    return (id<ILSoupTextIndex>) self.soupIndiciesStorage[indexPath];
}

- (id<ILSoupDateIndex>) createDateIndex:(NSString *)indexPath {
    ILStockDateIndex* stockIndex = [ILStockDateIndex indexWithPath:indexPath inSoup:self];
    [self loadIndex:indexPath index:stockIndex];
    return stockIndex;
}

- (id<ILSoupTextIndex> _Nullable) queryDateIndex:(NSString *)indexPath {
    return (id<ILSoupTextIndex>) self.soupIndiciesStorage[indexPath];
}

- (id<ILSoupNumberIndex>) createNumberIndex:(NSString *)indexPath {
    ILStockNumberIndex* stockIndex = [ILStockNumberIndex indexWithPath:indexPath inSoup:self];
    [self loadIndex:indexPath index:stockIndex];
    return stockIndex;
}

- (id<ILSoupNumberIndex> _Nullable) queryNumberIndex:(NSString *)indexPath {
    return (id<ILSoupNumberIndex>) self.soupIndiciesStorage[indexPath];
}

// MARK: - Cursor

- (id<ILSoupCursor>) resetCursor {
    if (self.soupQuery) {
        self.soupCursorStorage = [self querySoup:self.soupQuery];
    }
    else { // create a cursor with all the items
        self.soupCursorStorage = [ILStockCursor.alloc initWithEntries:self.soupEntryStorage.allValues];
    }
    
    return self.soupCursorStorage;
}

- (id<ILSoupCursor>) cursor {
    if (!self.soupCursorStorage) {
        [self resetCursor];
    }
    
    return self.soupCursorStorage;
}

// MARK: - Sequences

- (NSArray<id<ILSoupSequence>>*) soupSequences {
    return self.soupSequencesStorage.allValues;
}

- (id<ILSoupSequence>) createSequence:(NSString*) sequencePath {
    ILStockSequence* stockSequence = [ILStockSequence sequenceWithPath:sequencePath];
    self.soupSequencesStorage[sequencePath] = stockSequence;

    for (id<ILSoupEntry> entry in self.soupEntryStorage.allKeys) {
        [self sequenceEntry:entry];
    }

    return stockSequence;
}

- (id<ILSoupSequence> _Nullable) querySequence:(NSString*) sequencePath {
    return self.soupSequencesStorage[sequencePath];
}

// MARK: - Soup Managment

- (void) fillNewSoup {
    // ??? create some default indexes (UUID, for e.g.)
}

- (void) doneWithSoup:(NSString*) appIdentifier {
    // ??? delete all the indexes?
}

// MARK: - NSObject

- (NSString*) description {
    return [NSString stringWithFormat:@"%@: \"%@\" %@ %@ %lu entries\nindicies:\n%@\nsequences:\n%@",
            self.class, self.soupName, self.soupDescription, self.soupUUID, self.soupEntryStorage.allKeys.count,
            self.soupIndicies, self.soupSequences];
}

@end

NS_ASSUME_NONNULL_END
