#import <Foundation/Foundation.h>
#import <Soup/Soup.h>

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        ILMemorySoup* memory = [ILMemorySoup makeSoup:@"Address Book"];
        memory.soupDescription = @"Example Address Book Soup";
        [memory createIndex:@"name"];
        [memory createIndex:@"email"];
        [memory createIndex:@"phone"];
        [memory createIndex:@"url"];
        [memory createSequence:@"weight"];

        memory.defaultEntry = @{
            @"name":  @"",
            @"email": @"",
            @"phone": @"",
            @"url":   @""
        };
        
        id<ILMutableSoupEntry> newEntry = [[memory createBlankEntry] mutatedEntry:@{
            @"name":  @"Alf Watt",
            @"email": @"alf@istumbler.net",
            @"phone": @"415-449-0905",
            @"url":   @"https://istumbler.net/labs/",
            @"weight": @"100"
        }];
        
        id<ILMutableSoupEntry> nextEntry = [[memory createBlankEntry] mutatedEntry:@{
            @"name":  @"iStumbler Labs",
            @"email": @"support@istumbler.net",
            @"url":   @"https://istumbler.net",
            @"weight": @(100)
        }];
    
        [memory addEntry:newEntry];
        [memory addEntry:nextEntry];

        NSLog(@"%@", memory);
    }
    return 0;
}
