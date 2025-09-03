#import "ILSynchedSoup.h"

NS_ASSUME_NONNULL_BEGIN

@implementation ILSynchedSoup

+ (nullable instancetype) makeSoup:(NSString*) soupName {
    return nil;
}

+ (instancetype) synchronizedSoup:(id<ILSoup>) synched {
    ILSynchedSoup* soup = [ILSynchedSoup new];
    soup.synchronized = synched;
    return soup;
}

// MARK: - Initilizer

- (instancetype)initWithName:(NSString *)soupName {
    return nil;
}

// MARK: - Properties

- (NSUUID*) soupUUID {
    @synchronized(self.synchronized) {
        return self.synchronized.soupUUID;
    }
}

- (NSString*) soupName {
    @synchronized(self.synchronized) {
        return self.synchronized.soupName;
    }
}

- (void) setSoupName:(NSString*) newName {
    @synchronized(self.synchronized) {
        self.synchronized.soupName = newName;
    }
}

- (NSString*) soupDescription {
    @synchronized(self.synchronized) {
        return self.synchronized.soupDescription;
    }
}

- (void) setSoupDescription:(NSString*) newDescription {
    @synchronized(self.synchronized) {
        self.synchronized.soupDescription = newDescription;
    }
}

- (NSPredicate*) soupQuery {
    @synchronized(self.synchronized) {
        return self.synchronized.soupQuery;
    }
}

- (void) setSoupQuery:(NSPredicate*) newQuery {
    @synchronized(self.synchronized) {
        self.synchronized.soupQuery = newQuery;
    }
}

- (NSDictionary*) defaultEntry {
    @synchronized(self.synchronized) {
        return self.synchronized.defaultEntry;
    }
}

- (void) setDefaultEntry:(NSDictionary*) newDefaults {
    @synchronized(self.synchronized) {
        self.synchronized.defaultEntry = newDefaults;
    }
}

- (NSObject<ILSoupDelegate>*) delegate {
    @synchronized(self.synchronized) {
        return self.synchronized.delegate;
    }
}

- (void) setDelegate:(NSObject<ILSoupDelegate>*) delegate {
    @synchronized(self.synchronized) {
        self.synchronized.delegate = delegate;
    }
}

// MARK: - Entries

- (NSString*) addEntry:(id<ILSoupEntry>) entry; {
    @synchronized(self.synchronized) {
        return [self.synchronized addEntry:entry];
    }
}

- (id<ILMutableSoupEntry>) createBlankEntry; {
    @synchronized(self.synchronized) {
        return [self.synchronized createBlankEntry];
    }
}

- (nullable id<ILMutableSoupEntry>)createBlankEntryOfClass:(Class)comformsToMutableSoupEntry {
    @synchronized(self.synchronized) {
        return [self.synchronized createBlankEntryOfClass:comformsToMutableSoupEntry];
    }
}

- (void) deleteEntry:(id<ILSoupEntry>) entry; {
    @synchronized(self.synchronized) {
        [self.synchronized deleteEntry:entry];
    }
}

- (NSString*) entryAlias:(id<ILSoupEntry>) entry; {
    @synchronized(self.synchronized) {
        return [self.synchronized entryAlias:entry];
    }
}

- (nullable id<ILMutableSoupEntry>) gotoAlias:(NSString*) alias {
    @synchronized(self.synchronized) {
        return [self.synchronized gotoAlias:alias];
    }
}

// MARK: - Indicies

- (NSArray<id<ILSoupIndex>>*) soupIndices {
    @synchronized(self.synchronized) {
        return self.synchronized.soupIndices;
    }
}

- (id<ILSoupIndex>)indexForPath:(NSString*)indexPath {
    @synchronized (self.synchronized) {
        return [self.synchronized indexForPath:indexPath];
    }
}

- (id<ILSoupIndex>) createIndex:(NSString*)indexPath; {
    @synchronized(self.synchronized) {
        return [self.synchronized createIndex:indexPath];
    }
}

- (nullable id<ILSoupIndex>) queryIndex:(NSString *)indexPath {
    @synchronized(self.synchronized) {
        return [self.synchronized queryIndex:indexPath];
    }
}

// MARK: - Default Indicies

