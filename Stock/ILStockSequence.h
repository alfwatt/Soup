@import Foundation;

#import <Soup/ILSoupSequence.h>

NS_ASSUME_NONNULL_BEGIN

@interface ILStockSequence : NSObject <ILSoupSequence>

@end

// MARK: -

@interface ILStockSequenceSource : NSObject <ILSoupSequenceSource>

+ (instancetype) sequencSourceWithTimes:(NSArray<NSDate*>*) seqenceTimes andValues:(NSArray<NSNumber*>*) sequenceValues;

@end

NS_ASSUME_NONNULL_END
