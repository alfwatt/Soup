#import <Foundation/Foundation.h>

#import "ILSoupSnapshot.h"
#import "ILSoup.h"
#import "ILSoupEntry.h"
#import "ILSoupIndex.h"

NS_ASSUME_NONNULL_BEGIN

/*

Snapshot map for NSDate

{
    "Properties": {
        "timeIntervalSince1970": {
            "Storage": "secondsSinceEpoch",
            "ValueTransformer": "ILSoupDateValueTransformer",
        }
    },
    "MatchKeyPath": "timeIntervalSince1970" -- doesn't work for NSDate, since it's immutable
}

*/

@interface ILSoupSnapshot ()

@property(nonatomic,retain) NSDictionary* snapshotMap;

@end

// MARK: -

@implementation ILSoupSnapshot

- (instancetype) initWithMap:(NSDictionary*) snapshotMap {
    if ((self = [super init])) {
        self.snapshotMap = snapshotMap;
    }

    return self;
}

// MARK: -

- (nullable id<ILSoupEntry>) snapshot:(NSObject*) object inSoup:(id<ILSoup>) soup {
    id<ILMutableSoupEntry> snapEntry = nil;

    // if the map has ILSoupSnapshotMatchKeyPaths try to find an existing item
    NSString* matchKeyPath = self.snapshotMap[ILSoupSnapshotMatchKeyPath];
    if (matchKeyPath) {
        id<ILSoupIdentityIndex> index = [soup queryIdentityIndex:matchKeyPath];
        if (index) {
            // check to see if the map has a different ILSoupSnapshotStorage path
            id value = [object valueForKeyPath:matchKeyPath];
            snapEntry = [index entryWithValue:value].mutableCopy;
        }
    }

    NSMutableDictionary* objectValues = NSMutableDictionary.new;

    // loop through ILSoupSnapshotProperties
    for (NSString* keyPath in [self.snapshotMap[ILSoupSnapshotProperties] allKeys]) {
        NSDictionary* keyMap = self.snapshotMap[ILSoupSnapshotProperties][keyPath];
        id value = [object valueForKeyPath:keyPath];

        // check to see if there is a storage key we need to use
        NSString* storageKey = (keyMap[ILSoupSnapshotStorageKey] ?: keyPath);

        // check for a value trasformer
        NSString* valueTransformerName = keyMap[ILSoupSnapshotValueTransformer];
        if (valueTransformerName) {
            NSValueTransformer* valueTransformer = [NSValueTransformer valueTransformerForName:valueTransformerName];
            if (valueTransformer) {
                value = [valueTransformer transformedValue:value];
            }
        }

        objectValues[storageKey] = value;
    }

    // check for a custom class name in the map
    NSString* entryClassName = self.snapshotMap[ILSoupEntryClassName];
    Class entryClass = nil;
    if (entryClassName && (entryClass = NSClassFromString(entryClassName))) { // initilize the class specified
        snapEntry = [soup createBlankEntryOfClass:entryClass];
    }
    else {
        snapEntry = [soup createBlankEntry];
    }

    // mutate the found or new blank entry
    id<ILSoupEntry> mutatedEntry = [snapEntry mutatedEntry:objectValues];
    [soup addEntry:mutatedEntry];

    return mutatedEntry;
}

@end

NS_ASSUME_NONNULL_END
