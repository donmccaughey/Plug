#import <Foundation/Foundation.h>


NS_ASSUME_NONNULL_BEGIN


@interface PLGTimeout : NSObject

- (id)initWithTimeout:(NSTimeInterval)timeout
              onQueue:(dispatch_queue_t)queue
            forTarget:(id)target
            andAction:(SEL)action;

- (void)reset;

@end


NS_ASSUME_NONNULL_END
