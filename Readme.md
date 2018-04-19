= Soup

A persistance framework modeled on the Apple Newton API

== Newton Soup History

    http://en.m.wikipedia.org/wiki/Soup_(Apple_Newton)

    http://www.canicula.com/newton/prog/soups.htm

    Unlike traditional operating systems such as the MacOS and Windows NT there is no file system and therefore no files in the Newton Operating Sbtystem. Data is instead stored in opaque collections like a database in entities known as soups. Each entry in a soup can be likened to a record in a database and each data member in an entry (known as a slot) can be likened to a field in a database. Unlike database records entries in a soup do not all have to have the same slots. To retrieve data entries from the soups you don't access them directly but rather send queries to the soups which return cursor objects. You then use the cursor object to get copies of individual entries in the soup. You can then do whatever you want with the copies. The original entries in the soups are not modified unless you overwrite them with your changed copy.

    The actual soups themselves are held on the Newton in stores. Every Newton device has at least one store (the internal store) but they can also have other external stores on PCMCIA cards. On a Newton MessagePad 130 there can be one external store as there is one PCMCIA slot. Other devices such as the MessagePad 2000 which has two PCMCIA slots can have more external stores. So that you don't have to worry about which store your soup is on you can use a type of soup known as a union soup in your application. This is a system maintained virtual soup that is made up of all entries from a particular named soup no matter where the entries are physically stored. For Example - if you have two soups named "Match Results" (one on the internal store and one on an external store) to hold results of football matches you can treat them as one big soup containing all the entries by using a union soup. Union soups take into account any choices you make for default storage location and add new entries to a union soup in the member soup which resides on your default store (see AddToDefaultStoreXmit below).

== Why Soup Now?

Soup was designed for dealing with storage on a mobile device where storage is transient. This model is useful for modern mobile devcies, particlary when they move between offline and connected states due to network availability. While most database focus on large data set performance or suitabiilty for high demand online production loads, few are optimized for the mobile use case, and fewer take the realaties of modern networking into account.

Soup brings back the simplicity and clarity of the Newton Soup API, adds modern conveniances 

=== Simplicity of Design

Soups clear, simple design makes it easy to underdant and intergrate.

=== Optimized for Presentaion

Soup has features which make it a pleasure to work with when building User interfaces

=== Connected and Disconnected

The ability to build union soups and for entreis to be adoped from one soup to another allows for the flexability to have local, online, and peer soups which are merged into a single data source for an applicaiton to present to the user.

== Soup Objects

The Soup framework consists of the following objects:

- ILSoup
- ILSoupDelegate
- ILSoupUnionSoup
- ILUnionSoupDelegate
- ILSSoupEntry
- ILSoupCursor
- ILSoupIndex
- ILSoupSequence

=== ILSoup

ILSoup is the peer of the newtSoup proto

    @interface ILSoup
    @property(retain) NSString* soupName
    @property(retain) NSUUID* soupUUID
    @property(retain) NSArray<ILSoupIndex*>* soupIndicies
    @property(retain) NSPredicate* soupQuery
    @property(retain) NSStirng* soupDescr
    @property(assign) Class defaultDataType
    @property(assing) id<ILSoupDelegate> delegate
    
    + (ILSoup*) makeSoup:(NSString*) appIdentifier
    
    #pragma mark - Entries
    - (void) addEntry:(ILSoupEntry*) entry
    - (void) adoptEntry:(ILSoupEntry*) entry type:(Class) type
    - (ILSoupEntry*) createBlankEntry
    - (void) deleteEntry:(ILSoupEntry*) entry
    - (ILSoupEntry*) duplicateEntry:(ILSoupEntry*) entry
    - (id) getAlias:(ILSoupEntry*) entry // alias or path?
    - (ILSoupEntry*) gotoAlias:(id) alias
    
    #pragma mark - Cursor
    
    - (void) setupCursor() // create or reset cursor after setting soupQuery
    - (ILSoupCursor*) getCursor() // query param?
    - (id) getCursorPosition // alias or path?
    - (ILSoupCursor*) query:(NSPredicate*) query

    #pragma mark - Soup Managment
    
    - (void) doneWithSoup:(NSString*) appIdentifier
    - (void) fillNewSoup
    
    @end


