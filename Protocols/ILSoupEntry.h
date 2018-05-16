#ifndef ILSoupEntry_h
#define ILSoupEntry_h

#pragma mark -

/* @brief NSString* UUID */
extern NSString* ILSoupEntryUUID;

/* @brief NSDate* creation date */
extern NSString* ILSoupEntryCreationDate; // NSDate*

/* @brief protocol for an entry in ILSoup */
@protocol ILSoupEntry

/* @brief hashcode for the entry */
@property(nonatomic, readonly) NSString* entryHash;

/* @brief keys and values for the entry */
@property(nonatomic, readonly) NSDictionary* entryKeys;

#pragma mark -

/* @brief create entry with keys provided */
+ (instancetype) soupEntryFromKeys:(NSDictionary*) entryKeys;

@end

#pragma mark -

/* @brief NSString* hash of the ancestor for a mutated entry */
extern NSString* ILSoupEntryAncestorKey;

/* @brief NSDate* that the entry was mutated */
extern NSString* ILSoupEntryMutationDate;

/* @brief protocol for mutable entries in ILSoup */
@protocol ILMutableSoupEntry <ILSoupEntry>

/* @brief mutate a single key and value in the entry, creating a new entry with the same UUID and a new hash */
- (id<ILMutableSoupEntry>) mutatedEntry:(NSString*) mutatedKey newValue:(id) value;

/* @brief mutate keys and values provided, creating a new entry with the same UUID and a new hash */
- (id<ILMutableSoupEntry>) mutatedEntry:(NSDictionary*) mutatedValues;

@end

#endif /* ILSoupEntry_h */
