#import "Server.h"

#import "Session.h"


@implementation Server


- (instancetype)init;
{
    self = [super init];
    if (!self) return nil;
    
    _exit_status = EXIT_SUCCESS;
    
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
        Session *session = [[Session alloc] initWithConnection:connection];
        
        NSError *error = nil;
        BOOL started = [session startWithError:&error];
        if (started) {
            [_sessions addObject:session];
            session.server = self;
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
    _exit_status = EXIT_FAILURE;
    [listener close];
}


- (void)listenerDidClose:(nonnull PLGListener *)listener;
{
    NSLog(@"Listener on %@ closed", listener.serverAddress);
    exit(_exit_status);
}


- (BOOL)start;
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