=== ILSoupDelegate

Delegate methods for ILSoup

    @protocol ILSoupDelegate
    
    - (void) soup:(ILSoup*) deJour addedEntry:(ILSoupEntry*) entry
    - (void) soup:(ILSoup*) deJour adoptedEntry:(ILSoupEntry*) entry
    - (void) soup:(ILSoup*) deJour createdEntry:(ILSopuEntry*) entry
    - (void) soup:(ILSoup*) deJour setQuery:(NSPredicate*) query
    
    @end


=== ILUnionSoup

Compines soups into a single virutal store

    @interface
    @property(readonly) NSArray<ILSoup*>* soups
    @property(assign) id<ILUnionSoupDelegate> delegate
    
    - (void) addSoup:(ILSoup*) soup // adds a soup to the union
    - (void) insertSoup:(ILSoup*) soup atIndex:(NSUnsignedInteger) index // insert at index in the stack
    - (void) removeSoup:(ILSoup*) soup // removes a soup from the union
    - (void) suspendSoup:(ILSoup*) soup // retains a soup in the union, but suspend operations
    - (void) resumeSoup:(ILSoup*) soup // attempt to resume operations on a soup
    
    @end


=== ILUnionSoupDelegate

Delegate messages relating to the soup

    @protocol ILUnionSoupDelegate
    
    - (void) unionSoup:(ILUnionSoup*) union addedSoup:(ILSoup*) soup
    - (void) unionSoup:(ILUnionSoup*) union removedSoup:(ILSoup*) soup
    - (void) unionSoup:(ILUnionSoup*) union suspendedSoup:(ILSoup*) soup
    - (void) unionSoup:(ILUnionSoup*) union resumedSoup:(ILSoup*) soup
    
    @end


=== ILSSoupEntry

SoupEntries implement the following protocol

    @protocol ILSoupEntry
    @property(readonly) NSString* entryHash
    @property(retain) NSDictionary* entryKeys
    
    + (instancetype) soupEntryFromKeys:(NSDictionary*) entryKeys;
    
    @end


=== ILSoupCursor

A collection of objects returned from a search

    @interface
    @property(readonly) NSArray<ILSoupEntry*>* entries
    
    @end


=== ILSoupIndex

Searchable index on a set

    @interface ILSoupIndex
    @property(readonly) NSString* indexPath
    @property(readonly) NSDictionary* index
    
    - (void) indexEntry:(ILSoupEntry*) entry
    - (void) removeEntry:(ILSoupEntry*) entry
    - (BOOL) includesEntry:(ILSoupEntry*) entry
    - (ILSoupCursor*) entriesWithValue:(id) value
    
    @end


=== ILSoupSequence

Maintain a time sequence for an indexPath property

    @interface ILSoupSequence
    @property(readonly) NSString* indexPath
    @property(readonly) NSDictionary<NSArray<NSDate*>*>* sequenceTimes
    @proeprty(readonly) NSDictionary<NSArray<NSNumber*>*>* sequenceValues
    
    - (void) sequenceEntry:(ILSoupEntry*) entry atTime:(NSDate*) timeIndex;
    - (void) removeEntry:(ILSoupEntry*) entry;
    - (BOOL) includesEntry:(ILSoupEntry*) entry;

    #pragma mark - fetching sequence data

    - (BOOL) fetchSequenceFor:(ILSoupEntry*) entry times:(NSArray<NSDate*>**) timeArray values:(NSArray<NSNumber*>**) valueArray

    
    @end


=== Example: Names Soup




