#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

// MARK: -

/// ILSoupTime supports relative time ranges for querying an ILSoupDateIndex
@protocol ILSoupTime <NSObject>

/// match any time before now
+ (id<ILSoupTime>) earlier;

/// match any time earlier than latest
+ (id<ILSoupTime>)earlierThan:(NSDate*) latest;

/// match and time after now
+ (id<ILSoupTime>) later;

/// match any time later than earliest
+ (id<ILSoupTime>)laterThan:(NSDate*) earliest;

/// match any time between distantPast and distantFuture
+ (id<ILSoupTime>) anytime;

/// match any time or nil
+ (id<ILSoupTime>) whenever;

/// never doesn't match any dates, not now, not ever
+ (id<ILSoupTime>) never;

// MARK: - right about now

/// the time interval around the center date
+ (id<ILSoupTime>) interval:(NSTimeInterval) seconds before:(NSDate*) latest;
+ (id<ILSoupTime>) interval:(NSTimeInterval) seconds around:(NSDate*) center;
+ (id<ILSoupTime>) interval:(NSTimeInterval) seconds after:(NSDate*) earliest;

/// the five minutes before now
+ (id<ILSoupTime>) recently;

/// the two minutes including the one before now and the one after
+ (id<ILSoupTime>) nowish;

/// the five minutes after now
+ (id<ILSoupTime>) soonish;

/// from midnight today to 23:59:59
+ (id<ILSoupTime>) today;

// MARK: - this era

/// 
+ (id<ILSoupTime>) thisMonth;

/// from midnight jan 1 this year to 23:59:59 on dec 31
+ (id<ILSoupTime>) thisYear;

/// from midnight jan 1 the first year of this decade to 23:59:59 on dec 31 of the last year of the decade
// + (id<ILSoupTime>) thisDecade;

/// from midnight jan 1 the first year of this century to 23:59:59 on dec 31 of the last year of the century
// + (id<ILSoupTime>) thisCentury;

/// from midnight jan 1 the first year of this millennium to 23:59:59 on dec 31 of the last year of the millennium
// + (id<ILSoupTime>) thisMillennium;

// MARK: - last era

/// from midnight jan 1 last year to 23:59:59 on dec 31
+ (id<ILSoupTime>) lastYear;

/// from midnight jan 1 the first year of the last decade to 23:59:59 on dec 31 of the last year of the decade
+ (id<ILSoupTime>) lastDecade;

/// from midnight jan 1 the first year of the last century to 23:59:59 on dec 31 of the last year of the century
+ (id<ILSoupTime>) lastCentury;

/// from midnight jan 1 the first year of the last millennium to 23:59:59 on dec 31 of the last year of the millennium
+ (id<ILSoupTime>) lastMillennium;

// MARK: - next era

/// from midnight jan 1 next year to 23:59:59 on dec 31
+ (id<ILSoupTime>) nextYear;

/// from midnight jan 1 the first year of the next decade to 23:59:59 on dec 31 of the last year of the decade
+ (id<ILSoupTime>) nextDecade;

/// from midnight jan 1 the first year of the last century to 23:59:59 on dec 31 of the last year of the century
+ (id<ILSoupTime>) nextCentury;

/// from midnight jan 1 the first year of the next millennium to 23:59:59 on dec 31 of the last year of the millennium
+ (id<ILSoupTime>) nextMillennium;

// MARK: -

/// earliest moment of this ILSoupTime
@property(nonatomic,readonly) NSDate* earliest;

/// latest moment of this ILSoupTime
@property(nonatomic,readonly) NSDate* latest;

// MARK: - Initializer

/// init an ILSoupTime with earliest and latest dates
- (instancetype) initWithEarliest:(NSDate*)earliest andLatest:(NSDate*)latest;

/// interval of this ILSoupTime
- (NSTimeInterval) interval;

// MARK: - Comparability

- (NSComparisonResult) compare:(NSDate*)date;

@end

NS_ASSUME_NONNULL_END
