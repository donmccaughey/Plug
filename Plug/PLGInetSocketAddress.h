#import "PLGSocketAddress.h"


NS_ASSUME_NONNULL_BEGIN


@interface PLGInetSocketAddress : PLGSocketAddress

- (in_addr_t)address;

- (struct in_addr)addressStruct;

+ (id)anyInternetAddressWithPort:(in_port_t)port;

+ (id)broadcastInternetAddressWithPort:(in_port_t)port;

- (NSString *)dottedDecimalAddress;

- (id)initWithAddress:(in_addr_t)address
              andPort:(in_port_t)port;

- (id)initWithData:(NSData *)sockaddr_inData;

- (id)initWithDottedDecimalAddress:(NSString *)address
                           andPort:(in_port_t)port;

- (id)initWithSockaddr_in:(struct sockaddr_in const *)sockaddr_in;

+ (BOOL)isValidDottedDecimalAddress:(NSString *)address;

+ (id)loopbackInternetAddressWithPort:(in_port_t)port;

- (in_port_t)port;

- (struct sockaddr_in const *)sockaddr_in;

@end


NS_ASSUME_NONNULL_END
