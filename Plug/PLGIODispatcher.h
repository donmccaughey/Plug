#import <Foundation/Foundation.h>


@class PLGFileDescriptor;
@protocol PLGIODispatcherDelegate;


NS_ASSUME_NONNULL_BEGIN


@interface PLGIODispatcher : NSObject

@property (weak) id<PLGIODispatcherDelegate> delegate;

- (void)close;

- (BOOL)isDoneWriting;

- (BOOL)openWithFileDescriptor:(PLGFileDescriptor *)fileDescriptor
             andCleanupOnQueue:(dispatch_queue_t)cleanupQueue
                         error:(NSError **)error;

- (void)scheduleReadOnQueue:(dispatch_queue_t)readQueue;

- (void)scheduleWriteWithData:(dispatch_data_t)data
                      onQueue:(dispatch_queue_t)writeQueue;

- (void)setLowWaterMark:(size_t)lowWaterMark;

@end


NS_ASSUME_NONNULL_END
