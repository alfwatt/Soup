#import "ILQueuedSoup.h"
#import "ILSoupEntry.h"

@implementation ILQueuedSoup

+ (instancetype) makeSoup:(NSString*) soupName
{
    return nil;
}

+ (instancetype) queuedSoup:(id<ILSoup>) queuedSoup
{
    return [ILQueuedSoup queuedSoup:queuedSoup soupQueue:nil];
}

+ (instancetype) queuedSoup:(id<ILSoup>) queuedSoup soupQueue:(NSOperationQueue*) soupOps
{
    ILQueuedSoup* soup = ILQueuedSoup.new;
    soup.queued = queuedSoup;
    soup.soupOperations = soupOps;

    if (soup.soupOperations) {
        soup.soupOperations = NSOperationQueue.new;
        soup.soupOperations.maxConcurrentOperationCount = 1;
    }

    return soup;
}

// MARK: - Initilizers

- (instancetype)initWithName:(NSString *)soupName {
    return nil;
}

// MARK: - Properties

- (NSUUID*) soupUUID
{
    return self.queued.soupUUID;
}

- (NSString*) soupName
{
    return self.queued.soupName;
}

- (void) setSoupName:(NSString*) newName
{
    self.queued.soupName = newName;
}

- (NSString*) soupDescription
{
    return self.queued.soupDescription;
}

- (void) setSoupDescription:(NSString*) newDescription
{
    self.queued.soupDescription = newDescription;
}

- (NSPredicate*) soupQuery
{
    return self.queued.soupQuery;
}

- (void) setSoupQuery:(NSPredicate*) newQuery
{
    self.queued.soupQuery = newQuery;
}

- (NSDictionary*) defaultEntry
{
    return self.queued.defaultEntry;
}

- (void) setDefaultEntry:(NSDictionary*) newDefaults
{
    self.queued.defaultEntry = newDefaults;
}

- (NSObject<ILSoupDelegate>*) delegate
{
    return self.queued.delegate;
}

- (void) setDelegate:(NSObject<ILSoupDelegate>*) delegate
{
    self.queued.delegate = delegate;
}

// MARK: - Entries

- (NSString*) addEntry:(id<ILSoupEntry>) entry;
{
    NSString* entryHash = entry.entryHash;
    [self.soupOperations addOperationWithBlock:^{
        [self.queued addEntry:entry];
    }];
    return entryHash;
}

- (id<ILMutableSoupEntry>) createBlankEntry;
{
    return [self.queued createBlankEntry];
}

- (id<ILMutableSoupEntry>)createBlankEntryOfClass:(Class)comformsToMutableSoupEntry {
    return [self.queued createBlankEntryOfClass:comformsToMutableSoupEntry];
}

- (void) deleteEntry:(id<ILSoupEntry>) entry;
{
    [self.soupOperations addOperationWithBlock:^{
        [self.queued deleteEntry:entry];
    }];
}

- (id<ILMutableSoupEntry>) duplicateEntry:(id<ILSoupEntry>) entry;
{
    return [self.queued duplicateEntry:entry];
}

- (NSString*) entryAlias:(id<ILSoupEntry>) entry;
{
    return [self.queued entryAlias:entry];
}

- (id<ILSoupEntry>) gotoAlias:(NSString*) alias
{
    return [self.queued gotoAlias:alias];
}

// MARK: - Indicies

- (id<ILSoupIndex>)indexForPath:(NSString *)indexPath {
    return [self.queued indexForPath:indexPath];
}

- (NSArray<id<ILSoupIndex>>*) soupIndicies
{
    return self.queued.soupIndicies;
}

- (id<ILSoupIndex>) createIndex:(NSString*) indexPath;
{
    return [self.queued createIndex:indexPath];
}

- (id<ILSoupIndex>) queryIndex:(NSString*) indexPath {
    return [self.queued queryIndex:indexPath];
}

// MARK: - Default Indicies

- (id<ILSoupIdentityIndex>)createEntryIdentityIndex {
    return [self.queued createEntryIdentityIndex];
}

- (id<ILSoupIdentityIndex>) queryEntryIdentityIndex {
    return [self.queued queryEntryIdentityIndex];
}

- (id<ILSoupAncestryIndex>)createAncestryIndex {
    return [self.queued createAncestryIndex];
}

- (id<ILSoupAncestryIndex>)queryAncestryIndex {
    return [self.queued queryAncestryIndex];
}

// MARK: - User Indicies

- (id<ILSoupTextIndex>) createTextIndex:(NSString*) indexPath {
    return [self.queued createTextIndex:indexPath];
}

- (id<ILSoupTextIndex>) queryTextIndex:(NSString*) indexPath {
    return [self.queued queryTextIndex:indexPath];
}

- (id<ILSoupIdentityIndex>) createIdentityIndex:(NSString*)indexPath {
    return [self.queued createIdentityIndex:indexPath];
}

- (id<ILSoupIdentityIndex>) queryIdentityIndex:(NSString*) indexPath {
    return [self.queued queryIdentityIndex:indexPath];
}

- (id<ILSoupDateIndex>) createDateIndex:(NSString*) indexPath {
    return [self.queued createDateIndex:indexPath];
}

- (id<ILSoupDateIndex>) queryDateIndex:(NSString*) indexPath {
    return [self.queued queryDateIndex:indexPath];
}

- (id<ILSoupNumberIndex>) createNumberIndex:(NSString*) indexPath {
    return [self.queued createNumberIndex:indexPath];
}

- (id<ILSoupNumberIndex>) queryNumberIndex:(NSString*) indexPath {
    return [self.queued queryNumberIndex:indexPath];
}

// MARK: - Default Cursor

- (id<ILSoupCursor>) resetCursor
{
    return [self.queued resetCursor];
}

- (id<ILSoupCursor>) cursor
{
    return self.queued.cursor;
}

- (id<ILSoupCursor>) querySoup:(NSPredicate*) query
{
    return [self.queued querySoup:query];
}

// MARK: - Sequences

- (NSArray<id<ILSoupSequence>>*) soupSequences
{
    return self.queued.soupSequences;
}

- (id<ILSoupSequence>) createSequence:(NSString*) sequencePath
{
    return [self.queued createSequence:sequencePath];
}

- (id<ILSoupSequence>) querySequence:(NSString*) sequencePath {
    return [self.queued querySequence:sequencePath];
}

// MARK: - Soup Managment

- (void) doneWithSoup:(NSString*) appIdentifier
{
    [self.queued doneWithSoup:appIdentifier];
}

- (void) fillNewSoup
{
    [self.queued fillNewSoup];
}

@end
