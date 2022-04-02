@import Soup;

static NSString* const ILName = @"name";
static NSString* const ILEmail = @"email";
static NSString* const ILPhone = @"phone";
static NSString* const ILURL = @"url";
static NSString* const ILNotes = @"notes";
static NSString* const ILBirthday = @"birthday";
static NSString* const ILParents = @"parents";

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        // create a file/memory union soup
        ILUnionSoup* soup = ILUnionSoup.new;
        ILMemorySoup* memory = [ILMemorySoup makeSoup:@"Address Book"];
        ILFileSoup* files = [ILFileSoup fileSoupAtPath:@"~/Desktop/AddressBook.soup"];
        [soup addSoup:files];
        [soup addSoup:memory];

        // setup memory soup
        memory.soupDescription = @"Address Book Example Soup";
        [memory createIdentityIndex:ILSoupEntryIdentityUUID];
        [memory createIndex:ILSoupEntryAncestorEntryHash];
        [memory createIndex:ILSoupEntryDataHash];
        [memory createDateIndex:ILSoupEntryCreationDate];
        [memory createDateIndex:ILSoupEntryMutationDate];
        [memory createTextIndex:ILName];
        [memory createTextIndex:ILEmail];
        [memory createTextIndex:ILNotes];
        
        // add some entries to the union
        [soup addEntry:[memory.createBlankEntry mutatedEntry:@{
            ILName:  @"iStumbler Labs",
            ILEmail: @"support@istumbler.net",
            ILURL:   [NSURL URLWithString:@"https://istumbler.net/labs"],
            ILPhone: @"415-449-0905"
        }]];

        [soup addEntry:[memory.createBlankEntry mutatedEntry:@{
            ILName:  @"John Doe",
            ILEmail: @"j.doe@example.com"
        }]];

        [soup addEntry:[memory.createBlankEntry mutatedEntry:@{
            ILName:  @"Jane Doe",
            ILEmail: @"jane.d@example.com"
        }]];

        NSString* kimAlias = [soup addEntry:[memory.createBlankEntry mutatedEntry:@{
            ILName:  @"Kim Gru",
            ILEmail: @"kim.g@example.com"
        }]];
        NSUUID* kimUUID = [soup gotoAlias:kimAlias].entryKeys[ILSoupEntryIdentityUUID];
        
        NSString* samAlias = [soup addEntry:[memory.createBlankEntry mutatedEntry:@{
            ILName:  @"Sam Liu",
            ILEmail: @"sam.l@example.com"
        }]];
        NSUUID* samUUID = [soup gotoAlias:samAlias].entryKeys[ILSoupEntryIdentityUUID];

        [soup addEntry:[memory.createBlankEntry mutatedEntry:@{
            ILName: @"Fin Gru-Liu",
            ILEmail: @"fin.gl@example.com",
            ILBirthday: NSDate.date,
            ILParents: @[kimUUID, samUUID]
        }]];

        NSLog(@"%@", memory);
        
        [memory resetCursor];
        id<ILSoupEntry> entry = nil;
        while ((entry = [memory.cursor nextEntry])) {
            NSLog(@"entry: %@", entry);
        }
        
        NSLog(@"memory cursor: %@", memory.cursor);
        
        id<ILSoupCursor> does = [[memory queryTextIndex:ILName] entriesWithStringValueMatching:@".* Doe"];
        while ((entry = does.nextEntry)) {
            NSLog(@"doe %lu: %@", does.index, entry);
        }
        
        [files resetCursor];
        id<ILSoupCursor> fileItems = files.cursor;
        
        NSLog(@"file items: %@", fileItems);
        
        while ((entry = [fileItems nextEntry])) {
            NSLog(@"file %lu: %@", fileItems.index, entry);
        }
    }
    return 0;
}
