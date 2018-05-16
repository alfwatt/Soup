#import <Soup/Soup.h>

static NSString* const ILName = @"name";
static NSString* const ILEmail = @"email";
static NSString* const ILPhone = @"phone";
static NSString* const ILURL = @"url";
static NSString* const ILNotes = @"notes";

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        ILMemorySoup* memory = [ILMemorySoup makeSoup:@"Address Book"];
        memory.soupDescription = @"Example Address Book Soup";
        [memory createIndex:ILSoupEntryAncestorKey];
        [memory createDateIndex:ILSoupEntryCreationDate];
        [memory createDateIndex:ILSoupEntryMutationDate];
        [memory createTextIndex:ILName];
        [memory createIndex:ILEmail];
        [memory createIndex:ILPhone];
        [memory createIndex:ILURL];
        [memory createTextIndex:ILNotes];
        
        [memory addEntry:[[memory createBlankEntry] mutatedEntry:@{
            ILName:  @"iStumbler Labs",
            ILEmail: @"support@istumbler.net",
            ILURL:   @"https://istumbler.net/labs",
            ILPhone: @"415-449-0905"
        }]];

        [memory addEntry:[[memory createBlankEntry] mutatedEntry:@{
            ILName:  @"John Doe",
            ILEmail: @"j.doe@example.com"
        }]];

        [memory addEntry:[[memory createBlankEntry] mutatedEntry:@{
            ILName:  @"Jane Doe",
            ILEmail: @"jane.d@example.com"
        }]];

        NSLog(@"%@", memory);
        [memory setupCursor];
        id<ILSoupEntry> entry = nil;
        while ((entry = [[memory getCursor] nextEntry])) {
            NSLog(@"entry: %@", entry);
        }
        NSLog(@"cursor: %@", [memory getCursor]);
        
        id<ILSoupCursor> does = [[memory queryTextIndex:ILName] entriesWithStringValueMatching:@".* Doe"];
        while ((entry = [does nextEntry])) {
            NSLog(@"doe %lu: %@", does.index, entry);
        }
    }
    return 0;
}
