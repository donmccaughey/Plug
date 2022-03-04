#import "PLGInetSocketAddress.h"

#import <arpa/inet.h>


static BOOL dottedDecimalAddressTo_in_addr(NSString *address, struct in_addr *in_addr);


@implementation PLGInetSocketAddress
{
    struct sockaddr_in _sockaddr_in;
}


- (in_addr_t)address;
{
    return ntohl(_sockaddr_in.sin_addr.s_addr);
}


- (struct in_addr)addressStruct;
{
    return _sockaddr_in.sin_addr;
}


+ (id)anyInternetAddressWithPort:(in_port_t)port;
{
    return [[self alloc] initWithAddress:INADDR_ANY andPort:port];
}


+ (id)broadcastInternetAddressWithPort:(in_port_t)port;
{
    return [[self alloc] initWithAddress:INADDR_BROADCAST andPort:port];
}


- (id)copyWithZone:(NSZone *)zone;
{
    return self;
}


- (NSData *)data;
{
    return [NSData dataWithBytes:&_sockaddr_in length:sizeof _sockaddr_in];
}


- (NSString *)description;
{
    return [NSString stringWithFormat:@"%@:%u",
            [self dottedDecimalAddress], (unsigned)[self port]];
}


- (NSString *)dottedDecimalAddress;
{
    return [NSString stringWithCString:inet_ntoa(_sockaddr_in.sin_addr)
                              encoding:NSASCIIStringEncoding];
}


- (sa_family_t)family;
{
    return _sockaddr_in.sin_family;
}


- (NSUInteger)hash;
{
    NSUInteger factor = 31;
    
    NSUInteger hash = factor * 1 + (NSUInteger)_sockaddr_in.sin_addr.s_addr;
    hash = factor * hash + (NSUInteger)_sockaddr_in.sin_family;
    hash = factor * hash + (NSUInteger)_sockaddr_in.sin_len;
    hash = factor * hash + (NSUInteger)_sockaddr_in.sin_port;
    
    return hash;
}


- (id)init;
{
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}


- (id)initWithAddress:(in_addr_t)address
              andPort:(in_port_t)port;
{
    self = [super init];
    if ( ! self) return nil;
    
    _sockaddr_in.sin_len = sizeof _sockaddr_in;
    _sockaddr_in.sin_family = AF_INET;
    _sockaddr_in.sin_addr.s_addr = htonl(address);
    _sockaddr_in.sin_port = htons(port);
    
    return self;
}


- (id)initWithData:(NSData *)sockaddr_inData;
{
    if ([sockaddr_inData length] < sizeof(struct sockaddr_in)) {
        [NSException raise:NSInvalidArgumentException
                    format:@"Expected %lu bytes of struct sockaddr_in data (%lu bytes given)",
         sizeof(struct sockaddr_in), [sockaddr_inData length]];
    }
    
    struct sockaddr_in const *theSockaddr_in = [sockaddr_inData bytes];
    return [self initWithSockaddr_in:theSockaddr_in];
}


- (id)initWithDottedDecimalAddress:(NSString *)address
                           andPort:(in_port_t)port;
{
    struct in_addr in_addr;
    if ( ! dottedDecimalAddressTo_in_addr(address, &in_addr)) return nil;
    
    return [self initWithAddress:ntohl(in_addr.s_addr) andPort:port];
}


- (id)initWithSockaddr:(struct sockaddr const *)sockaddr;
{
    if (AF_INET != sockaddr->sa_family) {
        [NSException raise:NSInvalidArgumentException
                    format:@"Invalid value for sockaddr->sa_family: expected AF_INET (%i) but was %i",
         AF_INET, sockaddr->sa_family];
    }
    
    return [self initWithSockaddr_in:(struct sockaddr_in const *) sockaddr];
}


- (id)initWithSockaddr_in:(struct sockaddr_in const *)sockaddr_in;
{
    self = [super init];
    if ( ! self) return nil;
    
    if (AF_INET != sockaddr_in->sin_family) {
        [NSException raise:NSInternalInconsistencyException
                    format:@"Invalid value for sockaddr_in->sa_family: expected AF_INET (%i) but was %i",
         AF_INET, sockaddr_in->sin_family];
    }
    
    _sockaddr_in.sin_len = sizeof _sockaddr_in;
    _sockaddr_in.sin_family = sockaddr_in->sin_family;
    _sockaddr_in.sin_addr.s_addr = sockaddr_in->sin_addr.s_addr;
    _sockaddr_in.sin_port = sockaddr_in->sin_port;
    
    return self;
}


- (BOOL)isEqualToSocketAddress:(PLGSocketAddress *)socketAddress;
{
    if (self == socketAddress) return YES;
    if ( ! socketAddress) return NO;
    if ( ! [socketAddress isKindOfClass:[PLGInetSocketAddress class]]) return NO;
    
    PLGInetSocketAddress *inetSocketAddress = (PLGInetSocketAddress *) socketAddress;
    if ([self address] != [inetSocketAddress address]) return NO;
    if ([self port] != [inetSocketAddress port]) return NO;
    return YES;
}


+ (BOOL)isValidDottedDecimalAddress:(NSString *)address;
{
    struct in_addr in_addr;
    return dottedDecimalAddressTo_in_addr(address, &in_addr);
}


- (socklen_t)length;
{
    return _sockaddr_in.sin_len;
}


+ (id)loopbackInternetAddressWithPort:(in_port_t)port;
{
    return [[self alloc] initWithAddress:INADDR_LOOPBACK
                                 andPort:port];
}


- (in_port_t)port;
{
    return ntohs(_sockaddr_in.sin_port);
}


- (struct sockaddr const *)sockaddr;
{
    return (struct sockaddr const *)&_sockaddr_in;
}


- (struct sockaddr_in const *)sockaddr_in;
{
    return &_sockaddr_in;
}


@end


static BOOL dottedDecimalAddressTo_in_addr(NSString *address, struct in_addr *in_addr)
{
    char const *asciiAddress = [address cStringUsingEncoding:NSASCIIStringEncoding];
    if ( ! asciiAddress) return NO;
    
    int result = inet_aton(asciiAddress, in_addr);
    if (0 == result) return NO;
    
    return YES;
}
