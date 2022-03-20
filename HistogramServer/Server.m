#import "Server.h"

#import "Session.h"


@implementation Server


- (instancetype)init;
{
    self = [super init];
    if (!self) return nil;
    
    _failed = NO;
    
    PLGInetSocketAddress *address = [PLGInetSocketAddress anyInternetAddressWithPort:2000];
    _listener = [[PLGListener alloc] initWithServerAddress:address];
    _listener.delegate = self;
    
    _sessions = [NSMutableArray new];
    
    return self;
}


- (void)listener:(nonnull PLGListener *)listener
didAcceptConnections:(nonnull NSArray *)connections;
{
    for (PLGConnection *connection in connections) {
        NSLog(@"Accepted connection from %@", connection.remoteAddress);
        dispatch_queue_t timeoutQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0);
        dispatch_queue_t ioQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
        
        Session *session = [[Session alloc] initWithConnection:connection
                                                      andQueue:ioQueue];
        connection.delegate = session;
        
        NSError *error = nil;
        BOOL opened = [connection openWithTimeoutInterval:10.0
                                             timeoutQueue:timeoutQueue
                                        andCleanupOnQueue:ioQueue
                                                    error:&error];
        if (opened) {
            [_sessions addObject:session];
            [connection scheduleReadOnQueue:ioQueue];
        } else {
            NSLog(@"Error: (%li): %@", (long)error.code, error.description);
            [connection close];
        }
    }
}


- (void)listener:(nonnull PLGListener *)listener
didFailWithError:(nonnull NSError *)error;
{
    NSLog(@"Error: (%li): %@", (long)error.code, error.description);
    self.failed = YES;
    [listener close];
}


- (void)listenerDidClose:(nonnull PLGListener *)listener;
{
    NSLog(@"Listener on %@ closed", listener.serverAddress);
    exit(self.failed ? EXIT_FAILURE : EXIT_SUCCESS);
}


- (BOOL)run;
{
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    NSError *error = nil;
    BOOL opened = [_listener openOnQueue:queue error:&error];
    if (opened) {
        NSLog(@"Listening on %@", _listener.serverAddress);
        return YES;
    } else {
        NSLog(@"Error: (%li) %@", (long)error.code, error.description);
        return NO;
    }
}


@end
