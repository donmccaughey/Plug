#import <Foundation/Foundation.h>
#import <sys/socket.h>


NS_ASSUME_NONNULL_BEGIN


@interface PLGSocketAddress : NSObject <NSCoding, NSCopying>

- (NSData *)data;

- (sa_family_t)family;

- (NSString *)familyName;

+ (NSString *)familyNameForFamily:(sa_family_t)family;

- (id)initWithData:(NSData *)sockaddrData;

- (id)initWithSockaddr:(struct sockaddr const *)sockaddr;

- (BOOL)isEqualToSocketAddress:(PLGSocketAddress *)socketAddress;

- (socklen_t)length;

- (struct sockaddr const *)sockaddr;

@end


NS_ASSUME_NONNULL_END
