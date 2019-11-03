#ifndef ILSoupEntry_h
#define ILSoupEntry_h

// MARK: -

/*! @brief NSString* UUID */
extern NSString* ILSoupEntryUUID;

/*! @brief NSDate* creation date */
extern NSString* ILSoupEntryCreationDate; // NSDate*

/*! @brief NSString* dataHash */
extern NSString* ILSoupEntryDataHash; // NSString*

/*! @brief protocol for an entry in ILSoup */
@protocol ILSoupEntry

/*! @brief hashcode for the entry */
@property(nonatomic, readonly) NSString* entryHash;

/*! @brief hashcode for the data records (excluding the Soup Meta-Data) */
@property(nonatomic, readonly) NSString* dataHash;

/*! @brief hashcode for the keys of the entry (excluding the Soup Meta-Data Keys) */
@property(nonatomic, readonly) NSString* keysHash;

/*! @brief keys and values for the entry */
@property(nonatomic, readonly) NSDictionary* entryKeys;

// MARK: -

/*! @brief create entry with keys provided */
+ (instancetype) soupEntryFromKeys:(NSDictionary*) entryKeys;

@end

// MARK: -

/*! @brief NSString* hash of the ancestor for a mutated entry */
extern NSString* ILSoupEntryAncestorKey;

/*! @brief NSDate* that the entry was mutated */
extern NSString* ILSoupEntryMutationDate;

/*! @brief protocol for mutable entries in ILSoup
    <a id="ILMutableSoupEntry"></a> */
@protocol ILMutableSoupEntry <ILSoupEntry>

/*! @brief mutate a single key and value in the entry, creating a new entry with the same UUID and a new hash */
- (id<ILMutableSoupEntry>) mutatedEntry:(NSString*) mutatedKey newValue:(id) value;

/*! @brief mutate keys and values provided, creating a new entry with the same UUID and a new hash */
- (id<ILMutableSoupEntry>) mutatedEntry:(NSDictionary*) mutatedValues;

@end

#endif /* ILSoupEntry_h */
