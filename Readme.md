
= Soup

A persistance framework modeled on the Apple Newton API


== Newton Soup History

    http://en.m.wikipedia.org/wiki/Soup_(Apple_Newton)

    http://www.canicula.com/newton/prog/soups.htm

    Unlike traditional operating systems such as the MacOS and Windows NT there is
    no file system and therefore no files in the Newton Operating Sytystem. Data is
    instead stored in opaque collections like a database in entities known as soups.

    Each entry in a soup can be likened to a record in a database and each data member
    in an entry (known as a slot) can be likened to a field in a database. Unlike 
    database records entries in a soup do not all have to have the same slots. 

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
    
    So that you don't have to worry about which store your soup is on you can use a type
    of soup known as a union soup in your application. This is a system maintained virtual
    soup that is made up of all entries from a particular named soup no matter where the 
    entries are physically stored. 
    
    For Example - if you have two soups named "Match Results" (one on the internal store 
    and one on an external store) to hold results of football matches you can treat them 
    as one big soup containing all the entries by using a union soup. Union soups take 
    into account any choices you make for default storage location and add new entries to 
    a union soup in the member soup which resides on your default store.


== Why Soup Now?

Soup was designed for dealing with storage on a mobile device where storage is transient.  This model is useful
for modern mobile devcies, particlary when they move between offline and connected states due to network 
availability. While most database focus on large data set performance or suitabiilty for high demand online 
production loads, few are optimized for the mobile use case, and fewer take the realaties of modern 
networking into account.

Soup brings back the simplicity and clarity of the Newton Soup API, adds modern conveniances  


=== Simplicity of Design

Soups clear, simple design makes it easy to understand and to quickly intergrate int apps.


=== Optimized for Presentaion

Soup has features which make it a pleasure to work with when building User interfaces


=== Connected and Disconnected

The ability to build union soups and for entreis to be adoped from one soup to another allows for the flexability to
have local, online, and peer soups which are merged into a single data source for an applicaiton to present to the user.


== Soup Protocols

The Soup framework consists of the following protocols:

- ILSoup — ILSoup is the peer of the newtSoup proto
    - ILSoupDelegate — recieves messages when the soup performs operations or encouters errors
- ILSoupEntry — basic data storage unit in a soup
    - ILSoupMutableEntry — allows for mutation of elements
- ILSoupIndex — fast access to soup entries by property index
    - ILSoupCursor — index operations return cursors, which contain a list of entries
- ILSoupSequence — fast access to time sequence datat for numeric properties of entries
    - ILSoupSequceSource — Impedence match with SparkKit

== Soup Stock

Stock in-memory implemenatilns of the Soup Protocols

- ILSoupStock
- ILSoupStockEntry
    - ILSoupStockMutableEntry
- ILSoupStockIndex 
    - ILSoupStockCursor
- ILSoupStockSequence 
    - ILSoupStockSequenceSource

== Soup Flavors

The Soup framework includes a few pre-made flavors which you may find useful in your applications

- ILMemorySoup — in-memory soup made with Stock ingredients
- ILFileSoup — file-system based soup, entries are written to files
- ILSynchSoup — synchronized access to a soup, so that it can safely be mutated across multiple threads
- ILUnionSoup — Combines several soups into a single virutal store
    - ILUnionSoupDelegate — Delegate messages relating to the soup

== TODO Flavors

- ILRemoteSoup — fetches soup contents from a remote source
- ILQueuedSoup — performs all queue opertaions on a serial background queue, and all delegate callbacks on a specified serial queue 

== Example: Address Book

    ILMemorySoup* memory = [ILMemorySoup new];
    memory.soupName = @"Address Book";
    [memory createIndex:@"name"];
    [memory createIndex:@"email"];
    [memory createIndex:@"phone"];
    [memory createIndex:@"url"];
    [memory createIndex:@"birthday"];
    
    NSLog(@"Create Address Book: %@ %@\n%@", memory.soupName, memory.soupUUID, memory.soupIndicis);
    
    ILSoupEntry* entry = [memory createBlankEntry];
    
    
