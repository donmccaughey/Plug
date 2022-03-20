#import <Plug/Plug.h>


@class Histogram;
@class PLGConnection;


NS_ASSUME_NONNULL_BEGIN


@interface Session : NSObject<PLGConnectionDelegate>

@property (readonly, strong) PLGConnection *connection;
@property (readonly, strong) Histogram *histogram;
@property (readonly) dispatch_queue_t queue;

- (instancetype)initWithConnection:(PLGConnection *)connection
                          andQueue:(dispatch_queue_t)queue;

@end


NS_ASSUME_NONNULL_END
