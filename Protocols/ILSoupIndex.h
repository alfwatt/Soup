#ifndef ILSoupIndex_h
#define ILSoupIndex_h

#pragma mark -

@protocol ILSoupEntry;

#pragma mark -

/*! @brief result set for a particular query executed against the index */
@protocol ILSoupCursor

/*! @brief the array of entries in this cursor */
@property(readonly) NSArray<id<ILSoupEntry>>* entries;

/*! @brief the current index of the cursor */
@property(readonly) NSUInteger index;

#pragma mark -

/*! @brief create a cursor with the entries provided */
- (instancetype) initWithEntries:(NSArray<id<ILSoupEntry>>*) entries;

/*! @brief get the next entry in the cursor, and advance the index */
- (id<ILSoupEntry>) nextEntry;

/*! @brief reset the cursor index to 0 */
- (void) resetCursor;

@end

#pragma mark -

/*! @brief manintain an index of items by an indexPath provided
    <a id="ILSoupIndex"></a> */
@protocol ILSoupIndex

/*! @brief this path used to fetch indexed properties from the items to build the index */
@property(readonly) NSString* indexPath;

#pragma mark -

/*! @brief create an index with the path provided */
+ (instancetype) indexWithPath:(NSString*) indexPath;

#pragma mark - Entries

/*! @brief add the entry to the index */
- (void) indexEntry:(id<ILSoupEntry>) entry;

/*! @brief remove the entry from the index */
- (void) removeEntry:(id<ILSoupEntry>) entry;

/*! @brief is the entry in the index */
- (BOOL) includesEntry:(id<ILSoupEntry>) entry;

#pragma mark - Cursors

/*! @brief a cursor with all the entries currently in the index */
- (id<ILSoupCursor>) allEntries;

/*! @brief a cursor with all items having the provided value in the index */
- (id<ILSoupCursor>) entriesWithValue:(id) value;

@end

#pragma mark -

/*! @brief an identity index maintains a mapping of values to single Soup Entries,
    if an entry is added to the index twice the first entry is replaced by the later
    <a id="ILSoupIdentityIndex"></a>  */
@protocol ILSoupIdentityIndex <ILSoupIndex>

- (id<ILSoupEntry>) entryWithValue:(id) value;

@end

#pragma mark -

/*! @brief only indexes values which are strings, can be searched with a regex
    <a id="ILSoupTextIndex"></a> */
@protocol ILSoupTextIndex <ILSoupIndex>

/*! @brief a cursor with all items matching the regular expression pattern provided */
- (id<ILSoupCursor>) entriesWithStringValueMatching:(NSString*) pattern;

@end

#pragma mark -

/*! @brief only indexes values wich are numbers
   <a id="ILSoupNumberIndex"></a> */
@protocol ILSoupNumberIndex <ILSoupIndex>

/*! @brief a cursor of items with values between the numbers provided */
- (id<ILSoupCursor>) entriesWithValuesBetween:(NSNumber*) min and:(NSNumber*) max;

@end

#pragma mark -

/*! @brief only indexes values which are dates
   <a id="ILSoupDateIndex"></a> */
@protocol ILSoupDateIndex <ILSoupIndex>

/*! @brief a cursor of items with values between the dates provided */
- (id<ILSoupCursor>) entriesWithDatesBetween:(NSDate*) earliest and:(NSDate*) latest;

@end

#endif /* ILSoupIndex_h */
