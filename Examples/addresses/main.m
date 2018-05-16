#import <Foundation/Foundation.h>
#import <Soup/Soup.h>

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        ILMemorySoup* memory = [ILMemorySoup makeSoup:@"Address Book"];
        memory.soupDescription = @"Example Address Book Soup";
        [memory createIndex:ILSoupEntryAncestorKey];
        [memory createDateIndex:ILSoupEntryCreationDate];
        [memory createDateIndex:ILSoupEntryMutationDate];
        [memory createIndex:@"name"];
        [memory createIndex:@"email"];
        [memory createIndex:@"phone"];
        [memory createIndex:@"url"];
        [memory createTextIndex:@"notes"];

        memory.defaultEntry = @{
            @"name":  @"",
            @"email": @"",
            @"phone": @"",
            @"url":   @""
        };
        
        [memory addEntry:[[memory createBlankEntry] mutatedEntry:@{
            @"name":  @"iStumbler Labs",
            @"email": @"support@istumbler.net",
            @"url":   @"https://istumbler.net/labs",
            @"phone": @"415-449-0905"
        }]];

        [memory addEntry:[[memory createBlankEntry] mutatedEntry:@{
            @"name":  @"John Doe",
            @"email": @"j.doe@example.com",
            @"phone": @"555-555-5555",
            @"url":   @"https://example.com/"
        }]];

        NSLog(@"%@", memory);
        [memory setupCursor];
        id<ILSoupEntry> entry = nil;
        while ((entry = [[memory getCursor] nextEntry])) {
            NSLog(@"entry: %@", entry);
        }
        NSLog(@"cursor: %@", [memory getCursor]);
        
        id<ILSoupCursor> does = [[memory queryIndex:@"name"] entriesWithValue:@"John Doe"];
        while ((entry = [does nextEntry])) {
            NSLog(@"doe: %@", entry);
        }
    }
    return 0;
}
