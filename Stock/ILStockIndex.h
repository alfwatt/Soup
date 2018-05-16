#import <Foundation/Foundation.h>
#import <Soup/ILSoupIndex.h>

@interface ILStockIndex : NSObject <ILSoupIndex>

@end

#pragma mark-

@interface ILStockTextIndex : ILStockIndex <ILSoupTextIndex>

@end

#pragma mark -

@interface ILStockNumberIndex : ILStockIndex <ILSoupNumberIndex>

@end

#pragma mark -

@interface ILStockDateIndex : ILStockIndex <ILSoupDateIndex>

@end

#pragma mark -

@interface ILStockCursor : NSObject <ILSoupCursor>

@end
