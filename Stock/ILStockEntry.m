#import "ILStockEntry.h"
#import "NSDictionary+Hashcodes.h"
#import <objc/runtime.h>

NS_ASSUME_NONNULL_BEGIN

@interface ILStockEntry ()
@property(nonatomic,retain) NSDictionary<NSString*, id>* entryKeysStorage;
@property(nonatomic,retain) NSMutableDictionary* entryKeysMutations;

- (instancetype) initWithKeys:(NSDictionary<NSString*, id>*) entryKeys;

@end

// MARK: - Dynamic Getter and Setter

void* accessorGetter(id self, SEL _cmd)
{
    NSString* key = NSStringFromSelector(_cmd);
    NSObject* value = [(ILStockEntry*)self valueForKey:key];
    void* returnValue = NULL;
    char* returnType = NULL;
    if (value) {
        /* TODO we need to check and see if it needs unboxing
        Class dynamicClass = object_getClass(self);
        Method getMethod = class_getInstanceMethod(dynamicClass, _cmd);
        returnType = method_copyReturnType(getMethod);
        */
        returnValue = (__bridge void*) value;
    }
exit:
    if (returnType) free(returnType);
    return returnValue;
}

void accessorSetter(id self, SEL _cmd, id newValue)
{
    NSString *methodName = NSStringFromSelector(_cmd);

    // remove leading 'set' and trailing ':' and lowercase the method name
    NSString *keyName = [methodName substringWithRange:NSMakeRange(3, (methodName.length - 4))];
    // lowercase the first character
    keyName = [[keyName substringWithRange:NSMakeRange(0, 1)].lowercaseString stringByAppendingString:
               [keyName substringWithRange:NSMakeRange(1, (keyName.length - 1))]];

    [(ILStockEntry*)self setValue:newValue forKey:keyName];
}

// MARK: -

@implementation ILStockEntry

+ (instancetype) soupEntryWithKeys:(NSDictionary<NSString*, id>*) entryKeys {
    return [self.alloc initWithKeys:entryKeys];
}

// MARK: - Dynamic Properties

+ (BOOL) resolveInstanceMethod:(SEL)aSEL {
    NSString *method = NSStringFromSelector(aSEL);

    if ([method hasPrefix:@"set"]) {
        class_addMethod([self class], aSEL, (IMP) accessorSetter, "v@:@");
        return YES;
    }
    else if ([method rangeOfString:@":"].location == NSNotFound) { // get method with one
        class_addMethod([self class], aSEL, (IMP) accessorGetter, "@@:");
        return YES;
    }
    return [super resolveInstanceMethod:aSEL];
}

// MARK: - ILSoupStockEntry

