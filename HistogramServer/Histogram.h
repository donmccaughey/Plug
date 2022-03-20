#import <Foundation/Foundation.h>


NS_ASSUME_NONNULL_BEGIN


@interface Histogram : NSObject

@property (readonly) NSUInteger bytesCounted;
@property (readonly, strong) NSMutableDictionary<NSNumber *, NSNumber *> *counts;

- (void)addData:(nonnull dispatch_data_t)data
 shouldReadMore:(nonnull BOOL *)shouldReadMore;

- (dispatch_data_t)generateReport;

@end


NS_ASSUME_NONNULL_END