- (id<ILSoupIdentityIndex>) createEntryIdentityIndex; {
    @synchronized(self.synchronized) {
        return [self.synchronized createEntryIdentityIndex];
    }
}

- (nullable id<ILSoupEntry>) queryEntryIdentityIndex:(NSString*) entryIdentityUUID {
    @synchronized(self.synchronized) {
        return [self.synchronized queryEntryIdentityIndex:entryIdentityUUID];
    }
}

- (id<ILSoupAncestryIndex>)createAncestryIndex {
    @synchronized (self.synchronized) {
        return [self.synchronized createAncestryIndex];
    }
}


- (nullable id<ILSoupAncestryIndex>)queryAncestryIndex {
    @synchronized (self.synchronized) {
        return [self.synchronized queryAncestryIndex];
    }
}

// MARK: - User Indicies

- (id<ILSoupIdentityIndex>) createIdentityIndex:(NSString *)indexPath {
    @synchronized(self.synchronized) {
        return [self.synchronized createIdentityIndex:indexPath];
    }
}

- (nullable id<ILSoupIdentityIndex>) queryIdentityIndex:(NSString *)indexPath {
    @synchronized(self.synchronized) {
        return [self.synchronized queryIdentityIndex:indexPath];
    }
}

- (id<ILSoupTextIndex>) createTextIndex:(NSString *)indexPath {
    @synchronized(self.synchronized) {
        return [self.synchronized createTextIndex:indexPath];
    }
}

- (nullable id<ILSoupTextIndex>) queryTextIndex:(NSString *)indexPath {
    @synchronized(self.synchronized) {
        return [self.synchronized queryTextIndex:indexPath];
    }
}

- (id<ILSoupDateIndex>) createDateIndex:(NSString *)indexPath {
    @synchronized(self.synchronized) {
        return [self.synchronized createDateIndex:indexPath];
    }
}

- (nullable id<ILSoupDateIndex>) queryDateIndex:(NSString *)indexPath {
    @synchronized(self.synchronized) {
        return [self.synchronized queryDateIndex:indexPath];
    }
}

- (id<ILSoupNumberIndex>) createNumberIndex:(NSString *)indexPath {
    @synchronized(self.synchronized) {
        return [self.synchronized createNumberIndex:indexPath];
    }
}

- (nullable id<ILSoupNumberIndex>) queryNumberIndex:(NSString *)indexPath {
    @synchronized(self.synchronized) {
        return [self.synchronized queryNumberIndex:indexPath];
    }
}

// MARK: - Default Cursor

- (id<ILSoupCursor>) resetCursor {
    @synchronized(self.synchronized) {
        return [self.synchronized resetCursor];
    }
}

- (id<ILSoupCursor>) cursor {
    @synchronized(self.synchronized) {
        return [self.synchronized cursor];
    }
}

- (id<ILSoupCursor>) querySoup:(NSPredicate*) query {
    @synchronized(self.synchronized) {
        return [self.synchronized querySoup:query];
    }
}

// MARK: - Sequences

- (NSArray<id<ILSoupSequence>>*) soupSequences {
    @synchronized(self.synchronized) {
        return self.synchronized.soupSequences;
    }
}

- (id<ILSoupSequence>) createSequence:(NSString*) sequencePath {
    @synchronized(self.synchronized) {
        return [self.synchronized createSequence:sequencePath];
    }
}

- (nullable id<ILSoupSequence>) querySequence:(NSString *)sequencePath {
    @synchronized(self.synchronized) {
        return [self.synchronized querySequence:sequencePath];
    }
}

// MARK: - Soup Managment

- (void) doneWithSoup:(NSString*) appIdentifier {
    @synchronized(self.synchronized) {
        [self.synchronized doneWithSoup:appIdentifier];
    }
}

- (void) fillNewSoup {
    @synchronized(self.synchronized) {
        [self.synchronized fillNewSoup];
    }
}

- (nonnull id<ILSoupIndex>)createValueIndex:(nonnull NSString *)indexPath {
    @synchronized(self.synchronized) {
        return [self.synchronized createValueIndex:indexPath];
    }
}

- (nullable id<ILSoupIndex>)queryValueIndex:(nonnull NSString *)indexPath {
    @synchronized(self.synchronized) {
        return [self.synchronized queryValueIndex:indexPath];
    }
}


@end

NS_ASSUME_NONNULL_END
