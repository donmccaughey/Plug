#import <Foundation/Foundation.h>


@class PLGIODispatcher;


NS_ASSUME_NONNULL_BEGIN


@protocol PLGIODispatcherDelegate <NSObject>

- (void)dispatcherDidClose:(PLGIODispatcher *)dispatcher;

- (void)dispatcher:(PLGIODispatcher *)dispatcher
  didFailWithError:(NSError *)error;

- (void)  dispatcher:(PLGIODispatcher *)dispatcher
didFinishWritingData:(dispatch_data_t)data;

- (void)dispatcher:(PLGIODispatcher *)dispatcher
       didReadData:(dispatch_data_t)data;

- (void)dispatcherDidReadToEnd:(PLGIODispatcher *)dispatcher;

- (void)dispatcherWillClose:(PLGIODispatcher *)dispatcher;

- (void)dispatcher:(PLGIODispatcher *)dispatcher
     didWriteRange:(NSRange)range
            ofData:(dispatch_data_t)data;

@end


NS_ASSUME_NONNULL_END
