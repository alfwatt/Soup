@import Foundation;

#import <Soup/ILSoupSequence.h>

@interface ILStockSequence : NSObject <ILSoupSequence>

@end

// MARK: -

@interface ILStockSequenceSource : NSObject <ILSoupSequenceSource>

+ (instancetype) sequencSourceWithTimes:(NSArray<NSDate*>*) seqenceTimes andValues:(NSArray<NSNumber*>*) sequenceValues;

@end
