#import "PLGIODispatcherDelegate.h"


@class PLGSocket;
@class PLGSocketAddress;
@protocol PLGConnectionDelegate;


NS_ASSUME_NONNULL_BEGIN


@interface PLGConnection : NSObject<PLGIODispatcherDelegate>

@property (weak) id<PLGConnectionDelegate>delegate;
@property (readonly) PLGSocketAddress *remoteAddress;
@property (readonly) PLGSocketAddress *serverAddress;

- (void)close;

- (id)initWithSocket:(PLGSocket *)socket
       remoteAddress:(PLGSocketAddress *)remoteAddress
    andServerAddress:(PLGSocketAddress *)serverAddress;

- (BOOL)isDoneWriting;

- (BOOL)openWithTimeoutInterval:(NSTimeInterval)timeoutInterval
                   timeoutQueue:(dispatch_queue_t)timeoutQueue
              andCleanupOnQueue:(dispatch_queue_t)cleanupQueue
                          error:(NSError **)error;

- (void)scheduleReadOnQueue:(dispatch_queue_t)readQueue;

- (void)scheduleWriteWithData:(dispatch_data_t)data
                      onQueue:(dispatch_queue_t)writeQueue;

@end


NS_ASSUME_NONNULL_END
