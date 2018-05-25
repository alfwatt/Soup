#import "ILFileSoup.h"
#import "ILSoupStock.h"
#import "ILStockEntry.h"
#import "ILStockIndex.h"
#import "ILStockSequence.h"

@interface ILFileIndex : ILStockIndex

@end

#pragma mark -

@interface ILFileCursor : ILStockCursor

+ (instancetype) fileCursorWithPaths:(NSArray*) filePaths;

@end

#pragma mark -

@interface ILFileSequence : ILStockSequence

@end


@interface ILFileSoup ()
@property(nonatomic, retain) NSString* filePathStorage;

- (instancetype) initWithFilePath:(NSString*) filePath;

@end

#pragma mark -

@implementation ILFileSoup

+ (ILFileSoup*) fileSoupAtPath:(NSString*) filePath
{
    return [[ILFileSoup alloc] initWithFilePath:filePath];
}

#pragma mark -

- (instancetype) initWithFilePath:(NSString*) filePath;
{
    if (self = [super init]) {
        self.filePathStorage = filePath;
        self.soupName = filePath.lastPathComponent;
    }
    
    return self;
}

#pragma mark -

- (NSString*) pathForEntryHash:(NSString*) entryHash
{
    return [[self.filePathStorage stringByAppendingPathComponent:@"entries"] stringByAppendingPathComponent:entryHash];
}

- (NSString*) pathForIndex:(NSString*) indexPath
{
    return [[self.filePathStorage stringByAppendingPathComponent:@"indicies"] stringByAppendingPathComponent:indexPath];
}

- (NSString*) pathForSequence:(NSString*) sequencePath
{
    return [[self.filePathStorage stringByAppendingPathComponent:@"sequences"] stringByAppendingPathComponent:sequencePath];
}

#pragma mark -

- (NSString*) filePath
{
    return self.filePathStorage;
}

#pragma mark -

- (NSString*)addEntry:(id<ILSoupEntry>)entry
{
    NSMutableDictionary* jsonKeys = [NSMutableDictionary new];
    
    for (NSString* key in entry.entryKeys.allKeys) {
        id value = entry.entryKeys[key];
        
        // TODO convert other value types (URL, Image, etc)
        // if ([value isKindOfClass:[NSString class]]
        // || [value isKindOfClass:[NSNumber class]]) {
        // } else
        if ([value isKindOfClass:[NSDate class]]) { // convert to a number
            jsonKeys[key] = @([value timeIntervalSinceReferenceDate]);
        }
        else if ([value isKindOfClass:[NSURL class]]) { // convert to a number
            jsonKeys[key] = [value absoluteString];
        }
        else {
            jsonKeys[key] = value;
        }
    }

    NSString* entryPath = [[self pathForEntryHash:entry.entryHash] stringByExpandingTildeInPath];
    NSString* entriesDir = [entryPath stringByDeletingLastPathComponent];
    [[NSFileManager defaultManager] createDirectoryAtPath:entriesDir withIntermediateDirectories:YES attributes:nil error:nil];
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

#pragma mark - Aliases

- (id<ILSoupEntry>)gotoAlias:(NSString*)alias
{
    NSString* entryPath = [self pathForEntryHash:alias];
    NSInputStream* fileStream = [NSInputStream inputStreamWithFileAtPath:entryPath];
    NSDictionary* entryKeys = [NSJSONSerialization JSONObjectWithStream:fileStream options:0 error:nil];
    [fileStream close];
    
    ILStockEntry* stockEntry = [ILStockEntry soupEntryFromKeys:entryKeys];

    return stockEntry;
}

#pragma mark - Queries

- (id<ILSoupCursor>)querySoup:(NSPredicate *)query
{
    return nil;
}

#pragma mark - Indicies

- (void) loadIndex:(NSString*) indexPath index:(id<ILSoupIndex>) stockIndex
{
}

#pragma mark - Cursor

- (id<ILSoupCursor>)setupCursor
{
    NSArray* soupEntries = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:[self.filePathStorage stringByAppendingPathComponent:@"entries"] error:nil];
    // ILFileCursor* fileCursor = [ILFileCursor fileCursorWithEntries:soupEntries];
    
    return nil;
}

#pragma mark - Sequences

- (id<ILSoupSequence>)createSequence:(NSString*)sequencePath
{
    return nil;
}

#pragma mark - NSObject

- (NSString*) description
{
    return [NSString stringWithFormat:@"%@: \"%@\" %@ %@ %@\nindicies:\n%@\nsequences:\n%@",
            self.className, self.soupName, self.soupDescription, self.soupUUID, self.filePath,
            self.soupIndicies, self.soupSequences];
}

@end
