#import "ILSoupClock.h"

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

+ (id<ILSoupTime>)later {
    return [self.alloc initWithEarliest:NSDate.date andLatest:NSDate.distantFuture];
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

+ (id<ILSoupTime>)lastCentury {
    return nil;
}

+ (id<ILSoupTime>)lastDecade {
    return nil;
}

+ (id<ILSoupTime>)lastMillenium {
    return nil;
}

+ (id<ILSoupTime>)lastYear {
    return nil;
}

+ (id<ILSoupTime>)nextCentury {
    return nil;
}

+ (id<ILSoupTime>)nextDecade {
    return nil;
}

+ (id<ILSoupTime>)nextMillenium {
    return nil;
}

+ (id<ILSoupTime>)nextYear {
    return nil;
}

+ (id<ILSoupTime>)nowish {
    return nil;
}

+ (id<ILSoupTime>)recenly {
    return nil;
}

+ (id<ILSoupTime>)soonish {
    return nil;
}

+ (id<ILSoupTime>)thisCentury {
    return nil;
}

+ (id<ILSoupTime>)thisDecade {
    return nil;
}

+ (id<ILSoupTime>)thisMillenium {
    return nil;
}

+ (id<ILSoupTime>)thisYear {
    return nil;
}

+ (id<ILSoupTime>)today {
    return nil;
}

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
