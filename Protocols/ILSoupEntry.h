#ifndef ILSoupEntry_h
#define ILSoupEntry_h

NS_ASSUME_NONNULL_BEGIN

// MARK: ILSoupEntry

/// String UUID
static NSString* const ILSoupEntryIdentityUUID = @"soup.entry.uuid";

/// Date creation date
static NSString* const ILSoupEntryCreationDate = @"soup.entry.created";

/// String  entryHash 
static NSString* const ILSoupEntryHash = @"soup.entry.hash";

/// String dataHash
static NSString* const ILSoupEntryDataHash = @"soup.entry.dataHash";

/// String keysHash
static NSString* const ILSoupEntryKeysHash = @"soup.entry.keysHash";

/// String className — the local className for the entry
static NSString* const ILSoupEntryClassName = @"soup.entry.className";

/// String duplicateUUID - the identityUUID of the entry this was duplicated from
static NSString* const ILSoupEntryDuplicateUUID = @"soup.entry.duplicate.uuid";

@protocol ILMutableSoupEntry; // for mutableCopy

/// @protocol for an entry in ILSoup
@protocol ILSoupEntry <NSCopying,NSMutableCopying>

/// @property entryHash — unique hashcode for the entry
@property(nonatomic, readonly) NSString* entryHash;

/// @property dataHash — hashcode for the data records (excluding the Soup Meta-Data)
@property(nonatomic, readonly) NSString* dataHash;

/// @property keysHash — hashcode for the keys of the entry (excluding the Soup Meta-Data Keys)
/// this is effectivley a `typeOf`' value for any given entity with the same set of keys
@property(nonatomic, readonly) NSString* keysHash;

/// @property dictionary of keys and values for the entry
@property(nonatomic, readonly) NSDictionary<NSString*, id>* entryKeys;

/// @property sorted keys of the entryKeys dictionary
@property(nonatomic, readonly) NSArray<NSString*>* sortedEntryKeys;

/// @param entryKeys —dictionary of keys and values for the entry
/// @returns an auto-released `<ILSopuEntry>` with the `entryKeys` provided
+ (instancetype) soupEntryWithKeys:(NSDictionary<NSString*, id>*) entryKeys;

/// @param entryKeys — dictionary of keys and values for the entry
/// @returns a new `<ILSopuEntry>` with the `entryKeys` provided
- (instancetype) initWithKeys:(NSDictionary<NSString*, id>*) entryKeys;

// MARK: - NSObject Overrides

- (instancetype) copy;

- (id<ILMutableSoupEntry>) mutableCopy;

@end

// MARK: - ILMutableSoupEntry

/// NSString* hash of the ancestor for a mutated entry
extern NSString* ILSoupEntryAncestorEntryHash;

/// NSDate* that the entry was mutated
extern NSString* ILSoupEntryMutationDate;

/// @protocol for mutable entries in ILSoup
///     <a id="ILMutableSoupEntry"></a>
@protocol ILMutableSoupEntry <ILSoupEntry>

/// @returns a mutable version of the entry provided
+ (instancetype) mutableEntry:(id<ILSoupEntry>) entry;

/// @returns an initalized <ILMutableSoupEntry>
- (instancetype) initWithEntry:(id<ILSoupEntry>) entry;

/// @param mutatedValues — a dictionary of keys and values
/// @returns an `<ILMutableSoupEntry>` with mutated keys and values provided in `mutatedValues`
/// creating a new entry with the same UUID and a new hash
//  Note: mutatedCopy would be more natural but too easy to conflate with mutableCopy
- (instancetype) mutatedEntry:(NSDictionary<NSString*, id>*) mutatedValues;

/// duplicate entry, providing a mutable entry with a new UUID
/// duplicate will have a ILSoupEntryDuplicateUUID key with the identity UUID of the original object
/// N.B. that the duplicate entry is not yet stored in the soup
/// @returns – `<ILMutableSoupEntry>` which is a duplicate of the data in `entry`
- (instancetype) duplicateEntry;

@end

NS_ASSUME_NONNULL_END

#endif
