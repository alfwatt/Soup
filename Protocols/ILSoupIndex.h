#ifndef ILSoupIndex_h
#define ILSoupIndex_h

#pragma mark -

@protocol ILSoupEntry;

#pragma mark -

/* @biref result set for a particular query executed against the  */
@protocol ILSoupCursor

/* @brief the array of entries in this cursor */
@property(readonly) NSArray<id<ILSoupEntry>>* entries;

/* @biref the current index of the cursor */
@property(readonly) NSUInteger index;

#pragma mark -

/* @biref create a cursor with the entries provided */
- (instancetype) initWithEntries:(NSArray<id<ILSoupEntry>>*) entries;

/* @brief get the next entry in the cursor, and advance the index */
- (id<ILSoupEntry>) nextEntry;

/* @biref reset the cursor index to 0 */
- (void) resetCursor;

@end

#pragma mark -

/* @biref manintain an index of items by an indexPath provided */
@protocol ILSoupIndex

/* @biref this path used to fetch indexed properties from the items to build the index */
@property(readonly) NSString* indexPath;

#pragma mark -

/* @brief create an index with the path provided */
+ (instancetype) indexWithPath:(NSString*) indexPath;

#pragma mark - Entries

/* @brief add the entry to the index */
- (void) indexEntry:(id<ILSoupEntry>) entry;

/* @brief remove the entry from the index */
- (void) removeEntry:(id<ILSoupEntry>) entry;

/* @brief is the entry in the index */
- (BOOL) includesEntry:(id<ILSoupEntry>) entry;

#pragma mark - Cursors

/* @brief a cursor with all items having the provided value in the index */
- (id<ILSoupCursor>) entriesWithValue:(id) value;

@end

#pragma mark -

/* @brief only indexes values which are strings, can be searched with a regex  */
@protocol ILSoupStringIndex <ILSoupIndex>

/* @brief a cursor with all items matching the regular expression pattern provided */
- (id<ILSoupCursor>) entriesWithStringValueMatching:(NSString*) pattern;

@end

#pragma mark -

/* @brief only indexes values wich are numbers */
@protocol ILSoupNumberIndex <ILSoupIndex>

/* @brief a cursor of items with values between the numbers provided */
- (id<ILSoupCursor>) entriesWithValueBetween:(NSNumber*) min and:(NSNumber*) max;

@end

#pragma mark -

/* @brief only indexes values which are dates */
@protocol ILSoupDateIndex <ILSoupIndex>

/* @brief a cursor of items with values between the dates provided */
- (id<ILSoupCursor>) entriesWithDatesBetween:(NSDate*) earliest and:(NSDate*) latest;

@end

#endif /* ILSoupIndex_h */