- (instancetype) initWithKeys:(NSDictionary<NSString*, id>*) entryKeys {
    if ((self = super.init)) {
        NSMutableDictionary<NSString*, id>* newEntryKeys = (entryKeys ? entryKeys.mutableCopy : NSMutableDictionary.new);
        
        if (![newEntryKeys.allKeys containsObject:ILSoupEntryIdentityUUID]) { // create a new UUID for the entry
            newEntryKeys[ILSoupEntryIdentityUUID] = NSUUID.UUID.UUIDString;
        }
        
        if (![newEntryKeys.allKeys containsObject:ILSoupEntryCreationDate]) { // enter a creation date for the entry
            newEntryKeys[ILSoupEntryCreationDate] = NSDate.date;
        }
        
        if (![newEntryKeys.allKeys containsObject:ILSoupEntryClassName]) { // enter the class name for this instance
            newEntryKeys[ILSoupEntryClassName] = NSStringFromClass(self.class);
        }
        
        NSMutableDictionary* entryDataKeys = newEntryKeys.mutableCopy;
        for (NSString* soupKey in @[ILSoupEntryIdentityUUID, ILSoupEntryCreationDate, ILSoupEntryDataHash,
            ILSoupEntryKeysHash, ILSoupEntryAncestorEntryHash, ILSoupEntryMutationDate]) {
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

- (NSDictionary<NSString*, id>*) entryKeys {
    return self.entryKeysStorage;
}

- (NSArray<NSString*>*) sortedEntryKeys {
    return [self.entryKeys.allKeys sortedArrayUsingSelector:@selector(compare:)];
}

// MARK: - ILMutableSoupEntry

NSString* ILSoupEntryAncestorEntryHash = @"soup.entry.ancestor";
NSString* ILSoupEntryMutationDate = @"soup.entry.mutated";

- (instancetype) mutatedEntry:(NSDictionary*) mutatedValues {
    NSMutableDictionary* mutatedKeys = (self.entryKeysStorage ? self.entryKeysStorage.mutableCopy : NSMutableDictionary.new);
    for (id key in mutatedValues.allKeys) {
        id object = mutatedValues[key];
        if (object == NSNull.null) {
            mutatedKeys[key] = nil;
        }
        else {
            mutatedKeys[key] = object;
        }
    }
    // link the entry to it's ancestor
    mutatedKeys[ILSoupEntryAncestorEntryHash] = self.entryHash;
    // mutation date gurantees a new entryHash, even if all the other data is the same
    mutatedKeys[ILSoupEntryMutationDate] = NSDate.date;
    
    return [self.class soupEntryWithKeys:mutatedKeys];
}

- (instancetype) mutatedCopy:(NSDictionary*) mutatedValues {
    NSMutableDictionary* mutableValues = mutatedValues.mutableCopy;
    // copies need a new UUID
    mutableValues[ILSoupEntryIdentityUUID] = NSUUID.new;
    return [self mutatedEntry:mutableValues];
}

// MARK: - Ancestry

- (NSString*) ancestorEntryHash {
    return self.entryKeys[ILSoupEntryAncestorEntryHash];
}

// XXX: - Dynamic Properties

/*

 This implementation has a sublte over-release bug that I wasn't able to resolve,
 the resolveInstanceMethod: implemenatation above is a simpler and more reliable implementation

*/

/*! @return the method signature for a given selector, if it's not already defined then generate a generic get or set signature
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
 */

/*! @brief check for `set` invocations and attempt to copy or record the presented object into
- (void)forwardInvocation:(NSInvocation *)invocation {
    NSUInteger argc = invocation.methodSignature.numberOfArguments;
    NSString *key = NSStringFromSelector(invocation.selector);
    
    if ([key rangeOfString:@"set"].location == 0 && argc == 3) { // setter
        key = [key substringWithRange:NSMakeRange(3, (key.length - 4))].lowercaseString;
        if (key) {
            id obj;
            [invocation getArgument:&obj atIndex:2];
            if (obj) {
                [invocation retainArguments];
                if ([obj conformsToProtocol:@protocol(NSCopying)]) {
                    obj = [obj copy]; // retain an immutable copy
                }
                else { // we need to retain the arguments
                    [invocation retainArguments];
                }
                // NSLog(@"setting mutated key: %@ obj: %@ ref: %ld", key, obj, (long)CFGetRetainCount((__bridge CFTypeRef)(obj)));
                [self.entryKeysMutations setObject:obj forKey:key];
            }
            else { // set an NSNull value, so we can mask an underyling key
                [self.entryKeysMutations setObject:NSNull.null forKey:key];
            }
        }
    }
    else if (argc == 2) { // implied getter
        id obj = [self.entryKeysMutations objectForKey:key];
        if (obj && obj != NSNull.null) { // hide the NSNull values
            [invocation setReturnValue:&obj];
        }
    }
}
 */

// MARK: - Mutations

- (nullable NSDictionary*) propertyMutations {
    return [NSDictionary dictionaryWithDictionary:self.entryKeysMutations];
}

- (instancetype) entryWithPropertyMutations {
    return [self mutatedEntry:self.entryKeysMutations];
}

// MARK: - NSObject

- (NSString*) description {
    NSString* description = nil;
    if (self.entryKeysMutations.allKeys.count > 0) {
        description = [NSString stringWithFormat:@"%@ %@ %@ ~ %@", self.class, self.entryHash, self.entryKeys, self.entryKeysMutations];
    }
    else {
        description = [NSString stringWithFormat:@"%@ %@ %@", self.class, self.entryHash, self.entryKeys];
    }
    return description;
}

// MARK: - NSKeyValueCoding

- (_Nullable id) valueForKey:(NSString *)key {
    id value = nil;
    
    if (self.entryKeysMutations[key] != nil) {
        value = self.entryKeysMutations[key];
    }
    else {
        value = self.entryKeys[key];
    }
    
    return value;
}

- (void) setValue:(_Nullable id)value forKey:(NSString *)key {
    self.entryKeysMutations[key] = value;
}

@end

NS_ASSUME_NONNULL_END
