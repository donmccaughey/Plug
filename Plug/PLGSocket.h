#import "PLGFileDescriptor.h"
#import <sys/socket.h>


@class PLGSocketAddress;


NS_ASSUME_NONNULL_BEGIN


@interface PLGSocket : PLGFileDescriptor

- (PLGSocket *)acceptConnectionWithRemoteAddress:(PLGSocketAddress *_Nullable *_Nullable)remoteAddress
                                           error:(NSError **)error;

- (BOOL)bindToAddress:(PLGSocketAddress *)address
                error:(NSError **)error;

- (BOOL)getLocalAddress:(PLGSocketAddress *_Nullable *_Nonnull)localAddress
                  error:(NSError **)error;

- (BOOL)listenWithBacklog:(int)backlog
                    error:(NSError **)error;

- (BOOL)openWithDomain:(int)domain
                  type:(int)type
                 error:(NSError **)error;

- (BOOL)openWithDomain:(int)domain
                  type:(int)type
              protocol:(int)protocol
                 error:(NSError **)error;

- (BOOL)setIntOptionWithName:(int)name
                       value:(int)value
                       error:(NSError **)error;

- (BOOL)setOptionWithName:(int)name
                    value:(void const *)value
                   length:(socklen_t)length
                    error:(NSError **)error;

- (BOOL)setReuseAddress:(BOOL)reuseAddress
                  error:(NSError **)error;

- (BOOL)setReusePort:(BOOL)reusePort
               error:(NSError **)error;

- (BOOL)shutdown:(int)how
           error:(NSError **)error;

@end


NS_ASSUME_NONNULL_END
