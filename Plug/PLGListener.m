#import "PLGListener.h"

#import "PLGConnection.h"
#import "PLGListenerDelegate.h"
#import "PLGListenerStatistics.h"
#import "PLGPOSIXError.h"
#import "PLGSocket.h"
#import "PLGSocketAddress.h"


@interface PLGListener ()

- (void)acceptConnections;

- (void)closeSocket;

@end


@implementation PLGListener
{
    BOOL _open;
    PLGSocket *_socket;
    dispatch_source_t _source;
    PLGListenerStatistics *_statistics;
}


- (void)acceptConnections;
{
    NSError *error = nil;
    NSMutableArray *connections = [NSMutableArray new];
    id<PLGListenerDelegate> delegate;
    @synchronized (self) {
        do {
            PLGSocketAddress *remoteAddress = nil;
            PLGSocket *socket = [_socket acceptConnectionWithRemoteAddress:&remoteAddress
                                                                     error:&error];
            if (socket) {
                PLGConnection *connection = [[PLGConnection alloc] initWithSocket:socket
                                                                    remoteAddress:remoteAddress
                                                                 andServerAddress:_serverAddress];
                [connections addObject:connection];
                ++_statistics.acceptedConnectionCount;
            } else if (EWOULDBLOCK != [error code]) {
                ++_statistics.failedConnectionCount;
            }
        } while ( ! error);
        delegate = _delegate;
    }
    
    if (error && EWOULDBLOCK != [error code]) {
        [delegate listener:self didFailWithError:error];
    }
    if ([connections count]) {
        [delegate listener:self didAcceptConnections:connections];
    }
}


- (void)close;
{
    @synchronized (self) {
        if (_open) {
            _open = NO;
            dispatch_source_cancel(_source);
        }
    }
}


- (void)closeSocket;
{
    NSError *error = nil;
    id<PLGListenerDelegate> delegate = nil;
    @synchronized (self) {
        error = [_socket close];
        delegate = _delegate;
    }
    if (error) [delegate listener:self didFailWithError:error];
    [delegate listenerDidClose:self];
}


- (NSString *)description
{
    @synchronized (self) {
        return [NSString stringWithFormat:@"<%@: %p (%@)>",
                [self class], (__bridge void *)self, _serverAddress];
    }
}


- (id)init;
{
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}


- (id)initWithServerAddress:(PLGSocketAddress *)serverAddress;
{
    self = [super init];
    if (!self) return nil;
    
    _serverAddress = serverAddress;
    
    return self;
}


- (BOOL)openOnQueue:(dispatch_queue_t)queue
              error:(NSError **)error;
{
    return [self openWithBacklog:0 onQueue:queue error:error];
}


- (BOOL)openWithBacklog:(int)backlog
                onQueue:(dispatch_queue_t)queue
                  error:(NSError **)error;
{
    @synchronized (self) {
        _socket = [PLGSocket new];
        
        if (![_socket openWithDomain:AF_INET type:SOCK_STREAM error:error]) return NO;
        if (![_socket setReuseAddress:YES error:error]) return NO;
        if (![_socket setReusePort:YES error:error]) return NO;
        if (![_socket setNonBlock:YES error:error]) return NO;
        if (![_socket bindToAddress:_serverAddress error:error]) return NO;
        
        unsigned long mask = 0;
        _source = dispatch_source_create(DISPATCH_SOURCE_TYPE_READ,
                                         (uintptr_t) [_socket intValue], mask, queue);
        if ( ! _source) {
            if (error) *error = [PLGPOSIXError POSIXErrorWithSource:[self description]
                                                       andOperation:@"dispatch_source_create()"];
            return NO;
        }
        
        __weak PLGListener *weakSelf = self;
        dispatch_source_set_event_handler(_source, ^{
            [weakSelf acceptConnections];
        });
        
        dispatch_source_set_cancel_handler(_source, ^{
            [weakSelf closeSocket];
        });
        
        dispatch_resume(_source);
        
        if (![_socket listenWithBacklog:backlog error:error]) return NO;
        
        _open = YES;
        return YES;
    }
}

@end
