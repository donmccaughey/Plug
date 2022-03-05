#import "PLGSocket.h"

#import "PLGPOSIXError.h"
#import "PLGSocketAddress.h"


static NSDictionary *shutdownHowNames;
static NSDictionary *socketOptionNames;



@implementation PLGSocket


- (PLGSocket *)acceptConnectionWithRemoteAddress:(PLGSocketAddress **)remoteAddress
                                           error:(NSError **)error;
{
    @synchronized (self) {
        struct sockaddr sockaddr;
        socklen_t size = sizeof sockaddr;
        int connection = accept(_fileDescriptor, &sockaddr, &size);
        if (-1 == connection) {
            if (error) *error = [PLGPOSIXError POSIXErrorWithSource:[self description]
                                                       andOperation:@"accept()"];
            return nil;
        } else {
            if (remoteAddress) *remoteAddress = [[PLGSocketAddress alloc] initWithSockaddr:&sockaddr];
            return [[PLGSocket alloc] initWithFileDescriptor:connection];
        }
    }
}


- (BOOL)bindToAddress:(PLGSocketAddress *)address
                error:(NSError **)error;
{
    @synchronized (self) {
        int result = bind(_fileDescriptor, [address sockaddr], [address length]);
        if (-1 == result) {
            if (error) *error = [PLGPOSIXError POSIXErrorWithSource:[self description]
                                                       andOperation:@"bind() to %@", address];
            return NO;
        } else {
            return YES;
        }
    }
}


- (BOOL)getLocalAddress:(PLGSocketAddress **)localAddress
                  error:(NSError **)error;
{
    @synchronized (self) {
        struct sockaddr sockaddr;
        socklen_t sockaddrLength = sizeof sockaddr;
        int result = getsockname(_fileDescriptor, &sockaddr, &sockaddrLength);
        if (-1 == result) {
            if (error) *error = [PLGPOSIXError POSIXErrorWithSource:[self description]
                                                       andOperation:@"getsockname()"];
            return NO;
        } else {
            *localAddress = [[PLGSocketAddress alloc] initWithSockaddr:&sockaddr];
            return YES;
        }
    }
}


+ (void)initialize;
{
    if ([PLGSocket class] == self) {
        shutdownHowNames = @{
            @(SHUT_RD) : @"SHUT_RD",
            @(SHUT_WR) : @"SHUT_WR",
            @(SHUT_RDWR) : @"SHUT_RDWR",
        };
        
        socketOptionNames = @{
            @(SO_ACCEPTCONN) : @"SO_ACCEPTCONN",
            @(SO_BROADCAST) : @"SO_BROADCAST",
            @(SO_DEBUG) : @"SO_DEBUG",
            @(SO_DONTROUTE) : @"SO_DONTROUTE",
            @(SO_DONTTRUNC) : @"SO_DONTTRUNC",
            @(SO_ERROR) : @"SO_ERROR",
            @(SO_KEEPALIVE) : @"SO_KEEPALIVE",
            @(SO_LABEL) : @"SO_LABEL",
            @(SO_LINGER) : @"SO_LINGER",
            @(SO_LINGER_SEC) : @"SO_LINGER_SEC",
            @(SO_NKE) : @"SO_NKE",
            @(SO_NOADDRERR) : @"SO_NOADDRERR",
            @(SO_NOSIGPIPE) : @"SO_NOSIGPIPE",
            @(SO_NOTIFYCONFLICT) : @"SO_NOTIFYCONFLICT",
            @(SO_NP_EXTENSIONS) : @"SO_NP_EXTENSIONS",
            @(SO_NREAD) : @"SO_NREAD",
            @(SO_NWRITE) : @"SO_NWRITE",
            @(SO_OOBINLINE) : @"SO_OOBINLINE",
            @(SO_PEERLABEL) : @"SO_PEERLABEL",
            @(SO_RANDOMPORT) : @"SO_RANDOMPORT",
            @(SO_RCVBUF) : @"SO_RCVBUF",
            @(SO_RCVLOWAT) : @"SO_RCVLOWAT",
            @(SO_RCVTIMEO) : @"SO_RCVTIMEO",
            @(SO_REUSEADDR) : @"SO_REUSEADDR",
            @(SO_REUSEPORT) : @"SO_REUSEPORT",
            @(SO_REUSESHAREUID) : @"SO_REUSESHAREUID",
            @(SO_SNDBUF) : @"SO_SNDBUF",
            @(SO_SNDLOWAT) : @"SO_SNDLOWAT",
            @(SO_SNDTIMEO) : @"SO_SNDTIMEO",
            @(SO_TIMESTAMP) : @"SO_TIMESTAMP",
            @(SO_TIMESTAMP_MONOTONIC) : @"SO_TIMESTAMP_MONOTONIC",
            @(SO_TYPE) : @"SO_TYPE",
            @(SO_UPCALLCLOSEWAIT) : @"SO_UPCALLCLOSEWAIT",
            @(SO_USELOOPBACK) : @"SO_USELOOPBACK",
            @(SO_WANTMORE) : @"SO_WANTMORE",
            @(SO_WANTOOBFLAG) : @"SO_WANTOOBFLAG",
        };
    }
}


