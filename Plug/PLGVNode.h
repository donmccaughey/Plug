#import "PLGFile.h"


@protocol PLGVNodeDelegate;


NS_ASSUME_NONNULL_BEGIN


@interface PLGVNode : PLGFile

@property (weak) id<PLGVNodeDelegate> delegate;

- (BOOL)createWithPath:(NSString *)path
                 flags:(int)flags
                  mode:(mode_t)mode
       andWatchOnQueue:(dispatch_queue_t)queue
                 error:(NSError **)error;

- (BOOL)openWithPath:(NSString *)path
               flags:(int)flags
     andWatchOnQueue:(dispatch_queue_t)queue
               error:(NSError **)error;

- (BOOL)watchOnQueue:(dispatch_queue_t)queue
               error:(NSError **)error;

@end


NS_ASSUME_NONNULL_END
