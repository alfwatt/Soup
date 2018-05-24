#import "ILFileSoup.h"
#import "ILSoupStock.h"
#import "ILStockEntry.h"

@interface ILFileSoup ()
@property(nonatomic, retain) NSString* filePathStorage;

@end

#pragma mark -

@implementation ILFileSoup

+ (ILFileSoup*) fileSoupAtPath:(NSString*) filePath
{
    ILFileSoup* fileSoup = [ILFileSoup new];
    fileSoup.filePathStorage = filePath;
    return fileSoup;
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
    NSString* entryPath = [self pathForEntryHash:entry.entryHash];
    NSOutputStream* fileStream = [NSOutputStream outputStreamToFileAtPath:entryPath append:NO];
    [NSJSONSerialization writeJSONObject:entry.entryKeys toStream:fileStream options:0 error:nil];
    [fileStream close];
    
    [self indexEntry:entry];
    return entry.entryHash;
}

- (void)deleteEntry:(id<ILSoupEntry>)entry
{
    NSString* entryPath = [self pathForEntryHash:entry.entryHash];
    [[NSFileManager defaultManager] removeItemAtPath:entryPath error:nil];
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
    return nil;
}

#pragma mark - Sequences

- (id<ILSoupSequence>)createSequence:(NSString *)sequencePath
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
