
#ifdef SWIFT_PACKAGE
// MARK: Protocols

#import "ILSoup.h"
#import "ILSoupEntry.h"
#import "ILSoupIndex.h"
#import "ILSoupSequence.h"
#import "ILSoupTime.h"

// MARK: - Soup Stock

#import "ILSoupClock.h"
#import "ILSoupStock.h"
#import "ILStockEntry.h"
#import "ILStockIndex.h"
#import "ILStockSequence.h"
#import "ILSoupSnapshot.h"

// MARK: - Soup Flavors

#import "ILFileSoup.h"
#import "ILMemorySoup.h"
#import "ILQueuedSoup.h"
#import "ILSynchedSoup.h"
#import "ILUnionSoup.h"

// MARK: - Soup Salt

#import "NSArray+Soup.h"
#import "NSDictionary+Soup.h"

#else

// MARK: Protocols

#import <Soup/ILSoup.h>
#import <Soup/ILSoupEntry.h>
#import <Soup/ILSoupIndex.h>
#import <Soup/ILSoupSequence.h>
#import <Soup/ILSoupTime.h>

// MARK: - Soup Stock

#import <Soup/ILSoupClock.h>
#import <Soup/ILSoupStock.h>
#import <Soup/ILStockEntry.h>
#import <Soup/ILStockIndex.h>
#import <Soup/ILStockSequence.h>
#import <Soup/ILSoupSnapshot.h>

// MARK: - Soup Flavors

#import <Soup/ILFileSoup.h>
#import <Soup/ILMemorySoup.h>
#import <Soup/ILQueuedSoup.h>
#import <Soup/ILSynchedSoup.h>
#import <Soup/ILUnionSoup.h>

// MARK: - Soup Salt

#import <Soup/NSArray+Soup.h>
#import <Soup/NSDictionary+Soup.h>

#endif
