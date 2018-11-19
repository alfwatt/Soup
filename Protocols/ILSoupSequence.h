#ifndef ILSoupSequence_h
#define ILSoupSequence_h

@import CoreGraphics;

#pragma mark -

@protocol ILSoupEntry;
@protocol ILSoupSequenceSource;

#pragma mark -

/* @brief store a sequence for a numeric value */
@protocol ILSoupSequence

/* @prief the path for the sequence value */
@property(readonly) NSString* sequencePath;

#pragma mark -

/* @brief create a sequence with the path provided */
+ (instancetype) sequenceWithPath:(NSString*) sequencePath;

#pragma mark -

/* @brief sequence the entry provided, at the time index */
- (void) sequenceEntry:(id<ILSoupEntry>) entry atTime:(NSDate*) timeIndex;

/* @brief remove the entry from the sequence */
- (void) removeEntry:(id<ILSoupEntry>) entry;

/* @brief YES if there is a sequence for this entry */
- (BOOL) includesEntry:(id<ILSoupEntry>) entry;

#pragma mark - fetching sequence data

/* @brief get all sequence dates and values for a given entry */
- (BOOL) fetchSequenceFor:(id<ILSoupEntry>) entry times:(NSArray<NSDate*>**) timeArray values:(NSArray<NSNumber*>**) valueArray;

/* @brief get a sequence source for the entry */
- (id<ILSoupSequenceSource>) fetchSequenceSourceFor:(id<ILSoupEntry>) entry;

@end

#pragma mark -

/* @brief ILSparkLineDataSource Impedence Match */
@protocol ILSoupSequenceSource

/*! @brief array of dates for which sample values are avaliable */
@property(nonatomic, readonly) NSArray<NSDate*>* sampleDates;

/*! @brief scaled sample value between 0.0 and 1.0 at the index in the sampleDates array */
- (CGFloat) sampleValueAtIndex:(NSUInteger) index;

@end

#endif /* ILSoupSequence_h */
