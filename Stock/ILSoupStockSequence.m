#import "ILSoupStockSequence.h"
#import "ILSoupEntry.h"

@interface ILSoupStockSequenceEntry : NSObject
@property(retain) NSString* entryHash; // at the time
@property(retain) NSNumber* entryValue;
@property(retain) NSDate* entryDate;

@end

#pragma mark -

@implementation ILSoupStockSequenceEntry

@end

#pragma mark -

@interface ILSoupStockSequence ()
@property(retain) NSString* sequencePathStorage;
@property(retain) NSMutableDictionary<NSString*,id>* sequenceStorage;
@end

#pragma mark -

@implementation ILSoupStockSequence

+ (instancetype) sequenceWithPath:(NSString*) sequencePath
{
    ILSoupStockSequence* stockSequence = [ILSoupStockSequence new];
    stockSequence.sequencePathStorage = sequencePath;
    stockSequence.sequenceStorage = [NSMutableDictionary new];

    return stockSequence;
}

#pragma mark - Properties

- (NSString*) sequencePath
{
    return self.sequencePathStorage;
}

- (void) sequenceEntry:(id<ILSoupEntry>) entry atTime:(NSDate*) timeIndex
{
    id value = [entry.entryKeys valueForKeyPath:self.sequencePath];
    NSNumber* numberValue = nil;
    if ([value isKindOfClass:[NSNumber class]]) {
        numberValue = (NSNumber*) value;
    }
    else if ([value respondsToSelector:@selector(doubleValue)]) {
        numberValue = @([value doubleValue]);
    }
    
    if (numberValue) {
        ILSoupStockSequenceEntry* sequencyEntry = [ILSoupStockSequenceEntry new];
        sequencyEntry.entryHash = entry.entryHash;
        sequencyEntry.entryDate = timeIndex;
        sequencyEntry.entryValue = numberValue;
        
        NSMutableArray* sequence = self.sequenceStorage[entry.entryKeys[ILSoupEntryUUID]];
        if (!sequence) {
            sequence = [NSMutableArray new];
            self.sequenceStorage[entry.entryKeys[ILSoupEntryUUID]] = sequence;
        }
        
        [sequence addObject:sequencyEntry];
    }
    // else report sequence error?
}

- (void) removeEntry:(id<ILSoupEntry>) entry
{
    [self.sequenceStorage removeObjectForKey:entry.entryKeys[ILSoupEntryUUID]];
}

- (BOOL) includesEntry:(id<ILSoupEntry>) entry
{
    return [self.sequenceStorage.allKeys containsObject:entry.entryKeys[ILSoupEntryUUID]];
}

#pragma mark - fetching sequence data

- (BOOL) fetchSequenceFor:(id<ILSoupEntry>) entry times:(NSArray<NSDate*>**) timeArray values:(NSArray<NSNumber*>**) valueArray
{
    NSArray<ILSoupStockSequenceEntry*>* sequence = [self.sequenceStorage[entry.entryKeys[ILSoupEntryUUID]] copy]; // snapshot
    NSMutableArray* dateSequence = [NSMutableArray arrayWithCapacity:sequence.count];
    NSMutableArray* valueSequence = [NSMutableArray arrayWithCapacity:sequence.count];
    NSUInteger index = 0;
    for (ILSoupStockSequenceEntry* entry in sequence) {
        dateSequence[index] = entry.entryDate;
        valueSequence[index] = entry.entryValue;
        index++;
    }
    
    *timeArray = dateSequence;
    *valueArray = valueSequence;

    return (sequence != nil);
}

- (id<ILSoupSequenceSource>) fetchSequenceSourceFor:(id<ILSoupEntry>) entry
{
    return nil;
}

#pragma mark - NSObject

- (NSString*) description
{
    return [NSString stringWithFormat:@"%@ %@ %lu entries", self.className, self.sequencePath, self.sequenceStorage.allKeys.count];
}

@end

#pragma mark -

@interface ILSoupStockSequenceSource ()
@property(nonatomic, retain) NSArray<NSDate*>* sequenceDates;
@property(nonatomic, retain) NSArray<NSNumber*>* sequenceValues;

@end

#pragma mark -

@implementation ILSoupStockSequenceSource

+ (instancetype) stockSequencSourceWithDates:(NSArray<NSDate*>*) dates andValues:(NSArray<NSNumber*>*) values
{
    ILSoupStockSequenceSource* stockSource = [ILSoupStockSequenceSource new];
    stockSource.sequenceDates = dates;
    stockSource.sequenceValues = values;
    return stockSource;
}

#pragma mark -

- (NSArray<NSDate*>*) sampleDates
{
    return self.sequenceDates;
}

- (CGFloat)sampleValueAtIndex:(NSUInteger)index
{
    return [self.sequenceValues[index] doubleValue];
}

@end
