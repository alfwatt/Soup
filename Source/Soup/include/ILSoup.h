#ifndef ILSoup_h
#define ILSoup_h
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

// MARK: -

@protocol ILSoupEntry;
@protocol ILMutableSoupEntry;
@protocol ILSoupIndex;
@protocol ILSoupIdentityIndex;
@protocol ILSoupAncestryIndex;
@protocol ILSoupTextIndex;
@protocol ILSoupNumberIndex;
@protocol ILSoupDateIndex;
@protocol ILSoupCursor;
@protocol ILSoupSequence;
@protocol ILSoupDelegate;

/// @protocol a Soup contains a collection of `<ILSoupEntries>`,
/// and maintains `<ILSoupIndex>` objects to allow for access to those entries,
/// along with `<ILSoupSequence>` objects to track evolution of those entries
@protocol ILSoup

/// @property the UUID for this soup
@property(nonatomic, readonly) NSUUID* soupUUID;

/// @property name of the soup
@property(nonatomic, retain) NSString* soupName;

/// @property a description of the soups content
@property(nonatomic, retain) NSString* soupDescription;

/// @property the `NSPredicate` for the default cursor
@property(nonatomic, retain) NSPredicate* soupQuery;

/// the default cursor for this soup, filtered by the `soupQuery` predicate
@property(nonatomic, readonly) id<ILSoupCursor> cursor;

/// @property the default entry keys and values for a new `<ILSoupEntry>`
@property(nonatomic, retain) NSDictionary* defaultEntry; // XXX replace with generator block or copy property

/// @property the `<ILSoupDelegate>` which is notified when changes are made
@property(nonatomic, assign) NSObject<ILSoupDelegate>* delegate;

// MARK: - Kitchen

/// @returns a new `<ILSoup>` with the provided name
+ (nullable instancetype) makeSoup:(NSString*) soupName;

// MARK: - Designated Initializer

/// @return a new `<ILSoup>` with the provided name
- (instancetype) initWithName:(NSString*) soupName;

// MARK: - Entries

/// @returns a new blank entry, with the defaults for this soup and a new UUID,
/// NB that the new entry is not yet stored in the soup
- (id<ILMutableSoupEntry>) createBlankEntry;

/// @param conformsToMutableSoupEntry — must conform to the `<ILMutableSoupEntry>` protocol
/// @returns a new blank entry, with the defaults for this soup and a new UUID,
/// NB that the new entry is not yet stored in the soup
/// null if the class provided does not confirm to <ILMutableSoupEntry> or fails to initilize
- (nullable id<ILMutableSoupEntry>) createBlankEntryOfClass:(Class)conformsToMutableSoupEntry;

/// @param entry — an `<ILSoupEntry>` to add to this soup
/// @returns: the alias used to retrieve the entry
- (NSString*) addEntry:(id<ILSoupEntry>) entry;

/// @param entry - to be deleted from this soup
- (void) deleteEntry:(id<ILSoupEntry>) entry;

// MARK: - Aliases

/// get the soups alias for the individual entry, string is the entryHash of the entry
- (NSString*) entryAlias:(id<ILSoupEntry>) entry;

/// the entry from the soup, based on the alias provided
- (nullable id<ILMutableSoupEntry>) gotoAlias:(NSString*) alias;

// MARK: - Queries

/// a cursor with items specified by the predicate, O(N) time
- (id<ILSoupCursor>) querySoup:(NSPredicate*) query;

// MARK: - Default Cursor

/// reset cursor to the zero index, automatically called when setting property `soupQuery`
- (id<ILSoupCursor>) resetCursor;

// MARK: - Indices

/// the indexes currently maintained for this soup, ordered by indexPath ascending
@property(nonatomic, readonly) NSArray<id<ILSoupIndex>>* soupIndices;

/// returns the index for the path provided
- (id<ILSoupIndex>) indexForPath:(NSString*)indexPath;

/// create a new index on this soup with the path provided
- (id<ILSoupIndex>) createIndex:(NSString*)indexPath;

/// returns the index for the path provided
/// null if the index has not been created
- (nullable id<ILSoupIndex>) queryIndex:(NSString*)indexPath;

