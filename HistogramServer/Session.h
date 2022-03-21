#import <Plug/Plug.h>


@class Histogram;
@class PLGConnection;
@class Server;


NS_ASSUME_NONNULL_BEGIN


@interface Session : NSObject<PLGConnectionDelegate>

@property PLGConnection *connection;
@property Histogram *histogram;
@property dispatch_queue_t queue;
@property (weak) Server *server;

- (instancetype)initWithConnection:(PLGConnection *)connection;

- (BOOL)startWithError:(NSError **)error;

@end


NS_ASSUME_NONNULL_END
