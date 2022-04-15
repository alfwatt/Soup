#import "ILFileSoup.h"
#import "ILSoupStock.h"
#import "ILStockEntry.h"
#import "ILStockIndex.h"
#import "ILStockSequence.h"

NS_ASSUME_NONNULL_BEGIN

@interface ILFileIndex : ILStockIndex

@end

// MARK: -

@interface ILFileCursor : ILStockCursor

+ (instancetype) fileCursorWithPaths:(NSArray*) filePaths;

@end

// MARK: -

@interface ILFileSequence : ILStockSequence

@end


@interface ILFileSoup ()
@property(nonatomic, retain) NSString* filePathStorage;
@property(nonatomic, retain) id<ILSoupCursor> fileSoupCursor;

- (instancetype) initWithFilePath:(NSString*) filePath;

@end

// MARK: -

@implementation ILFileSoup

+ (ILFileSoup*) fileSoupAtPath:(NSString*) filePath
{
    return [ILFileSoup.alloc initWithFilePath:filePath];
}

// MARK: -

- (instancetype) initWithFilePath:(NSString*) filePath;
{
    if ((self = super.init)) {
        self.filePathStorage = filePath;
        self.soupName = filePath.lastPathComponent;
    }
    
    return self;
}

// MARK: -

- (NSString*) pathForEntryHash:(NSString*) entryHash
{
    return [[self.filePath stringByAppendingPathComponent:@"entries"] stringByAppendingPathComponent:entryHash];
}

- (NSString*) pathForIndex:(NSString*) indexPath
{
    return [[self.filePath stringByAppendingPathComponent:@"indicies"] stringByAppendingPathComponent:indexPath];
}

- (NSString*) pathForSequence:(NSString*) sequencePath
{
    return [[self.filePath stringByAppendingPathComponent:@"sequences"] stringByAppendingPathComponent:sequencePath];
}

// MARK: -

- (NSString*) filePath
{
    return [self.filePathStorage stringByExpandingTildeInPath];
}

// MARK: -

- (NSString*)addEntry:(id<ILSoupEntry>)entry
{
    NSMutableDictionary* jsonKeys = NSMutableDictionary.new;
    
    for (NSString* key in entry.entryKeys.allKeys) {
        id value = entry.entryKeys[key];
        
        // TODO convert other value types (URL, Image, etc)
        // if ([value isKindOfClass:[NSString class]]
        // || [value isKindOfClass:[NSNumber class]]) {
        // } else
        if ([value isKindOfClass:[NSDate class]]) { // convert to a number
            jsonKeys[key] = @([value timeIntervalSinceReferenceDate]);
        }
        else if ([value isKindOfClass:[NSURL class]]) { // convert to a string
            jsonKeys[key] = [value absoluteString];
        }
#if TARGET_OS_MAC
/*
        else if ([value isKindOfClass:[NSImage class]]) { // write to a file in the container
        
        }
*/
#elif TARGET_OS_IPHONE || TARGET_OS_TV
        else if ([value isKindOfClass:UIImage.class]) { // write into a file in the container
            
        }
#endif
        else {
            jsonKeys[key] = value;
        }
    }

    NSString* entryPath = [[self pathForEntryHash:entry.entryHash] stringByAppendingPathComponent:@"entry.json"];
    NSString* entriesDir = [entryPath stringByDeletingLastPathComponent];
    [NSFileManager.defaultManager createDirectoryAtPath:entriesDir withIntermediateDirectories:YES attributes:nil error:nil];
    NSOutputStream* fileStream = [NSOutputStream outputStreamToFileAtPath:entryPath append:NO];
    [fileStream open];
    [NSJSONSerialization writeJSONObject:jsonKeys toStream:fileStream options:(NSJSONWritingPrettyPrinted) error:nil];
    [fileStream close];
    
    [self indexEntry:entry];
    [self setupCursor]; // we changed the entry set
    return entry.entryHash;
}

- (void)deleteEntry:(id<ILSoupEntry>)entry
{
    NSString* entryPath = [self pathForEntryHash:entry.entryHash];
    
    [self removeFromIndicies:entry];
    [self removeFromSequences:entry];
    
    [[NSFileManager defaultManager] removeItemAtPath:entryPath error:nil];

    [self setupCursor]; // we changed the entry set
}

// MARK: - Aliases

- (id<ILSoupEntry>)gotoAlias:(NSString*)alias
{
    NSString* entryPath = [[[self pathForEntryHash:alias] stringByExpandingTildeInPath] stringByAppendingPathComponent:@"entry.json"];
    NSInputStream* fileStream = [NSInputStream inputStreamWithFileAtPath:entryPath];
    [fileStream open];
    NSDictionary<NSString*, id>* entryKeys = [NSJSONSerialization JSONObjectWithStream:fileStream options:0 error:nil];
    [fileStream close];
    
    ILStockEntry* stockEntry = [ILStockEntry soupEntryWithKeys:entryKeys];

    return stockEntry;
}

// MARK: - Queries

- (id<ILSoupCursor>)querySoup:(NSPredicate *)query
{
    return nil;
}

// MARK: - Indicies

- (void) loadIndex:(NSString*) indexPath index:(id<ILSoupIndex>) stockIndex
{
}

// MARK: - Cursor

- (id<ILSoupCursor>)getCursor
{
    return self.fileSoupCursor;
}

- (id<ILSoupCursor>)setupCursor
{
    NSString* entriesPath = [self.filePath stringByAppendingPathComponent:@"entries"];
    NSMutableArray* soupEntries = [NSMutableArray new];
    for (NSString* filePath in [[NSFileManager defaultManager] contentsOfDirectoryAtPath:entriesPath error:nil]) {
        if ([filePath rangeOfString:@"."].location !=0) { // skip the dot files
            [soupEntries addObject:filePath];
        }
    }
    
    self.fileSoupCursor = [[ILStockAliasCursor alloc] initWithAliases:soupEntries inSoup:self];

    return self.fileSoupCursor;
}

// MARK: - Sequences

- (id<ILSoupSequence>)createSequence:(NSString*)sequencePath
{
    return nil;
}

// MARK: - NSObject

- (NSString*) description
{
    return [NSString stringWithFormat:@"%@: \"%@\" %@ %@ %@\nindicies:\n%@\nsequences:\n%@",
            self.class, self.soupName, self.soupDescription, self.soupUUID, self.filePath,
            self.soupIndicies, self.soupSequences];
}

@end

NS_ASSUME_NONNULL_END
