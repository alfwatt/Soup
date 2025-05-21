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
        id<ILSoupIndex> index = [soup indexForPath:matchKeyPath];
        if (index) {
            // check to see if the map has a different ILSoupSnapshotStorage path
            id value = [object valueForKeyPath:matchKeyPath];
            id<ILSoupCursor> itemCursor = [index entriesWithValue:value];
            if (itemCursor.count == 1) {
                snapEntry = [itemCursor entryAtIndex:0].mutableCopy;
            }
            // ???: warn or error if multiple items match?
        }
    }

    NSMutableDictionary* objectValues = NSMutableDictionary.new;

    // loop through ILSoupSnapshotProperties
    for (NSString* keyPath in [self.snapshotMap[ILSoupSnapshotProperties] allKeys]) {
        NSDictionary* keyMap = self.snapshotMap[ILSoupSnapshotProperties][keyPath];
        id value = [object valueForKeyPath:keyPath];

        // check to see if there is a storage key we need to use
        NSString* storageKey = (keyMap[ILSoupSnapshotStorageKeyPath] ?: keyPath);

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

    // mutate the found or new blank entry
    snapEntry = [(snapEntry ?: [soup createBlankEntry]) mutatedEntry:objectValues];
    [soup addEntry:snapEntry];
    
    return snapEntry;
}

- (nullable id<ILSoupEntry>) snapshot:(NSObject*) object {
    NSLog(@"snapshot: %@", object);
    return nil;
}

- (nullable id<ILSoupEntry>) snapshot {
    NSLog(@"snapshot: %@", self);
    return nil;
}

@end

NS_ASSUME_NONNULL_END
