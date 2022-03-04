#import "PLGSocketAddress.h"

#import "PLGInetSocketAddress.h"


static NSDictionary *familyNames;


@implementation PLGSocketAddress


- (id)copyWithZone:(NSZone *)zone;
{
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}


- (NSData *)data;
{
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}


- (void)encodeWithCoder:(NSCoder *)encoder;
{
    [encoder encodeDataObject:[self data]];
}


- (sa_family_t)family;
{
    [self doesNotRecognizeSelector:_cmd];
    return 0;
}


- (NSString *)familyName;
{
    return [[self class] familyNameForFamily:[self family]];
}


+ (NSString *)familyNameForFamily:(sa_family_t)family;
{
    NSString *familyName = familyNames[@(family)];
    return familyName ? familyName : [NSString stringWithFormat:@"%u", (unsigned) family];
}


- (NSUInteger)hash;
{
    [self doesNotRecognizeSelector:_cmd];
    return 0;
}


- (id)init;
{
    if ([self isMemberOfClass:[PLGSocketAddress class]]) {
        [self doesNotRecognizeSelector:_cmd];
    }
    
    self = [super init];
    if ( ! self) return nil;
    
    return self;
}


+ (void)initialize;
{
    if ([PLGSocketAddress class] == self) {
        familyNames = @{
            @AF_UNSPEC : @"AF_UNSPEC",
            @AF_UNIX : @"AF_UNIX",
            @AF_INET : @"AF_INET",
            @AF_IMPLINK : @"AF_IMPLINK",
            @AF_PUP : @"AF_PUP",
            @AF_CHAOS : @"AF_CHAOS",
            @AF_NS : @"AF_NS",
            @AF_ISO : @"AF_ISO",
            @AF_ECMA : @"AF_ECMA",
            @AF_DATAKIT : @"AF_DATAKIT",
            @AF_CCITT : @"AF_CCITT",
            @AF_SNA : @"AF_SNA",
            @AF_DECnet : @"AF_DECnet",
            @AF_DLI : @"AF_DLI",
            @AF_LAT : @"AF_LAT",
            @AF_HYLINK : @"AF_HYLINK",
            @AF_APPLETALK : @"AF_APPLETALK",
            @AF_ROUTE : @"AF_ROUTE",
            @AF_LINK : @"AF_LINK",
            @pseudo_AF_XTP : @"pseudo_AF_XTP",
            @AF_COIP : @"AF_COIP",
            @AF_CNT : @"AF_CNT",
            @pseudo_AF_RTIP : @"pseudo_AF_RTIP",
            @AF_IPX : @"AF_IPX",
            @AF_SIP : @"AF_SIP",
            @pseudo_AF_PIP : @"pseudo_AF_PIP",
            @AF_NDRV : @"AF_NDRV",
            @AF_ISDN : @"AF_ISDN",
            @pseudo_AF_KEY : @"pseudo_AF_KEY",
            @AF_INET6 : @"AF_INET6",
            @AF_NATM : @"AF_NATM",
            @AF_SYSTEM : @"AF_SYSTEM",
            @AF_NETBIOS : @"AF_NETBIOS",
            @AF_PPP : @"AF_PPP",
            @pseudo_AF_HDRCMPLT : @"pseudo_AF_HDRCMPLT",
            @AF_RESERVED_36 : @"AF_RESERVED_36",
            @AF_IEEE80211 : @"AF_IEEE80211",
            @AF_UTUN : @"AF_UTUN",
            @AF_MAX : @"AF_MAX",
        };
    }
}


- (id)initWithCoder:(NSCoder *)decoder;
{
    NSData *sockaddr_inData = [decoder decodeDataObject];
    return [self initWithData:sockaddr_inData];
}


- (id)initWithData:(NSData *)sockaddrData;
{
    if ([sockaddrData length] < sizeof(struct sockaddr)) {
        NSLog(@"Expected at least %lu bytes but sockaddrData only has %lu bytes",
              sizeof(struct sockaddr), [sockaddrData length]);
        return nil;
    }
    
    struct sockaddr const *sockaddr = [sockaddrData bytes];
    return [self initWithSockaddr:sockaddr];
}


- (id)initWithSockaddr:(struct sockaddr const *)sockaddr;
{
    if (sockaddr->sa_family == AF_INET) {
        struct sockaddr_in const *sockaddr_in = (struct sockaddr_in const *) sockaddr;
        return [[PLGInetSocketAddress alloc] initWithSockaddr_in:sockaddr_in];
    } else if (sockaddr->sa_family == AF_INET6) {
        // TODO: implement IPV6SocketAddress
        [NSException raise:@"Not Implemented"
                    format:@"Address family AF_INET6 not implemented"];
        return nil;
    } else if (sockaddr->sa_family == AF_UNIX) {
        // TODO: implement UnixSocketAddress
        [NSException raise:@"Not Implemented"
                    format:@"Address family AF_UNIX not implemented"];
        return nil;
    } else {
        [NSException raise:NSInvalidArgumentException
                    format:@"Address family %@ not supported",
         [[self class] familyNameForFamily:sockaddr->sa_family]];
        return nil;
    }
}


- (BOOL)isEqual:(id)object;
{
    if (self == object) return YES;
    if (!object) return NO;
    if (![object isKindOfClass:[PLGSocketAddress class]]) return NO;
    return [self isEqualToSocketAddress:object];
}


- (BOOL)isEqualToSocketAddress:(PLGSocketAddress *)socketAddress;
{
    [self doesNotRecognizeSelector:_cmd];
    return NO;
}


- (socklen_t)length;
{
    [self doesNotRecognizeSelector:_cmd];
    return 0;
}


- (struct sockaddr const *)sockaddr;
{
    [self doesNotRecognizeSelector:_cmd];
    return NULL;
}


@end
