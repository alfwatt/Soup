@import Foundation;

#ifndef ILSoupTime_h
#define ILSoupTime_h

/*! @brief ILSoupTime supports relative time ranges for querying date based ILSoupIndex */
@protocol ILSoupTime <NSObject>

/*! @brief any time before now */
+ (id<ILSoupTime>) earlier;

/*! @brief and time after now */
+ (id<ILSoupTime>) later;

/*! @brief any time between distantPast and distantFuture */
+ (id<ILSoupTime>) anytime;

/*! @brief any time or nil */
+ (id<ILSoupTime>) whenever;

/*! @brief not now, not ever */
+ (id<ILSoupTime>) never;

/*! @brief the two minutes incluing the one before now and the one after */
+ (id<ILSoupTime>) nowish;

/*! @brief the five minutes after now */
+ (id<ILSoupTime>) soonish;

/*! @brief the five minutes before now */
+ (id<ILSoupTime>) recenly;

/*! @brief from midnight today to 23:59:59 */
+ (id<ILSoupTime>) today;

#pragma mark - this era

/*! @brief from midnight jan 1 this year to 23:59:59 on dec 31 */
+ (id<ILSoupTime>) thisYear;

/*! @brief from midnight jan 1 the first year of this decade to 23:59:59 on dec 31 of the last year */
+ (id<ILSoupTime>) thisDecade;

/*! @brief from midnight jan 1 the first year of this centuray to 23:59:59 on dec 31 of the last yaer */
+ (id<ILSoupTime>) thisCentury;

/*! @brief from midnight jan 1 the first year of this millenium to 23:59:59 on dec 31 of the last yaer */
+ (id<ILSoupTime>) thisMillenium;

#pragma mark - last era

/*! @brief from midnight jan 1 last year to 23:59:59 on dec 31 */
+ (id<ILSoupTime>) lastYear;

/*! @brief from midnight jan 1 the first year of the last decade to 23:59:59 on dec 31 of the last year */
+ (id<ILSoupTime>) lastDecade;

/*! @brief from midnight jan 1 the first year of the last centuray to 23:59:59 on dec 31 of the last yaer */
+ (id<ILSoupTime>) lastCentury;

/*! @brief from midnight jan 1 the first year of the last millenium to 23:59:59 on dec 31 of the last yaer */
+ (id<ILSoupTime>) lastMillenium;

#pragma mark - next era

/*! @brief from midnight jan 1 next year to 23:59:59 on dec 31 */
+ (id<ILSoupTime>) nextYear;

/*! @brief from midnight jan 1 the first year of the next decade to 23:59:59 on dec 31 of the last year */
+ (id<ILSoupTime>) nextDecade;

/*! @brief from midnight jan 1 the first year of the last century to 23:59:59 on dec 31 of the last yaer */
+ (id<ILSoupTime>) nextCentury;

/*! @brief from midnight jan 1 the first year of the next millenium to 23:59:59 on dec 31 of the last yaer */
+ (id<ILSoupTime>) nextMillenium;

#pragma mark -

/*! @brief init an ILSoupTime instance with earliest and latest dates */
+ (id<ILSoupTime>) timeSpanWithEarliest:(NSDate*)earliest andLatest:(NSDate*)latest;

/*! @brief from midnight jan 1 the first year of the last millenium to 23:59:59 on dec 31 of the last yaer */
+ (id<ILSoupTime>) timeSpanWithEarliest:(NSDate*)earliest andInterval:(NSTimeInterval)interval;

- (NSDate*) earliest;
- (NSDate*) latest;
- (NSTimeInterval) interval;

@end

#endif /* ILSoupTime_h */
