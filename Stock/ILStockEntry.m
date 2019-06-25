#import "ILStockEntry.h"
#import "NSDictionary+Hashcodes.h"

@interface ILStockEntry ()
@property(nonatomic,retain) NSDictionary* entryKeysStorage;

- (instancetype) initWithKeys:(NSDictionary*) entryKeys;

@end

#pragma mark -

NSString* ILSoupEntryUUID           = @"soup.entry.uuid";
NSString* ILSoupEntryCreationDate   = @"soup.entry.created";
NSString* ILSoupEntryDataHash       = @"soup.entry.dataHash";
NSString* ILSoupEntryKeysHash       = @"soup.entry.keysHash";

@implementation ILStockEntry

+ (instancetype) soupEntryFromKeys:(NSDictionary*) entryKeys
{
    return [ILStockEntry.alloc initWithKeys:entryKeys];
}

#pragma mark - ILSoupStockEntry

- (instancetype) initWithKeys:(NSDictionary*) entryKeys
{
    if ((self = super.init)) {
        NSMutableDictionary* newEntryKeys = (entryKeys ? entryKeys.mutableCopy : NSMutableDictionary.new);
        if (![newEntryKeys.allKeys containsObject:ILSoupEntryUUID]) { // create a new UUID for the entry
            newEntryKeys[ILSoupEntryUUID] = NSUUID.UUID.UUIDString;
        }
        
        if (![newEntryKeys.allKeys containsObject:ILSoupEntryCreationDate]) { // enter a creation date for the entry
            newEntryKeys[ILSoupEntryCreationDate] = NSDate.date;
        }
        
        NSMutableDictionary* entryDataKeys = newEntryKeys.mutableCopy;
        for (NSString* soupKey in @[ILSoupEntryUUID, ILSoupEntryCreationDate, ILSoupEntryDataHash,
            ILSoupEntryKeysHash, ILSoupEntryAncestorKey, ILSoupEntryMutationDate]) {
            [entryDataKeys removeObjectForKey:soupKey];
        }
        
        newEntryKeys[ILSoupEntryDataHash] = [entryDataKeys sha224AllKeysAndValues];
        newEntryKeys[ILSoupEntryKeysHash] = [entryDataKeys sha224AllKeys];
        
        self.entryKeysStorage = newEntryKeys;
    }
    return self;
}

- (instancetype) init
{
    return [self initWithKeys:@{}];
}

#pragma mark - ILSoupEntry

- (NSString*) entryHash
{
    return [self.entryKeys sha224AllKeysAndValues];
}

- (NSString*) dataHash
{
    return self.entryKeys[ILSoupEntryDataHash];
}

- (NSString*) keysHash
{
    return self.entryKeys[ILSoupEntryKeysHash];
}

- (NSDictionary*) entryKeys
{
    return self.entryKeysStorage;
}

#pragma mark - ILMutableSoupEntry

NSString* ILSoupEntryAncestorKey    = @"soup.entry.ancestor";
NSString* ILSoupEntryMutationDate   = @"soup.entry.mutated";

- (id<ILSoupEntry>) mutatedEntry:(NSString*) mutatedKey newValue:(id) value
{
    NSMutableDictionary* mutatedKeys = self.entryKeysStorage.mutableCopy;
    mutatedKeys[mutatedKey] = value;
    return [self.class soupEntryFromKeys:mutatedKeys];
}

- (id<ILSoupEntry>) mutatedEntry:(NSDictionary*) mutatedValues
{
    NSMutableDictionary* mutatedKeys = (self.entryKeysStorage ? self.entryKeysStorage.mutableCopy : NSMutableDictionary.new);
    for (id key in mutatedValues.allKeys) {
        mutatedKeys[key] = mutatedValues[key];
    }
    mutatedKeys[ILSoupEntryAncestorKey] = self.entryHash;
    mutatedKeys[ILSoupEntryMutationDate] = NSDate.date;
    return [self.class soupEntryFromKeys:mutatedKeys];
}

#pragma mark - Ancestry

- (NSString*) ancestorEntryHash
{
    return self.entryKeys[ILSoupEntryAncestorKey];
}

#pragma mark -

- (NSString*) description
{
    return [NSString stringWithFormat:@"%@ %@ %@", self.class, self.entryHash, self.entryKeys];
}

@end
