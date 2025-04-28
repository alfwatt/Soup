#import "ILStockSequence.h"
#import "ILSoupEntry.h"

NS_ASSUME_NONNULL_BEGIN

@interface ILStockSequenceEntry : NSObject
@property(retain) NSString* entryHash; // at the time
@property(retain) NSNumber* entryValue;
@property(retain) NSDate* entryDate;

@end

// MARK: -

@implementation ILStockSequenceEntry

@end

// MARK: -

@interface ILStockSequence ()
@property(retain) NSString* sequencePathStorage;
@property(retain) NSMutableDictionary<NSString*,id>* sequenceStorage;
@end

// MARK: -

@implementation ILStockSequence

+ (instancetype) sequenceWithPath:(NSString*) sequencePath {
    ILStockSequence* stockSequence = ILStockSequence.new;
    stockSequence.sequencePathStorage = sequencePath;
    stockSequence.sequenceStorage = NSMutableDictionary.new;

    return stockSequence;
}

// MARK: - Properties

- (NSString*) sequencePath {
    return self.sequencePathStorage;
}

- (void) sequenceEntry:(id<ILSoupEntry>) entry atTime:(NSDate*) timeIndex {
    id value = [entry.entryKeys valueForKeyPath:self.sequencePath];
    NSNumber* numberValue = nil;
    if ([value isKindOfClass:NSNumber.class]) {
        numberValue = (NSNumber*) value;
    }
    else if ([value respondsToSelector:@selector(doubleValue)]) {
        numberValue = @([value doubleValue]);
    }
    
    if (numberValue != nil) {
        ILStockSequenceEntry* sequencyEntry = [ILStockSequenceEntry new];
        sequencyEntry.entryHash = entry.entryHash;
        sequencyEntry.entryDate = timeIndex;
        sequencyEntry.entryValue = numberValue;
        
        NSMutableArray* sequence = self.sequenceStorage[entry.entryKeys[ILSoupEntryIdentityUUID]];
        if (!sequence) {
            sequence = NSMutableArray.new;
            self.sequenceStorage[entry.entryKeys[ILSoupEntryIdentityUUID]] = sequence;
        }
        
        [sequence addObject:sequencyEntry];
    }
    // else report sequence error?
}

- (void) removeEntry:(id<ILSoupEntry>) entry {
    [self.sequenceStorage removeObjectForKey:entry.entryKeys[ILSoupEntryIdentityUUID]];
}

- (BOOL) includesEntry:(id<ILSoupEntry>) entry {
    return [self.sequenceStorage.allKeys containsObject:entry.entryKeys[ILSoupEntryIdentityUUID]];
}

// MARK: - fetching sequence data

- (BOOL) fetchSequenceFor:(id<ILSoupEntry>) entry times:(NSArray<NSDate*>**) timeArray values:(NSArray<NSNumber*>**) valueArray {
    NSArray<ILStockSequenceEntry*>* sequence = [self.sequenceStorage[entry.entryKeys[ILSoupEntryIdentityUUID]] copy]; // snapshot
    NSMutableArray* timeSequence = [NSMutableArray arrayWithCapacity:sequence.count];
    NSMutableArray* valueSequence = [NSMutableArray arrayWithCapacity:sequence.count];
    NSUInteger index = 0;
    for (ILStockSequenceEntry* entry in sequence) {
        timeSequence[index] = entry.entryDate;
        valueSequence[index] = entry.entryValue;
        index++;
    }
    
    *timeArray = timeSequence;
    *valueArray = valueSequence;

    return (sequence != nil);
}

- (nullable id<ILSoupSequenceSource>) fetchSequenceSourceFor:(id<ILSoupEntry>) entry {
    ILStockSequenceSource* source;
//    NSArray<NSDate*>* sequenceTimes;
//    NSArray<NSNumber*>* sequenceValues;
//
//    if ([self fetchSequenceFor:entry times:&sequenceTimes value:&sequenceValues]) {
//        source = [ILStockSequenceSource sequencSourceWithTimes:sequenceTimes andValues:sequenceValues];
//    }

    return source;
}

// MARK: - NSObject

- (NSString*) description {
    return [NSString stringWithFormat:@"%@ %@ %lu entries", self.class, self.sequencePath, self.sequenceStorage.allKeys.count];
}

@end

// MARK: -

@interface ILStockSequenceSource ()
@property(nonatomic, retain) NSArray<NSDate*>* sequenceDates;
@property(nonatomic, retain) NSArray<NSNumber*>* sequenceValues;

@end

// MARK: -

@implementation ILStockSequenceSource

+ (nonnull instancetype)sequenceSourceWithTimes:(nonnull NSArray<NSDate *> *)sequenceTimes andValues:(nonnull NSArray<NSNumber *> *)sequenceValues {
    ILStockSequenceSource* stockSource = ILStockSequenceSource.new;
    stockSource.sequenceDates = sequenceTimes;
    stockSource.sequenceValues = sequenceValues;
    return stockSource;
}

// MARK: -

- (NSArray<NSDate*>*) sampleDates {
    return self.sequenceDates;
}

- (CGFloat)sampleValueAtIndex:(NSUInteger)index {
    return [self.sequenceValues[index] doubleValue];
}

@end

NS_ASSUME_NONNULL_END
