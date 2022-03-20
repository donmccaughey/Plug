#import "PLGConnection.h"

#import "PLGConnectionDelegate.h"
#import "PLGConnectionStatistics.h"
#import "PLGIODispatcher.h"
#import "PLGPOSIXError.h"
#import "PLGSocket.h"
#import "PLGSocketAddress.h"
#import "PLGTimeout.h"


@interface PLGConnection ()

- (void)didTimeout;

@end


@implementation PLGConnection
{
    PLGIODispatcher *_ioDispatcher;
    BOOL _open;
    PLGSocket *_socket;
    PLGConnectionStatistics *_statistics;
    PLGTimeout *_timeout;
}


- (void)close;
{
    @synchronized (self) {
        if (_open) {
            _open = NO;
            [_ioDispatcher close];
            _timeout = nil;
        }
    }
}


- (NSString *)description;
{
    @synchronized (self) {
        return [NSString stringWithFormat:@"<%@ Remote=%@>", [self class], _remoteAddress];
    }
}


- (void)didTimeout;
{
    id<PLGConnectionDelegate> delegate = nil;
    @synchronized (self) {
        delegate = _delegate;
    }
    [delegate connectionDidTimeout:self];
}


- (void)dispatcherDidClose:(PLGIODispatcher *)dispatcher;
{
    NSError *error = nil;
    id<PLGConnectionDelegate> delegate = nil;
    @synchronized (self) {
        error = [_socket close];
        delegate = _delegate;
    }
    if (error) [delegate connection:self didFailWithError:error];
    [delegate connectionDidClose:self];
}


- (void)dispatcher:(PLGIODispatcher *)dispatcher
  didFailWithError:(NSError *)error;
{
    id<PLGConnectionDelegate> delegate = nil;
    @synchronized (self) {
        delegate = _delegate;
    }
    [delegate connection:self didFailWithError:error];
}


- (void)dispatcher:(PLGIODispatcher *)dispatcher
didFinishWritingData:(dispatch_data_t)data;
{
    id<PLGConnectionDelegate> delegate = nil;
    @synchronized (self) {
        ++_statistics.writeCount;
        delegate = _delegate;
    }
    [delegate connection:self didFinishWritingData:data];
}


- (void)dispatcher:(PLGIODispatcher *)dispatcher
       didReadData:(dispatch_data_t)data;
{
    id<PLGConnectionDelegate> delegate = nil;
    @synchronized (self) {
        delegate = _delegate;
    }
    [delegate connection:self didReadData:data];
}


- (void)dispatcherDidReadToEnd:(PLGIODispatcher *)dispatcher;
{
    id<PLGConnectionDelegate> delegate = nil;
    @synchronized (self) {
        delegate = _delegate;
    }
    [delegate connectionDidReadToEnd:self];
}


- (void)dispatcherWillClose:(PLGIODispatcher *)dispatcher;
{
    id<PLGConnectionDelegate> delegate = nil;
    NSError *error = nil;
    @synchronized (self) {
        // TODO: report unfinished writes
        // TODO: only shutdown if we haven't read to end
        [_socket shutdown:SHUT_RD error:&error];
        delegate = _delegate;
    }
    if (error) [delegate connection:self didFailWithError:error];
}


- (void)dispatcher:(PLGIODispatcher *)dispatcher
     didWriteRange:(NSRange)range
            ofData:(dispatch_data_t)data;
{
    id<PLGConnectionDelegate> delegate = nil;
    @synchronized (self) {
        [_timeout reset];
        _statistics.bytesWritten += range.length;
        delegate = _delegate;
    }
    [delegate connection:self didWriteRange:range ofData:data];
}


- (id)init;
{
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}


- (id)initWithSocket:(PLGSocket *)socket
       remoteAddress:(PLGSocketAddress *)remoteAddress
    andServerAddress:(PLGSocketAddress *)serverAddress;
{
    self = [super init];
    if ( ! self) return nil;
    
    _remoteAddress = remoteAddress;
    _serverAddress = serverAddress;
    _socket = socket;
    
    _ioDispatcher = [PLGIODispatcher new];
    [_ioDispatcher setDelegate:self];
    _statistics = [PLGConnectionStatistics new];
    
    return self;
}


- (BOOL)isDoneWriting;
{
    @synchronized (self) {
        return [_ioDispatcher isDoneWriting];
    }
}


- (BOOL)openWithTimeoutInterval:(NSTimeInterval)timeoutInterval
                   timeoutQueue:(dispatch_queue_t)timeoutQueue
              andCleanupOnQueue:(dispatch_queue_t)cleanupQueue
                          error:(NSError **)error;
{
    @synchronized (self) {
        _timeout = [[PLGTimeout alloc] initWithTimeout:timeoutInterval
                                               onQueue:timeoutQueue
                                             forTarget:self
                                             andAction:@selector(didTimeout)];
        
        if ( ! [_socket setNonBlock:YES error:error]) return NO;
        if ( ! [_ioDispatcher openWithFileDescriptor:_socket andCleanupOnQueue:cleanupQueue error:error]) return NO;
        
        [_ioDispatcher setLowWaterMark:0];
        
        _open = YES;
        return YES;
    }
}


- (void)scheduleReadOnQueue:(dispatch_queue_t)readQueue;
{
    @synchronized (self) {
        [_ioDispatcher scheduleReadOnQueue:readQueue];
        [_timeout reset];
    }
}


- (void)scheduleWriteWithData:(dispatch_data_t)data
                      onQueue:(dispatch_queue_t)writeQueue;
{
    @synchronized (self) {
        [_ioDispatcher scheduleWriteWithData:data onQueue:writeQueue];
        [_timeout reset];
    }
}

@end
