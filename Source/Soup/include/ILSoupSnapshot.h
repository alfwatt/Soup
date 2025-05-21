#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/// Propertes to map when an object is snapped
static NSString* const ILSoupSnapshotProperties = @"Properties";

/// Specify a key to use for storing the property in the soup entry, defaults the the key path
static NSString* const ILSoupSnapshotStorageKeyPath = @"StorageKeyPath";

/// Specify a transformer to use when storing the property in the soup entry
static NSString* const ILSoupSnapshotValueTransformer = @"ValueTransformer";

/// key path to search in the soup for an existing version of the object
static NSString* const ILSoupSnapshotMatchKeyPath = @"MatchKeyPath";

// MARK: -

@protocol ILSoup;
@protocol ILSoupEntry;

@interface ILSoupSnapshot : NSObject

- (instancetype) initWithMap:(NSDictionary*) snapshotMap;

// MARK: -

- (nullable id<ILSoupEntry>) snapshot:(NSObject*) object inSoup:(NSObject<ILSoup>*) soup NS_SWIFT_NAME(snapshot(_:in:));

- (nullable id<ILSoupEntry>) snapshot:(NSObject*) object;

- (nullable id<ILSoupEntry>) snapshot;

@end

NS_ASSUME_NONNULL_END