- (BOOL)listenWithBacklog:(int)backlog
                    error:(NSError **)error;
{
    @synchronized (self) {
        int result = listen(_fileDescriptor, backlog);
        if (-1 == result) {
            if (error) *error = [PLGPOSIXError POSIXErrorWithSource:[self description]
                                                       andOperation:@"listen()"];
            return NO;
        } else {
            return YES;
        }
    }
}


- (BOOL)openWithDomain:(int)domain
                  type:(int)type
                 error:(NSError **)error;
{
    return [self openWithDomain:domain type:type protocol:0 error:error];
}


- (BOOL)openWithDomain:(int)domain
                  type:(int)type
              protocol:(int)protocol
                 error:(NSError **)error;
{
    @synchronized (self) {
        _fileDescriptor = socket(domain, type, protocol);
        if (-1 == _fileDescriptor) {
            if (error) *error = [PLGPOSIXError POSIXErrorWithSource:[self description]
                                                       andOperation:@"socket()"];
            return NO;
        } else {
            return YES;
        }
    }
}


- (BOOL)setIntOptionWithName:(int)name
                       value:(int)value
                       error:(NSError **)error;
{
    return [self setOptionWithName:name
                             value:&value
                            length:sizeof(value)
                             error:error];
}


- (BOOL)setOptionWithName:(int)name
                    value:(void const *)value
                   length:(socklen_t)length
                    error:(NSError **)error;
{
    @synchronized (self) {
        int result = setsockopt(_fileDescriptor, SOL_SOCKET, name, value, length);
        if (-1 == result) {
            if (error) *error = [PLGPOSIXError POSIXErrorWithSource:[self description]
                                                       andOperation:@"setsockopt() for %@", socketOptionNames[@(name)]];
            return NO;
        } else {
            return YES;
        }
    }
}


- (BOOL)setReuseAddress:(BOOL)reuseAddress
                  error:(NSError **)error;
{
    return [self setIntOptionWithName:SO_REUSEADDR value:reuseAddress error:error];
}


- (BOOL)setReusePort:(BOOL)reusePort
               error:(NSError **)error;
{
    return [self setIntOptionWithName:SO_REUSEPORT value:reusePort error:error];
}


- (BOOL)shutdown:(int)how
           error:(NSError **)error;
{
    @synchronized (self) {
        int result = shutdown(_fileDescriptor, how);
        if (-1 == result) {
            if (error) *error = [PLGPOSIXError POSIXErrorWithSource:[self description]
                                                       andOperation:@"shutdown() for %@", shutdownHowNames[@(how)]];
            return NO;
        } else {
            return YES;
        }
    }
}


@end
