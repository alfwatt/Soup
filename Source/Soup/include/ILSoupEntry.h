#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

// MARK: -

/// The entity UUID which identifies all versions of an entry in the soup
static NSString* const ILSoupEntryIdentityUUID = @"soup.entry.uuid";

/// Creation date of the entity
static NSString* const ILSoupEntryCreationDate = @"soup.entry.created";

/// Hash of all the keys and data in the entry
static NSString* const ILSoupEntryHash = @"soup.entry.hash";

/// Hash of all the data in the entry
static NSString* const ILSoupEntryDataHash = @"soup.entry.dataHash";

/// Hash of all the keys in the entry, defines an entry type
static NSString* const ILSoupEntryKeysHash = @"soup.entry.keysHash";

/// The local className for the entry, used
static NSString* const ILSoupEntryClassName = @"soup.entry.className";

/// The identityUUID of the entry this was duplicated from
static NSString* const ILSoupEntryDuplicateUUID = @"soup.entry.duplicate.uuid";

@protocol ILMutableSoupEntry; // for mutableCopy

/// @protocol for an entry in ILSoup
@protocol ILSoupEntry <NSCopying,NSMutableCopying>

/// @property entryHash — unique hash-code for the entry
@property(nonatomic, readonly) NSString* entryHash;

/// @property dataHash — hash-code for the data records (excluding the Soup Meta-Data)
@property(nonatomic, readonly) NSString* dataHash;

/// @property keysHash — hash-code for the keys of the entry (excluding the Soup Meta-Data Keys)
/// this is effectively a `typeOf`' value for any given entity with the same set of keys
@property(nonatomic, readonly) NSString* keysHash;

/// @property dictionary of keys and values for the entry
@property(nonatomic, readonly) NSDictionary<NSString*, NSObject*>* entryKeys;

/// @property sorted keys of the entryKeys dictionary
@property(nonatomic, readonly) NSArray<NSString*>* sortedEntryKeys;

/// @param entryKeys —dictionary of keys and values for the entry
/// @returns an auto-released `<ILSoupEntry>` with the `entryKeys` provided
+ (instancetype) soupEntryWithKeys:(NSDictionary<NSString*, NSObject*>*) entryKeys;

/// @param entryKeys — dictionary of keys and values for the entry
/// @returns a new `<ILSoupEntry>` with the `entryKeys` provided
- (instancetype) initWithKeys:(NSDictionary<NSString*, NSObject*>*) entryKeys;

// MARK: - NSObject Overrides

- (instancetype) copy;

- (id<ILMutableSoupEntry>) mutableCopy;

@end

// MARK: -

/// NSString* hash of the ancestor for a mutated entry
extern NSString* ILSoupEntryAncestorEntryHash;

/// NSDate* that the entry was mutated
extern NSString* ILSoupEntryMutationDate;

/// @protocol for mutable entries in ILSoup
///     <a id="ILMutableSoupEntry"></a>
@protocol ILMutableSoupEntry <ILSoupEntry>

/// @returns a mutable version of the entry provided
+ (instancetype) mutableEntry:(id<ILSoupEntry>) entry;

/// @returns an initialized <ILMutableSoupEntry>
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
