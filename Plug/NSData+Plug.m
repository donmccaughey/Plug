#import "NSData+Plug.h"


@implementation NSData (Plug)

- (dispatch_data_t)dispatchDataOnQueue:(dispatch_queue_t)queue;
{
    __block NSData *data = [self copy];
    return dispatch_data_create([data bytes], [data length], queue, ^{
        data = nil;
    });
}


@end
