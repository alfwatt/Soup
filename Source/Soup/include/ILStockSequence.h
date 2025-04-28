#import <Foundation/Foundation.h>

#ifdef SWIFT_PACKAGE
#import "ILSoupSequence.h"
#else
#import <Soup/ILSoupSequence.h>
#endif

NS_ASSUME_NONNULL_BEGIN

@interface ILStockSequence : NSObject <ILSoupSequence>

@end

// MARK: -

@interface ILStockSequenceSource : NSObject <ILSoupSequenceSource>

+ (instancetype) sequenceSourceWithTimes:(NSArray<NSDate*>*) sequenceTimes andValues:(NSArray<NSNumber*>*) sequenceValues;

@end

NS_ASSUME_NONNULL_END
