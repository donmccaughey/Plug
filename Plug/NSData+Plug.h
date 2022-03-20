#import <Foundation/Foundation.h>


NS_ASSUME_NONNULL_BEGIN


@interface NSData (Plug)

- (dispatch_data_t)dispatchDataOnQueue:(dispatch_queue_t)queue;

@end


NS_ASSUME_NONNULL_END
