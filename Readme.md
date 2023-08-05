<a id="soup"></a>
# Soup

<img src="Artwork/Soup-Logo.png" width="256" height="256" style="margin:2em; float: right;">

An object oriented persistance framework from [iStumbler Labs](https://istumbler.net/labs) 
modeled on the [Apple Newton](https://en.wikipedia.org/wiki/Apple_Newton) API.

<a id="links"></a>
## Getting Soup

Soup on [GitHub](https://github.com/alfwatt/Soup), 
[GitLab](https://gitlab.com/alfwatt/Soup)

 <!-- Currently Disabled: Circle CI Build:  [![CircleCI](https://circleci.com/gh/alfwatt/Soup.svg?style=svg)](https://circleci.com/gh/alfwatt/Soup) -->

<a id="support"></a>
## Support Soup!

Are you using Soup.framework in your apps? Would you like to help support the project and get a sponsor credit?

Visit the [iStumbler Labs Patreon Page](https://www.patreon.com/istumblerlabs) and patronize us in exchange for totally adequite rewards!

<a id="contents"></a>
## Contents

- [History](#history)
- [Why Soup?](#whyyyy)
- [Protocols](#protocols)
- [Stock](#stock)
- [Flavors](#flavors)
- [Examples](#examples)
- [MIT License](#license)

<a id="history"></a>
## Newton Soup History

    Unlike traditional operating systems such as the MacOS and Windows NT there is
    no file system and therefore no files in the Newton Operating Sytystem. Data is
    instead stored in opaque collections like a database in entities known as soups.

    Each entry in a soup can be likened to a record in a database and each data member
    in an entry (known as a slot) can be likened to a field in a database. Unlike database
    records entries in a soup do not all have to have the same slots.

    To retrieve data entries from the soups you don't access them directly but rather
    send queries to the soups which return cursor objects. You then use the cursor
    object to get copies of individual entries in the soup. You can then do whatever
    you want with the copies. The original entries in the soups are not modified unless
    you overwrite them with your changed copy.

    The actual soups themselves are held on the Newton in stores. Every Newton device
    has at least one store (the internal store) but they can also have other external
    stores on PCMCIA cards. On a Newton MessagePad 130 there can be one external store
    as there is one PCMCIA slot. Other devices such as the MessagePad 2000 which has
    two PCMCIA slots can have more external stores.

    So that you don't have to worry about which store your soup is on you can use a
    type of soup known as a union soup in your application. This is a system maintained
    virtual soup that is made up of all entries from a particular named soup no matter
    where the entries are physically stored.

    For Example - if you have two soups named "Match Results" (one on the internal store
    and one on an external store) to hold results of football matches you can treat them
    as one big soup containing all the entries by using a union soup. Union soups take
    into account any choices you make for default storage location and add new entries to
    a union soup in the member soup which resides on your default store.

- [Ian Robinson](https://web.archive.org/web/20060210184323/http://www.canicula.com/newton/prog/soups.htm)

[Newton Soup (Wikipedia)](http://en.m.wikipedia.org/wiki/Soup_(Apple_Newton))


<a id="whyyyy"></a>
## Why Soup?

Soup was designed for dealing with storage on a mobile device where storage is transient.
This model is useful for modern mobile devcies, particlary when they move between offline
and connected states due to network availability. While most database focus on large data
set performance or suitabiilty for high demand online production loads, few are optimized
for the mobile use case, and fewer take the realaties of mobile networking into account.

Soup brings back the simplicity and clarity of the Newton Soup API, adds modern conveniances
and provides an interface tuned for developing user-facing data sets with flexable indexing
and storage.

### Simple Design, Small Footprint

Soups clear, simple design makes it easy to understand and to quickly intergrate into apps. 
The whole framework is less than 1MB!

### Optimized for Presentaion

Soup has features which make it a pleasure to work with when building User interfaces.

Soup entires and cursors are immutable, but you can easily create copies with mutations
and automaticallly maintain a hitory of edits, making undo operations easy to implement
and preventing errors resulting from mutating objects as they are displayed.

### Connected and Disconnected

The ability to build union soups and for entries to be adoped from one soup to another
allows for the flexability to have local, online, and peer soups which are merged into
a single data source for an applicaiton to present to the user.

<a id="protocols"></a>
## Soup Protocols

The Soup framework consists of the following protocols:

- [ILSoup](Protocols/ILSoup.h)  — ILSoup is the peer of the newtSoup proto
    - [ILSoupDelegate](Protocols/ILSoup.h#ILSoupDelegate) — recieves messages when the soup performs operations or encouters errors
- [ILSoupEntry](Protocols/ILSoup.h) — basic data storage unit in a soup
    - [ILMutableSoupEntry](Protocols/ILSoup.h#ILMutableSoupEntry) — allows for mutation of elements
- [ILSoupIndex](Protocols/ILSoupIndex.h) — fast access to soup entries by property index
    - [ILSoupCursor](Protocols/ILSoupIndex.h#ILSoupCursor) — index operations return cursors, which contain a list of entries
    - [ILSoupIdentityIndex](Protocols/ILSoupIndex.h#ILSoupIdentityIndex)
    - [ILSoupTextIndex](Protocols/ILSoupIndex.h#ILSoupTextIndex) — index which can be queried for text
    - [ILSoupDateIndex](Protocols/ILSoupIndex.h#ILSoupDateIndex) — index which can be queried for dates and ranges
    - [ILSoupNumberIndex](Protocols/ILSoupIndex.h#ILSoupNumberIndex) — index which can be queried for numbers and ranges
- [ILSoupSequence](Protocols/ILSoupSequence.h) — fast access to time sequence data for numeric properties of entries
    - [ILSoupSequceSource](Protocols/ILSoupSequence.h#ILSoupSequceSource) — Impedence match with [SparkKit]()

<a id="stock"></a>
## Soup Stock

Stock in-memory implementations of the Soup Protocols

- [ILSoupStock](Stock/ILSoupStock.h) [.m](Stock/ILSoupStock.m)
- [ILStockEntry](Stock/ILStockEntry.h) [.m](Stock/ILStockEntry.m)
    - ILMutableStockEntry
- [ILStockIndex](Stock/ILStockIndex.h) [.m](Stock/ILStockIndex.m)
    - ILStockCursor
    - ILStockIdentityIndex
    - ILStockTextIndex
    - ILStockDateIndex
    - ILStockNumberIndex
- [ILStockSequence](Stock/ILStockSequence.h) [.m](Stock/ILStockSequence.m)
    - ILStockSequenceSource 

<a id="flavors"></a>
## Soup Flavors

The Soup framework includes a few pre-made flavors which you may find useful
in your applications.

- [ILFileSoup](Flavors/ILFileSoup.h) — file-system based soup, entries are written to files
- [ILMemorySoup](Flavors/ILMemorySoup.h) — in-memory soup made with Stock ingredients
- [ILQueuedSoup](Flavors/ILQueuedSoup.h) — performs all queue and delegate operations on serial background queues
- [ILSynchedSoup](Flavors/ILSynchedSoup.h) — synchronized access to a soup, so that it can safely be mutated across multiple threads
- [ILUnionSoup](Flavors/ILUnionSoup.h) — Combines several soups into a single virutal store
    - ILUnionSoupDelegate — Delegate messages relating to the soup

<a id="example"></a>
## Example: Address Book


    // define some keys for our address book
    static NSString* const ILName = @"name";
    static NSString* const ILEmail = @"email";
    static NSString* const ILNotes = @"notes";

    // create a stock memory soup
    ILMemorySoup* memory = [ILMemorySoup makeSoup:@"Address Book"];

    // prep the soup with some default indexes
    memory.soupDescription = @"Address Book Example Soup";
    [memory createIndex:ILSoupEntryAncestorEntryHash];
    [memory createDateIndex:ILSoupEntryCreationDate];
    [memory createDateIndex:ILSoupEntryMutationDate];
    [memory createTextIndex:ILName];
    [memory createTextIndex:ILEmail];
    [memory createTextIndex:ILNotes];
    
    // add some entries to the union
    [memory addEntry:[[memory createBlankEntry] mutatedEntry:@{
        ILName:  @"John Doe",
        ILEmail: @"j.doe@example.com"
    }]];

    [memory addEntry:[[memory createBlankEntry] mutatedEntry:@{
        ILName:  @"Jane Gru",
        ILEmail: @"jane.g@example.com"
    }]];

    // print out all entries
    NSLog(@"%@", memory);
    id<ILSoupEntry> entry = nil;
    while ((entry = [memory.cursor nextEntry])) {
        NSLog(@"entry: %@", entry);
    }
    
    // search for does
    id<ILSoupCursor> does = [[memory queryTextIndex:ILName] entriesWithStringValueMatching:@".* Doe"];
    while ((entry = [does nextEntry])) {
        NSLog(@"doe %lu: %@", does.index, entry);
    }

<a href="Examples/addresses/main.m">Example Code</a>

## Dynamic Properties

Much like other data handlig frameworks, support is provided for custom model classes
using dynamic properties. For e.g. in Swift we can define a class with dynamic properties easily:

    // AddressBookEntry.swift
    //
    final class AddressBookEntry: ILStockEntry {
        dynamic var entryName: String? = nil
        dynamic var entryEmail: String? = nil
        dynamic var entryPhone: String? = nil
        dynamic var entryURL: URL? = nil
        dynamic var entryNotes: String? = nil
        dynamic var entryBirthday: Date? = nil
        dynamic var entryParents: Array<String>? = nil
        dynamic var entrySpouse: String? = nil
    }

Doing so in Objective-C is slightly more verbose:

    // AddressBookEntry.h
    //
    @interface AddressBookEntry : ILStockEntry
    @property(nonatomic,retain) NSString* entryName;
    @property(nonatomic,retain) NSString* entryEmail;
    @property(nonatomic,retain) NSString* entryPhone;
    @property(nonatomic,retain) NSURL* entryURL;
    @property(nonatomic,retain) NSString* entryNotes;
    @property(nonatomic,retain) NSDate* entryBirthday;
    @property(nonatomic,retain) NSArray<NSString*>* entryParents;
    @property(nonatimic,retain) NSString* entrySpouse;
    @end
    
    // AddressBookEntry.m
    //
    @implementation AddressBookEntry
    @dynamic entryName;
    @dynamic entryEmail;
    @dynamic entryPhone;
    @dynamic entryURL;
    @dynamic entryNotes;
    @dynamic entryBirthday;
    @dynamic entryParents;
    @dynamic entrySpouse;
    @end


<a id="license"></a>
## License

    The MIT License (MIT)

    Copyright © 2019-2022 Alf Watt

    Permission is hereby granted, free of charge, to any person obtaining a copy
    of this software and associated documentation files (the "Software"), to deal
    in the Software without restriction, including without limitation the rights
    to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
    copies of the Software, and to permit persons to whom the Software is
    furnished to do so, subject to the following conditions:

    The above copyright notice and this permission notice shall be included in all
    copies or substantial portions of the Software.

    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
    IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
    FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
    AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
    LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
    OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
    SOFTWARE.

