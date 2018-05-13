#import <Foundation/Foundation.h>
#import <Soup/ILSoupSequence.h>

@interface ILSoupStockSequence : NSObject <ILSoupSequence>

@end

#pragma mark -

@interface ILSoupStockSequenceSource : NSObject <ILSoupSequenceSource>

+ (instancetype) stockSequencSourceWithDates:(NSArray<NSDate*>*) dates andValues:(NSArray<NSNumber*>*) values;

@end