// MARK: - Default Indices

/// returns the entry UUID  identity index for this soup
- (id<ILSoupIdentityIndex>) createEntryIdentityIndex;

/// @param entryIdentityUUID the ILSoupEntryIdentityUUID we are looking up
/// @returns the entry UUID identity index for this soup
/// null if the entryIdentityUUID is not found
- (nullable id<ILSoupEntry>) queryEntryIdentityIndex:(NSString*) entryIdentityUUID;

/// returns the ancestry index for this soup
- (id<ILSoupAncestryIndex>) createAncestryIndex;

/// returns
- (nullable id<ILSoupAncestryIndex>) queryAncestryIndex;

// MARK: - User Indices

/// returns an identity index for the indexPath provided
- (id<ILSoupIdentityIndex>) createIdentityIndex:(NSString*)indexPath;

/// returns the entry identity index for this soup
/// null if the indexPath provided has not been created
- (nullable id<ILSoupIdentityIndex>) queryIdentityIndex:(NSString*)indexPath;

/// create a new index on this soup with the path provided
- (id<ILSoupTextIndex>) createTextIndex:(NSString*)indexPath;

/// returns the index for the path provided
/// null if the indexPath provided has not been created
- (nullable id<ILSoupTextIndex>) queryTextIndex:(NSString*)indexPath;

/// create a new index on this soup with the path provided
- (id<ILSoupNumberIndex>) createNumberIndex:(NSString*)indexPath;

/// returns the index for the path provided
/// null if the indexPath provided has not been created
- (nullable id<ILSoupNumberIndex>) queryNumberIndex:(NSString*)indexPath;

/// create a new index on this soup with the path provided
- (id<ILSoupDateIndex>) createDateIndex:(NSString*)indexPath;

/// returns the index for the path provided
/// null if the indexPath provided has not been created
- (nullable id<ILSoupDateIndex>) queryDateIndex:(NSString*)indexPath;

// MARK: - Sequences

/// the sequences currently maintained for this soup
@property(nonatomic, readonly) NSArray<id<ILSoupSequence>>* soupSequences;

/// create a sequence for numbers with the provided path
- (id<ILSoupSequence>) createSequence:(NSString*) sequencePath;

/// returns the sequence for the path provided
/// null if the sequencePath provided has not been created
- (nullable id<ILSoupSequence>) querySequence:(NSString*) sequencePath;

// MARK: - Soup Managment

/// if you need to do setup, now is the time
- (void) fillNewSoup;

/// we're done here
- (void) doneWithSoup:(NSString*) appIdentifier;

@end

// MARK: -

/// delegate protocol for <ILSoup> <a id="ILSoupDelegate"></a>
@protocol ILSoupDelegate
@optional

/// entry was created from the soup defaults
- (void) soup:(id<ILSoup>) deJour createdEntry:(id<ILSoupEntry>) entry;

/// entry was added to the soup
- (void) soup:(id<ILSoup>) deJour addedEntry:(id<ILSoupEntry>) entry;

/// entry was deleted from the soup
- (void) soup:(id<ILSoup>) deJour deletedEntry:(id<ILSoupEntry>) entry;

// MARK: - Indices & Sequences

/// index was added to the soup
- (void) soup:(id<ILSoup>) deJour createdIndex:(id<ILSoupIndex>) index;

/// index was updated
- (void) soup:(id<ILSoup>) deJour updatedIndex:(id<ILSoupIndex>) index;

/// sequence was added to the soup
- (void) soup:(id<ILSoup>) deJour createdSequence:(id<ILSoupSequence>) sequence;

/// sequence was updated
- (void) soup:(id<ILSoup>) deJour updatedSequence:(id<ILSoupSequence>) sequence;

// MARK: - Lifecycle

/// @param deJour - an `<ILSoup>` which has been initialized and filled with entries
- (void) soupFilled:(id<ILSoup>) deJour;

/// @param deJour — an `<ILSoup>` which as been finalized and all entries are removed
- (void) soupDone:(id<ILSoup>) deJour;

@end

NS_ASSUME_NONNULL_END
#endif

