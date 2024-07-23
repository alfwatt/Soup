#import "ILSoupClock.h"

NS_ASSUME_NONNULL_BEGIN

@interface ILSoupClock ()
@property(nonatomic,retain) NSDate* earliestStorage;
@property(nonatomic,retain) NSDate* latestStorage;
@property(nonatomic,assign) BOOL isWhenever;
@end

// MARK: -

@implementation ILSoupClock

+ (id<ILSoupTime>)earlier {
    return [self.alloc initWithEarliest:NSDate.distantPast andLatest:NSDate.date];
}

+ (id<ILSoupTime>)earlierThan:(NSDate*) latest {
    return [self.alloc initWithEarliest:NSDate.distantPast andLatest:latest];
}

+ (id<ILSoupTime>)later {
    return [self.alloc initWithEarliest:NSDate.date andLatest:NSDate.distantFuture];
}

+ (id<ILSoupTime>)laterThan:(NSDate*) earliest {
    return [self.alloc initWithEarliest:earliest andLatest:NSDate.distantFuture];
}

+ (id<ILSoupTime>)anytime {
    static ILSoupClock* anytime = nil;
    if (!anytime) {
        anytime = [self.alloc initWithEarliest:NSDate.distantPast andLatest:NSDate.distantFuture];
    }
    return anytime;
}

+ (id<ILSoupTime>)never {
    static ILSoupClock* never = nil;
    if (!never) {
        never =  [self.alloc initWithEarliest:NSDate.distantFuture andLatest:NSDate.distantPast];
    }
    return never;
}

+ (id<ILSoupTime>)whenever {
    static ILSoupClock* whenever = nil;
    if (!whenever) {
        whenever =  [self.alloc initWithEarliest:NSDate.distantFuture andLatest:NSDate.distantPast];
        whenever.isWhenever = true;
    }
    return whenever;
}

// MARK: -

NSTimeInterval const GREGORIAN_DAY = 60 * 60 * 24; // Seconds * Minutes * Hours
NSTimeInterval const GREGORIAN_YEAR = GREGORIAN_DAY * 365.2425;
NSTimeInterval const GREGORIAN_DECADE = GREGORIAN_YEAR * 10;
NSTimeInterval const GREGORIAN_CENTURY = GREGORIAN_YEAR * 100;
NSTimeInterval const GREGORIAN_MILLENIUM = GREGORIAN_YEAR * 1000;

+ (id<ILSoupTime>)lastYear {
    return [self interval:GREGORIAN_YEAR before:NSDate.date];
}

+ (id<ILSoupTime>)lastDecade {
    return [self interval:GREGORIAN_DECADE before:NSDate.date];
}

+ (id<ILSoupTime>)lastCentury {
    return [self interval:GREGORIAN_CENTURY before:NSDate.date];
}

+ (id<ILSoupTime>)lastMillenium {
    return [self interval:GREGORIAN_MILLENIUM before:NSDate.date];
}

+ (id<ILSoupTime>)nextYear {
    return [self interval:GREGORIAN_YEAR after:NSDate.date];
}

+ (id<ILSoupTime>)nextDecade {
    return [self interval:GREGORIAN_DECADE after:NSDate.date];
}

+ (id<ILSoupTime>)nextCentury {
    return [self interval:GREGORIAN_CENTURY after:NSDate.date];
}

+ (id<ILSoupTime>)nextMillenium {
    return [self interval:GREGORIAN_MILLENIUM after:NSDate.date];
}

// MARK: -

/// the time interval around the center date
+ (id<ILSoupTime>) interval:(NSTimeInterval) seconds before:(NSDate*) latest {
    return [self.alloc initWithEarliest:[latest dateByAddingTimeInterval:-seconds] andLatest:latest];
}

+ (id<ILSoupTime>) interval:(NSTimeInterval) seconds around:(NSDate*) center {
    return [self.alloc initWithEarliest:[center dateByAddingTimeInterval:-(seconds/2)]
                              andLatest:[center dateByAddingTimeInterval:(seconds/2)]];
}

+ (id<ILSoupTime>) interval:(NSTimeInterval) seconds after:(NSDate*) earliest {
    return [self.alloc initWithEarliest:earliest andLatest:[earliest dateByAddingTimeInterval:seconds]];
}

+ (id<ILSoupTime>)recenly {
    return [self interval:(5 * 1000) before:NSDate.date];
}

+ (id<ILSoupTime>)nowish {
    return [self interval:(2 * 1000) around:NSDate.date];
}

+ (id<ILSoupTime>)soonish {
    return [self interval:(5 * 1000) after:NSDate.date];
}

+ (id<ILSoupTime>)today {
    unsigned unitFlags = NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear | NSCalendarUnitEra;
    NSDateComponents* components = [NSCalendar.currentCalendar components:unitFlags fromDate:NSDate.date];
    NSDate* beginningOfToday = [components date];
    return [self interval:GREGORIAN_DAY after:beginningOfToday];
}

+ (id<ILSoupTime>)thisMonth {
    unsigned unitFlags = NSCalendarUnitMonth | NSCalendarUnitYear | NSCalendarUnitEra;
    NSDateComponents* components = [NSCalendar.currentCalendar components:unitFlags fromDate:NSDate.date];
    NSDate* beginningOfMonth = [components date];
    return [self interval:(GREGORIAN_DAY * 30.438) after:beginningOfMonth];
}

+ (id<ILSoupTime>)thisYear {
    unsigned unitFlags = NSCalendarUnitYear | NSCalendarUnitEra;
    NSDateComponents* components = [NSCalendar.currentCalendar components:unitFlags fromDate:NSDate.date];
    NSDate* beginningOfYear = [components date];
    return [self interval:GREGORIAN_YEAR after:beginningOfYear];
}

/*
+ (id<ILSoupTime>)thisDecade {
    return nil;
}

+ (id<ILSoupTime>)thisCentury {
    return nil;
}

+ (id<ILSoupTime>)thisMillenium {
    return nil;
}
*/

// MARK: -

- (instancetype) initWithEarliest:(NSDate*)earliest andLatest:(NSDate*)latest {
    if ((self = super.init)) {
        self.earliestStorage = earliest;
        self.latestStorage = latest;
    }
    return self;
}

// MARK: -

- (NSDate*) earliest {
    return self.earliestStorage;
}

- (NSDate*) latest {
    return self.latestStorage;
}

- (NSTimeInterval) interval {
    return [self.latest timeIntervalSinceDate:self.earliest];
}

// MARK: - compare

- (NSComparisonResult) compare:(id) other {
    NSComparisonResult result = self.isWhenever ? NSOrderedSame : NSOrderedAscending; // whenever always matches
    if (!self.isWhenever && [other isKindOfClass:NSDate.class]) {
        NSDate* comprable = (NSDate*)other;
        if ([comprable compare:self.earliestStorage] == NSOrderedDescending
          && [comprable compare:self.latestStorage] == NSOrderedAscending) { // same
            result = NSOrderedSame;
        }
        else if ([comprable compare:self.earliestStorage] == NSOrderedAscending) { // before
            result = NSOrderedAscending;
        }
        else if ([comprable compare:self.latestStorage] == NSOrderedDescending) { // after
            result = NSOrderedDescending;
        }
    }
    return result;
}

@end

NS_ASSUME_NONNULL_END
