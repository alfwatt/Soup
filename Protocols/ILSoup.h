#ifndef ILSoup_h
#define ILSoup_h

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
/// along with `<ILSoupSequence>` objects to track evolution of those entties
@protocol ILSoup

/// @property the UUID for this soup
@property(nonatomic, readonly) NSUUID* soupUUID;

/// @property name of the soup
@property(nonatomic, retain) NSString* soupName;

/// @property a description of the soups content
@property(nonatomic, retain) NSString* soupDescription;

/// @property the `NSPredicate` for the default cursor
@property(nonatomic, retain) NSPredicate* soupQuery;

/// @property the default entry keys and values for a new `<ILSoupEntry>`
@property(nonatomic, retain) NSDictionary* defaultEntry; // XXX replace with generator block

/// @property the `<ILSoupDelegate>` which is notified when changes are made
@property(nonatomic, assign) NSObject<ILSoupDelegate>* delegate;

// MARK: - Kitchen

/// @returns a new `<ILSoup>` with the provided name
+ (instancetype) makeSoup:(NSString*) soupName;

// MARK: - Designated Initilizer

/// @return a new `<ILSoup>` with the provided name
- (instancetype) initWithName:(NSString*) soupName;

// MARK: - Entries

/// @returns a new blank entry, with the defaults for this soup and a new UUID,
/// NB that the new entry is not yet stored in the soup
- (id<ILMutableSoupEntry>) createBlankEntry;

/// @param comformsToMutableSoupEntry — must conform to the `<ILMutableSoupEntry>` protocol
/// @returns a new blank entry, with the defaults for this soup and a new UUID,
/// NB that the new entry is not yet stored in the soup
- (id<ILMutableSoupEntry>) createBlankEntryOfClass:(Class)comformsToMutableSoupEntry;

/// @param entry — an `<ILSoupEntry>` to add to this soup
/// @returns: the alias used to retrieve the entry
- (NSString*) addEntry:(id<ILSoupEntry>) entry;

/// duplicate entry, providing a mutable entry with a new UUID
/// N.B. that the duplicate entry is not yet stored in the soup
/// @param entry – `<ILSoupEntry>` to be duplicated into a `<ILMutableSoupEntry>`
/// @returns – `<ILMutableSoupEntry>` which is a duplicate of the data in `entry`
- (id<ILMutableSoupEntry>) duplicateEntry:(id<ILSoupEntry>) entry;

/// @param entry - to be deleted from this soup
- (void) deleteEntry:(id<ILSoupEntry>) entry;

// MARK: - Aliases

/// get the soups alias for the individual entry, string is the entryHash of the entry
- (NSString*) entryAlias:(id<ILSoupEntry>) entry;

/// the entry from the soup, based on the alias provided
- (id<ILMutableSoupEntry>) gotoAlias:(NSString*) alias;

// MARK: - Queries

/// a cursor with items specified by the predicate, O(N) time
- (id<ILSoupCursor>) querySoup:(NSPredicate*) query;

// MARK: - Indicies

/// the indexes currently maintained for this soup, ordered by indexPath ascending
@property(nonatomic, readonly) NSArray<id<ILSoupIndex>>* soupIndicies;

/// returns the index for the path provided
- (id<ILSoupIndex>) indexForPath:(NSString*)indexPath;

/// create a new index on this soup with the path provided
- (id<ILSoupIndex>) createIndex:(NSString*)indexPath;

/// returns the index for the path provided
- (id<ILSoupIndex>) queryIndex:(NSString*)indexPath;

// MARK: - Default Indicies

/// returns the entry UUID  identity index for this soup
- (id<ILSoupIdentityIndex>) createEntryIdentityIndex;

/// returns the entry UUID identity index for this soup
- (id<ILSoupIdentityIndex> _Nullable) queryEntryIdentityIndex;

/// returns the ancestory index for this soup
- (id<ILSoupAncestryIndex>) createAncestryIndex;

/// returns
- (id<ILSoupAncestryIndex> _Nullable) queryAncestryIndex;

// MARK: - User Indicies

/// returns an identity index for the indexPath provided
- (id<ILSoupIdentityIndex>) createIdentityIndex:(NSString*)indexPath;

/// returns the entry identity index for this soup
- (id<ILSoupIdentityIndex> _Nullable) queryIdentityIndex:(NSString*)indexPath;

/// create a new index on this soup with the path provided
- (id<ILSoupTextIndex>) createTextIndex:(NSString*)indexPath;

/// returns the index for the path provided
- (id<ILSoupTextIndex> _Nullable) queryTextIndex:(NSString*)indexPath;

/// create a new index on this soup with the path provided
- (id<ILSoupNumberIndex>) createNumberIndex:(NSString*)indexPath;

/// returns the index for the path provided
- (id<ILSoupNumberIndex> _Nullable) queryNumberIndex:(NSString*)indexPath;

/// create a new index on this soup with the path provided
- (id<ILSoupDateIndex>) createDateIndex:(NSString*)indexPath;

/// returns the index for the path provided
- (id<ILSoupDateIndex> _Nullable) queryDateIndex:(NSString*)indexPath;

// MARK: - Default Cursor

/// reset cursor to the zero index, automatically called in when setitng property `soupQuery`
- (id<ILSoupCursor>) resetCursor;

/// the default cursor for this soup
@property(nonatomic, readonly) id<ILSoupCursor> cursor;

// MARK: - Sequences

/// the sequences currently maintained for this soup
@property(nonatomic, readonly) NSArray<id<ILSoupSequence>>* soupSequences;

/// create a sequence for numbers with the provided path
- (id<ILSoupSequence>) createSequence:(NSString*) sequencePath;

/// returns the sequence for the path provided
- (id<ILSoupSequence> _Nullable) querySequence:(NSString*) sequencePath;

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

// MARK: - Indicies & Sequences

/// index was added to the soup
- (void) soup:(id<ILSoup>) deJour createdIndex:(id<ILSoupIndex>) index;

/// index was updated
- (void) soup:(id<ILSoup>) deJour updatedIndex:(id<ILSoupIndex>) index;

/// sequence was added to the soup
- (void) soup:(id<ILSoup>) deJour createdSequence:(id<ILSoupSequence>) sequence;

/// sequence was updated
- (void) soup:(id<ILSoup>) deJour updatedSequence:(id<ILSoupSequence>) sequence;

// MARK: - Lifecycle

/// @param deJour - an `<ILSoup>` which has been initilized and filled with entries
- (void) soupFilled:(id<ILSoup>) deJour;

/// @param deJour — an `<ILSoup>` which as been finalied and all entries are removed
- (void) soupDone:(id<ILSoup>) deJour;

@end

NS_ASSUME_NONNULL_END

#endif

