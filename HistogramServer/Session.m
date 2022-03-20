#import "Session.h"

#import "Histogram.h"


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
    NSLog(@"Connection %@ wrote %zu bytes", connection, dispatch_data_get_size(data));
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
    NSLog(@"Connection %@ wrote %lu bytes", connection, (unsigned long)range.length);
}


- (void)connectionDidClose:(nonnull PLGConnection *)connection;
{
    NSLog(@"Connection %@ closed", connection);
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


- (instancetype)initWithConnection:(PLGConnection *)connection
                          andQueue:(dispatch_queue_t)queue;
{
    self = [super init];
    if ( ! self) return nil;
    
    _connection = connection;
    _histogram = [Histogram new];
    _queue = queue;
    
    return self;
}


@end
