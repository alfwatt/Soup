#ifndef ILSoupIndex_h
#define ILSoupIndex_h

@protocol ILSoupEntry;
@protocol ILSoupTime;

// MARK: -

/// @brief result set for a particular query executed against the index
@protocol ILSoupCursor

/// @brief the array of entries in this cursor
@property(readonly) NSArray<id<ILSoupEntry>>* entries;

/// @brief the current index of the cursor
@property(readonly) NSUInteger index;

// MARK: -

/// @brief create a cursor with the entries provided
- (instancetype) initWithEntries:(NSArray<id<ILSoupEntry>>*) entries;

/// @brief get the next entry in the cursor, and advance the index
- (id<ILSoupEntry>) nextEntry;

/// @brief reset the cursor index to 0
- (void) resetCursor;

@end

// MARK: -

/// Random Access to Cursor Entries by Index or range
/// @extends ILSoupCursor to add methods which might be performance intensive,
/// depending on the indexing method used
@protocol ILSoupCursorRandomAccess <ILSoupCursor>

/// @returns the number of entries in this cursor
@property(readonly) NSUInteger count;

/// @param entryIndex — index of th entry we want to access
/// @returns the `ILSoupEntry` entry at the entryIndex provided
- (id<ILSoupEntry>) entryAtIndex:(NSUInteger) entryIndex;

/// @param entryRange — an `NSRage` indicating the index and count of entries to be returned
/// @returns an array of objects which implement `ILSoupEntry`
- (NSArray<id<ILSoupEntry>>*) entriesInRange:(NSRange) entryRange;

@end

// MARK: -

/// @protocol manintains an index of items by an indexPath provided
/// <a id="ILSoupIndex"></a>
@protocol ILSoupIndex

/// this path used to fetch indexed properties from the items to build the index
@property(readonly) NSString* indexPath;

// MARK: -

/// create an index with the path provided
+ (instancetype) indexWithPath:(NSString*) indexPath;

// MARK: - Entries

/// add the entry to the index
- (void) indexEntry:(id<ILSoupEntry>) entry;

/// remove the entry from the index
- (void) removeEntry:(id<ILSoupEntry>) entry;

/// is the entry in the index
- (BOOL) includesEntry:(id<ILSoupEntry>) entry;

// MARK: - Cursors

/// a cursor with all the entries currently in the index
- (id<ILSoupCursor>) allEntries;

/// a cursor with all items having the provided value in the index
- (id<ILSoupCursor>) entriesWithValue:(id) value;

@end

// MARK: -

/// an identity index maintains a mapping of values to single Soup Entries,
/// if an entry is added to the index twice the first entry is replaced by the later
/// <a id="ILSoupIdentityIndex"></a>
@protocol ILSoupIdentityIndex <ILSoupIndex>

- (id<ILSoupEntry>) entryWithValue:(id) value;

@end

// MARK: -

/// only indexes values which are strings, can be searched with a regex
/// <a id="ILSoupTextIndex"></a>
@protocol ILSoupTextIndex <ILSoupIndex>

/// a cursor with all items matching the regular expression pattern provided
- (id<ILSoupCursor>) entriesWithStringValueMatching:(NSString*) pattern;

@end

// MARK: -

/// only indexes values wich are numbers
/// <a id="ILSoupNumberIndex"></a>
@protocol ILSoupNumberIndex <ILSoupIndex>

/// a cursor of items with values between the numbers provided
- (id<ILSoupCursor>) entriesWithValuesBetween:(NSNumber*) min and:(NSNumber*) max;

@end

// MARK: -

/// only indexes values which are dates
/// <a id="ILSoupDateIndex"></a>
@protocol ILSoupDateIndex <ILSoupIndex>

/// @param early — events before this are too early
/// @param late — events after this are too late
/// @returns a cursor of items with values between the dates provided
- (id<ILSoupCursor>) entriesWithDatesBetween:(NSDate*) early and:(NSDate*) late;

/// @param timeRange — an object implementing the ILSoupTime protocol
/// @returns a cursor of items with values between the dates provided
- (id<ILSoupCursor>) entriesWithTimeRange:(id<ILSoupTime>) timeRange;

@end

#endif
