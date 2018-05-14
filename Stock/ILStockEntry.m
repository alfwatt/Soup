#import "ILStockEntry.h"
#import "NSDictionary+Hashcodes.h"

@interface ILStockEntry ()
@property(nonatomic,retain) NSDictionary* entryKeysStorage;

- (instancetype) initWithKeys:(NSDictionary*) entryKeys;

@end

#pragma mark -

NSString* ILSoupEntryUUID = @"uuid";
NSString* ILSoupEntryCreationDate = @"created";

@implementation ILStockEntry

+ (instancetype) soupEntryFromKeys:(NSDictionary*) entryKeys
{
    return [[ILStockEntry alloc] initWithKeys:entryKeys];
}

#pragma mark - ILSoupStockEntry

- (instancetype) initWithKeys:(NSDictionary*) entryKeys
{
    if (self = [super init]) {
        NSMutableDictionary* newEntryKeys = [entryKeys mutableCopy];
        if (![[newEntryKeys allKeys] containsObject:ILSoupEntryUUID]) { // create a new UUID for the entry
            newEntryKeys[ILSoupEntryUUID] = [[NSUUID UUID] UUIDString];
        }
        
        if (![[newEntryKeys allKeys] containsObject:ILSoupEntryCreationDate]) { // enter a creation date for the entry
            newEntryKeys[ILSoupEntryCreationDate] = [NSDate date];
        }
        
        self.entryKeysStorage = newEntryKeys;
    }
    return self;
}


#pragma mark - ILSoupEntry

- (NSString*) entryHash
{
    return [self.entryKeys sha224AllKeysAndValues];
}

- (NSDictionary*) entryKeys
{
    return self.entryKeysStorage;
}

#pragma mark - ILMutableSoupEntry

NSString* ILMutableSoupEntryAncestorKey = @"ancestor";
NSString* ILMutableSoupEntryMutationDate = @"mutated";


- (id<ILSoupEntry>) mutatedEntry:(NSString*) mutatedKey newValue:(id) value
{
    NSMutableDictionary* mutatedKeys = [self.entryKeysStorage mutableCopy];
    mutatedKeys[mutatedKey] = value;
    return [ILStockEntry soupEntryFromKeys:mutatedKeys];
}

- (id<ILSoupEntry>) mutatedEntry:(NSDictionary*) mutatedValues
{
    NSMutableDictionary* mutatedKeys = [self.entryKeysStorage mutableCopy];
    for (id key in mutatedValues.allKeys) {
        mutatedKeys[key] = mutatedValues[key];
    }
    mutatedKeys[ILMutableSoupEntryAncestorKey] = self.entryHash;
    mutatedKeys[ILMutableSoupEntryMutationDate] = [NSDate date];
    return [ILStockEntry soupEntryFromKeys:mutatedKeys];
}

#pragma mark - Ancestry

- (NSString*) ancestorEntryHash
{
    return self.entryKeys[ILMutableSoupEntryAncestorKey];
}

#pragma mark -

- (NSString*) description
{
    return [NSString stringWithFormat:@"%@ %@ %@", self.className, self.entryHash, self.entryKeys];
}

@end
