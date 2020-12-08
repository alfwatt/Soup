#ifndef ILSoupTime_h
#define ILSoupTime_h

@import Foundation;

// MARK: -

/// ILSoupTime supports relative time ranges for querying an ILSoupDateIndex
@protocol ILSoupTime <NSObject>

/// match any time before now
+ (id<ILSoupTime>) earlier;

/// match and time after now
+ (id<ILSoupTime>) later;

/// match any time between distantPast and distantFuture
+ (id<ILSoupTime>) anytime;

/// match any time or nil
+ (id<ILSoupTime>) whenever;

/// nevver doesn't match any dates, not now, not ever
+ (id<ILSoupTime>) never;

// MARK: - right about now

/// the two minutes incluing the one before now and the one after
+ (id<ILSoupTime>) nowish;

/// the five minutes after now
+ (id<ILSoupTime>) soonish;

/// the five minutes before now
+ (id<ILSoupTime>) recenly;

/// from midnight today to 23:59:59
+ (id<ILSoupTime>) today;

// MARK: - this era

/// from midnight jan 1 this year to 23:59:59 on dec 31
+ (id<ILSoupTime>) thisYear;

/// from midnight jan 1 the first year of this decade to 23:59:59 on dec 31 of the last year of the decade
+ (id<ILSoupTime>) thisDecade;

/// from midnight jan 1 the first year of this centuray to 23:59:59 on dec 31 of the last yaer of the century
+ (id<ILSoupTime>) thisCentury;

/// from midnight jan 1 the first year of this millenium to 23:59:59 on dec 31 of the last yaer of the millenium
+ (id<ILSoupTime>) thisMillenium;

// MARK: - last era

/// from midnight jan 1 last year to 23:59:59 on dec 31
+ (id<ILSoupTime>) lastYear;

/// from midnight jan 1 the first year of the last decade to 23:59:59 on dec 31 of the last year of the decade
+ (id<ILSoupTime>) lastDecade;

/// from midnight jan 1 the first year of the last centuray to 23:59:59 on dec 31 of the last year of the century
+ (id<ILSoupTime>) lastCentury;

/// from midnight jan 1 the first year of the last millenium to 23:59:59 on dec 31 of the last year of the millenium
+ (id<ILSoupTime>) lastMillenium;

// MARK: - next era

/// from midnight jan 1 next year to 23:59:59 on dec 31
+ (id<ILSoupTime>) nextYear;

/// from midnight jan 1 the first year of the next decade to 23:59:59 on dec 31 of the last year of the decade
+ (id<ILSoupTime>) nextDecade;

/// from midnight jan 1 the first year of the last century to 23:59:59 on dec 31 of the last year of the century
+ (id<ILSoupTime>) nextCentury;

/// from midnight jan 1 the first year of the next millenium to 23:59:59 on dec 31 of the last year of the millenium
+ (id<ILSoupTime>) nextMillenium;

// MARK: -

/// earliest moment of this ILSoupTime
@property(nonatomic,readonly) NSDate* earliest;

/// latest moment of this ILSoupTime
@property(nonatomic,readonly) NSDate* latest;

// MARK: - Initilizer

/// init an ILSoupTime with earliest and latest dates
- (instancetype) initWithEarliest:(NSDate*)earliest andLatest:(NSDate*)latest;

/// iterval of this ILSoupTime
- (NSTimeInterval) interval;

// MARK: - Comprability

- (NSComparisonResult) compare:(NSDate*)date;

@end

#endif
