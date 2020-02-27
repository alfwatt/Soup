#ifndef ILSoupEntry_h
#define ILSoupEntry_h

// MARK: -

/// NSString* UUID
extern NSString* ILSoupEntryUUID;

/// NSDate* creation date
extern NSString* ILSoupEntryCreationDate; // NSDate*

/// NSString* dataHash
extern NSString* ILSoupEntryDataHash; // NSString*

/// protocol for an entry in ILSoup
@protocol ILSoupEntry

/// hashcode for the entry
@property(nonatomic, readonly) NSString* entryHash;

/// hashcode for the data records (excluding the Soup Meta-Data)
@property(nonatomic, readonly) NSString* dataHash;

/// hashcode for the keys of the entry (excluding the Soup Meta-Data Keys)
@property(nonatomic, readonly) NSString* keysHash;

/// keys and values for the entry
@property(nonatomic, readonly) NSDictionary* entryKeys;

// MARK: -

/// create entry with keys provided
+ (instancetype) soupEntryFromKeys:(NSDictionary*) entryKeys;

@end

// MARK: -

/// NSString* hash of the ancestor for a mutated entry
extern NSString* ILSoupEntryAncestorKey;

/// NSDate* that the entry was mutated
extern NSString* ILSoupEntryMutationDate;

/// protocol for mutable entries in ILSoup
///     <a id="ILMutableSoupEntry"></a>
@protocol ILMutableSoupEntry <ILSoupEntry>

/// mutate a single key and value in the entry, creating a new entry with the same UUID and a new hash
- (id<ILMutableSoupEntry>) mutatedEntry:(NSString*) mutatedKey newValue:(id) value;

/// mutate keys and values provided, creating a new entry with the same UUID and a new hash
- (id<ILMutableSoupEntry>) mutatedEntry:(NSDictionary*) mutatedValues;

@end

#endif
