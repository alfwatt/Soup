#import "ILStockEntry.h"
#import "NSDictionary+Hashcodes.h"

@interface ILStockEntry ()
@property(nonatomic,retain) NSDictionary* entryKeysStorage;
@property(nonatomic,retain) NSMutableDictionary* entryKeysMutations;

- (instancetype) initWithKeys:(NSDictionary*) entryKeys;

@end

// MARK: -

@implementation ILStockEntry

+ (instancetype) soupEntryWithKeys:(NSDictionary*) entryKeys {
    return [ILStockEntry.alloc initWithKeys:entryKeys];
}

// MARK: - ILSoupStockEntry

- (instancetype) initWithKeys:(NSDictionary*) entryKeys {
    if ((self = super.init)) {
        NSMutableDictionary* newEntryKeys = (entryKeys ? entryKeys.mutableCopy : NSMutableDictionary.new);
        
        if (![newEntryKeys.allKeys containsObject:ILSoupEntryUUID]) { // create a new UUID for the entry
            newEntryKeys[ILSoupEntryUUID] = NSUUID.UUID.UUIDString;
        }
        
        if (![newEntryKeys.allKeys containsObject:ILSoupEntryCreationDate]) { // enter a creation date for the entry
            newEntryKeys[ILSoupEntryCreationDate] = NSDate.date;
        }
        
        if (![newEntryKeys.allKeys containsObject:ILSoupEntryClassName]) { // enter the class name for this instance
            newEntryKeys[ILSoupEntryClassName] = NSStringFromClass(self.class);
        }
        
        NSMutableDictionary* entryDataKeys = newEntryKeys.mutableCopy;
        for (NSString* soupKey in @[ILSoupEntryUUID, ILSoupEntryCreationDate, ILSoupEntryDataHash,
            ILSoupEntryKeysHash, ILSoupEntryAncestorKey, ILSoupEntryMutationDate]) {
            [entryDataKeys removeObjectForKey:soupKey];
        }
        
        // generate the keys and data hash values for the entry
        newEntryKeys[ILSoupEntryDataHash] = [entryDataKeys sha224AllKeysAndValues];
        newEntryKeys[ILSoupEntryKeysHash] = [entryDataKeys sha224AllKeys];

        self.entryKeysStorage = newEntryKeys;
        self.entryKeysMutations = NSMutableDictionary.new;
    }
    
    return self;
}

- (instancetype) init {
    return [self initWithKeys:@{}];
}

// MARK: - ILSoupEntry

- (NSString*) entryHash {
    return [self.entryKeys sha224AllKeysAndValues];
}

- (NSString*) dataHash {
    return self.entryKeys[ILSoupEntryDataHash];
}

- (NSString*) keysHash {
    return self.entryKeys[ILSoupEntryKeysHash];
}

- (NSDictionary*) entryKeys {
    return self.entryKeysStorage;
}

// MARK: - ILMutableSoupEntry

NSString* ILSoupEntryAncestorKey = @"soup.entry.ancestor";
NSString* ILSoupEntryMutationDate = @"soup.entry.mutated";

- (instancetype) mutatedEntry:(NSString*) mutatedKey newValue:(id) value {
    NSMutableDictionary* mutatedKeys = (self.entryKeysStorage ? self.entryKeysStorage.mutableCopy : NSMutableDictionary.new);
    mutatedKeys[mutatedKey] = value;
    
    return [self.class soupEntryWithKeys:mutatedKeys];
}

- (instancetype) mutatedEntry:(NSDictionary*) mutatedValues {
    NSMutableDictionary* mutatedKeys = (self.entryKeysStorage ? self.entryKeysStorage.mutableCopy : NSMutableDictionary.new);
    for (id key in mutatedValues.allKeys) {
        mutatedKeys[key] = mutatedValues[key];
    }
    mutatedKeys[ILSoupEntryAncestorKey] = self.entryHash;
    mutatedKeys[ILSoupEntryMutationDate] = NSDate.date;
    
    return [self.class soupEntryWithKeys:mutatedKeys];
}

// MARK: - Ancestry

- (NSString*) ancestorEntryHash {
    return self.entryKeys[ILSoupEntryAncestorKey];
}

// MARK: - Dynamic Properties

/*! @return the method signature for a given selector, if it's not already defined then generate a generic get or set signature */
- (NSMethodSignature*) methodSignatureForSelector:(SEL)selector {
    NSMethodSignature* signature = nil;
    if ([self respondsToSelector:selector]) {
        signature = [NSMethodSignature methodSignatureForSelector:selector];
    }
    else {
        NSString *sel = NSStringFromSelector(selector);
        if ([sel rangeOfString:@"set"].location == 0) {
            signature = [NSMethodSignature signatureWithObjCTypes:"v@:@"];
        } else {
            signature = [NSMethodSignature signatureWithObjCTypes:"@@:"];
        }
    }
    
    return signature;
}

/*! @brief check for `set` invocations and attempt to copy or record the presented object into */
- (void)forwardInvocation:(NSInvocation *)invocation {
    NSString *key = NSStringFromSelector(invocation.selector);
    if ([key rangeOfString:@"set"].location == 0
     && invocation.methodSignature.numberOfArguments == 1) { // setter
        key = [key substringWithRange:NSMakeRange(3, (key.length - 4))].lowercaseString;
        if (key) {
            id obj;
            [invocation getArgument:&obj atIndex:2];
            if (obj) {
                if ([obj conformsToProtocol:@protocol(NSCopying)]) { // make an immutable copy
                    obj = [obj copy];
                }
                else { // if we can't copy, NSInvocation needs to retain the argument for us
                    [invocation retainArguments];
                }

                [self.entryKeysMutations setObject:obj forKey:key];
            }
            else {
                [self.entryKeysMutations removeObjectForKey:key];
            }
        }
    }
    else if (invocation.methodSignature.numberOfArguments == 0) { // implied getter
        NSString *obj = [self.entryKeysMutations objectForKey:key];
        if (obj) {
            [invocation setReturnValue:&obj];
        }
    }
}

// MARK: - Mutations

- (NSDictionary*) propertyMutations {
    return [NSDictionary dictionaryWithDictionary:self.entryKeysMutations];
}

- (instancetype) entryWithPropertyMutations {
    return [self mutatedEntry:self.entryKeysMutations];
}

// MARK: - NSObject

- (NSString*) description {
    return [NSString stringWithFormat:@"%@ %@ %@ ~ %@", self.class, self.entryHash, self.entryKeys, self.entryKeysMutations];
}

@end
