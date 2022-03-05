#import <Foundation/Foundation.h>


@class PLGSocketAddress;
@protocol PLGListenerDelegate;


NS_ASSUME_NONNULL_BEGIN


@interface PLGListener : NSObject

@property (weak) id<PLGListenerDelegate> delegate;
@property (readonly) PLGSocketAddress *serverAddress;

- (void)close;

- (id)initWithServerAddress:(PLGSocketAddress *)serverAddress;

- (BOOL)openOnQueue:(dispatch_queue_t)queue
              error:(NSError **)error;

- (BOOL)openWithBacklog:(int)backlog
                onQueue:(dispatch_queue_t)queue
                  error:(NSError **)error;

@end


NS_ASSUME_NONNULL_END
