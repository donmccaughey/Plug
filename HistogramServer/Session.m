#import "Session.h"

#import "Histogram.h"
#import "Server.h"


@implementation Session


- (void)connection:(nonnull PLGConnection *)connection
  didFailWithError:(nonnull NSError *)error;
{
    NSLog(@"Error: (%li): %@", (long)error.code, error.description);
    [connection close];
}


  - (void)connection:(nonnull PLGConnection *)connection
didFinishWritingData:(nonnull dispatch_data_t)data;
{
    NSLog(@"Connection %@ finished writing %zu bytes", connection, dispatch_data_get_size(data));
    [connection close];
}


- (void)connection:(nonnull PLGConnection *)connection
       didReadData:(nonnull dispatch_data_t)data;
{
    NSLog(@"Connection %@ read %zu bytes", connection, dispatch_data_get_size(data));
    BOOL shouldReadMore = YES;
    [_histogram addData:data shouldReadMore:&shouldReadMore];
    if (shouldReadMore) {
        [_connection scheduleReadOnQueue:_queue];
    } else {
        dispatch_data_t report = [_histogram generateReport];
        [_connection scheduleWriteWithData:report onQueue:_queue];
    }
}


- (void)connection:(nonnull PLGConnection *)connection
     didWriteRange:(NSRange)range
            ofData:(nonnull dispatch_data_t)data;
{
    NSLog(@"Connection %@ wrote %lu of %zu bytes",
          connection,
          (unsigned long)range.length,
          dispatch_data_get_size(data));
}


- (void)connectionDidClose:(nonnull PLGConnection *)connection;
{
    NSLog(@"Connection %@ closed", connection);
    Server *server = _server; // take a strong reference
    if (server) [server.sessions removeObject:self];
}


- (void)connectionDidReadToEnd:(nonnull PLGConnection *)connection;
{
    NSLog(@"Connection %@ read to end", connection);
}


- (void)connectionDidTimeout:(nonnull PLGConnection *)connection;
{
    NSLog(@"Connection %@ timed out", connection);
    [connection close];
}


- (id)init;
{
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}


- (instancetype)initWithConnection:(PLGConnection *)connection;
{
    self = [super init];
    if ( ! self) return nil;
    
    _connection = connection;
    _connection.delegate = self;
    
    _histogram = [Histogram new];
    _queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    
    return self;
}


- (BOOL)startWithError:(NSError **)error;
{
    BOOL opened = [_connection openWithTimeoutInterval:10.0
                                         timeoutQueue:_queue
                                    andCleanupOnQueue:_queue
                                                error:error];
    if (!opened) return NO;
    
    [_connection scheduleReadOnQueue:_queue];
    return YES;
}


@end
