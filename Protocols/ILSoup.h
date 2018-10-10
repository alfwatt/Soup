#ifndef ILSoup_h
#define ILSoup_h

#pragma mark -

@protocol ILSoupEntry;
@protocol ILMutableSoupEntry;
@protocol ILSoupIndex;
@protocol ILSoupTextIndex;
@protocol ILSoupNumberIndex;
@protocol ILSoupDateIndex;
@protocol ILSoupCursor;
@protocol ILSoupDelegate;
@protocol ILSoupSequence;

#pragma mark -

/* @brief defines the requried methods for a soup */
@protocol ILSoup

/* @brief UUID for this soup */
@property(nonatomic, readonly) NSUUID* soupUUID;

/* @brief name of the soup */
@property(nonatomic, retain) NSString* soupName;

/* @brief description of the soups content */
@property(nonatomic, retain) NSString* soupDescription;

/* @biref query string for the default cursor */
@property(nonatomic, retain) NSPredicate* soupQuery;

/* @brief default entry keys and values */
@property(nonatomic, retain) NSDictionary* defaultEntry; // XXX replace with generator block

/* @brief the <ILSoupDelegate> whis is notified when changes are made */
@property(nonatomic, assign) NSObject<ILSoupDelegate>* delegate;

#pragma mark -

/* @brief create a new soup with the provided name */
+ (instancetype) makeSoup:(NSString*) soupName;

#pragma mark - Entries

/*  @brief create a new blank entry, with the defaults for this soup and a new UUID,
    NB that the new entry is not yet stored in the soup */
- (id<ILMutableSoupEntry>) createBlankEntry;

/*  @brief store an entry to this soup
    @returns the alias used to store the entry */
- (NSString*) addEntry:(id<ILSoupEntry>) entry;

/*  @brief duplicate the entry entry, providing a mutable entry with a new UUID,
    NB that the duplicate entry is not yet stored in the soup */
- (id<ILMutableSoupEntry>) duplicateEntry:(id<ILSoupEntry>) entry;

/*  @brief delete an entry from this soup */
- (void) deleteEntry:(id<ILSoupEntry>) entry;

#pragma mark - Aliases

/*  @brief get the soups alias the entry (may be the hash, UUID or other string) */
- (NSString*) entryAlias:(id<ILSoupEntry>) entry;

/*  @brief the the item from the soup, based on the alias provided */
- (id<ILSoupEntry>) gotoAlias:(NSString*) alias;

#pragma mark - Queries

/*  @brief a cursor with items specified by the predicate, O(N) time */
- (id<ILSoupCursor>) querySoup:(NSPredicate*) query;

#pragma mark - Indicies

/* @breif the indexes currently maintained for this soup */
@property(nonatomic, readonly) NSArray<id<ILSoupIndex>>* soupIndicies;

/*  @brief create a new index on this soup with the path provided */
- (id<ILSoupIndex>) createIndex:(NSString*)indexPath;

/* @brief returns the index for the path provided */
- (id<ILSoupIndex>) queryIndex:(NSString*)indexPath;

/*  @brief create a new index on this soup with the path provided */
- (id<ILSoupTextIndex>) createTextIndex:(NSString*)indexPath;

/* @brief returns the index for the path provided */
- (id<ILSoupTextIndex>) queryTextIndex:(NSString*)indexPath;

/*  @brief create a new index on this soup with the path provided */
- (id<ILSoupNumberIndex>) createNumberIndex:(NSString*)indexPath;

/* @brief returns the index for the path provided */
- (id<ILSoupNumberIndex>) queryNumberIndex:(NSString*)indexPath;

/*  @brief create a new index on this soup with the path provided */
- (id<ILSoupDateIndex>) createDateIndex:(NSString*)indexPath;

/* @brief returns the index for the path provided */
- (id<ILSoupDateIndex>) queryDateIndex:(NSString*)indexPath;

#pragma mark - Default Cursor

/*  @brief create or reset cursor after setting soupQuery */
- (id<ILSoupCursor>) setupCursor;

/*  @brief the default cursor for this soup */
- (id<ILSoupCursor>) getCursor;

#pragma mark - Sequences

/* @brief the sequences currently maintained for this soup */
@property(nonatomic, readonly) NSArray<id<ILSoupSequence>>* soupSequences;

/*  @brief create a sequence for numbers with the provided path */
- (id<ILSoupSequence>) createSequence:(NSString*) sequencePath;

/* @brief returns the sequence for the path provided */
- (id<ILSoupSequence>) querySequence:(NSString*) sequencePath;

#pragma mark - Soup Managment

/*  @brief if you need to do setup, now is the time */
- (void) fillNewSoup;

/*  @brief we're done here */
- (void) doneWithSoup:(NSString*) appIdentifier;

@end

#pragma mark -

/*  @brief delegate protocol for <ILSoup>
    <a id="ILSoupDelegate"></a> */
@protocol ILSoupDelegate
@optional

/* @brief entry was created from the soup defaults */
- (void) soup:(id<ILSoup>) deJour createdEntry:(id<ILSoupEntry>) entry;

/*  @brief entry was added to the soup */
- (void) soup:(id<ILSoup>) deJour addedEntry:(id<ILSoupEntry>) entry;

/* @brief entry was deleted from the soup */
- (void) soup:(id<ILSoup>) deJour deletedEntry:(id<ILSoupEntry>) entry;

#pragma mark - Indicies & Sequences

/* @brief index was added to the soup */
- (void) soup:(id<ILSoup>) deJour createdIndex:(id<ILSoupIndex>) index;

/* @brief sequence was added to the soup */
- (void) soup:(id<ILSoup>) deJour createdSequence:(id<ILSoupSequence>) sequence;

#pragma mark - Lifecycle

/* @brief soup was initially filled */
- (void) soupFilled:(id<ILSoup>) deJour;

/* @brief soup is done */
- (void) soupDone:(id<ILSoup>) deJour;

@end

#endif /* ILSoup_h */
