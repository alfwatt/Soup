#import <Foundation/Foundation.h>
#import <Soup/ILSoupSequence.h>

@interface ILStockSequence : NSObject <ILSoupSequence>

@end

#pragma mark -

@interface ILStockSequenceSource : NSObject <ILSoupSequenceSource>

+ (instancetype) sequencSourceWithTimes:(NSArray<NSDate*>*) seqenceTimes andValues:(NSArray<NSNumber*>*) sequenceValues;

@end
