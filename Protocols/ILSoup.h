#ifndef ILSoup_h
#define ILSoup_h

#pragma mark -

@protocol ILSoupEntry;
@protocol ILMutableSoupEntry;
@protocol ILSoupIndex;
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
@property(nonatomic, assign) id<ILSoupDelegate> delegate;

#pragma mark -

/* @breif the indexes currently maintained for this soup */
@property(nonatomic, readonly) NSArray<id<ILSoupIndex>>* soupIndicies;

/* @brief the sequences currently maintained for this soup */
@property(nonatomic, readonly) NSArray<id<ILSoupSequence>>* soupSequences;

#pragma mark -

/* @brief create a new soup with the provided name */
+ (instancetype) makeSoup:(NSString*) soupName;

#pragma mark - Entries

/* @brief add an entry to this soup */
- (void) addEntry:(id<ILSoupEntry>) entry;

/* @breif create a new blank entry, with the defaults for this soup and a new UUID */
- (id<ILMutableSoupEntry>) createBlankEntry;

/* @brief delete an entry from this soup */
- (void) deleteEntry:(id<ILSoupEntry>) entry;

/* @breif duplicate an entry, providing a mutable entry with a new UUID */
- (id<ILMutableSoupEntry>) duplicateEntry:(id<ILSoupEntry>) entry;

/* @brief get the soups alias the entry (may be the hash, UUID or other string) */
- (NSString*) getAlias:(id<ILSoupEntry>) entry;

/* @brief the the item from the soup, based on the alias provided */
- (id<ILSoupEntry>) gotoAlias:(NSString*) alias;

#pragma mark - Indicies

/* @brief create a new index on this soup with the path provided */
- (id<ILSoupIndex>) createIndex:(NSString*)indexPath;

#pragma mark - Default Cursor

/* @brief create or reset cursor after setting soupQuery */
- (void) setupCursor;

/* @brief the default cursor for this soup */
- (id<ILSoupCursor>) getCursor;

/* @brief a cursor with items specified by the query */
- (id<ILSoupCursor>) quey:(NSPredicate*) query;

#pragma mark - Sequences

/* @brief create a sequence for numbers with the provided path */
- (id<ILSoupSequence>) createSequence:(NSString*) sequencePath;

#pragma mark - Soup Managment

/* @brief we're done here */
- (void) doneWithSoup:(NSString*) appIdentifier;

/* @brief if you need to do setup, now is the time */
- (void) fillNewSoup;

@end

#pragma mark -

/* @brief delegate protocol for <ILSoup>  */
@protocol ILSoupDelegate
@optional

/* @brief entry was added to the soup */
- (void) soup:(id<ILSoup>) deJour addedEntry:(id<ILSoupEntry>) entry;

/* @brief entry was deleted from the soup */
- (void) soup:(id<ILSoup>) deJour deletedEntry:(id<ILSoupEntry>) entry;

/* @brief entry was created from the soup defaults */
- (void) soup:(id<ILSoup>) deJour createdEntry:(id<ILSoupEntry>) entry;

#pragma mark - Indicies & Sequences

/* @brief index was added to the soup */
- (void) soup:(id<ILSoup>) deJour createIndex:(id<ILSoupIndex>) index;

/* @brief sequence was added to the soup */
- (void) soup:(id<ILSoup>) deJour createSequence:(id<ILSoupSequence>) sequence;

#pragma mark - Lifecycle

/* @brief soup was initially filled */
- (void) soupFill:(id<ILSoup>) deJour;

/* @brief soup is done */
- (void) soupDone:(id<ILSoup>) deJour;

@end

#endif /* ILSoup_h */
