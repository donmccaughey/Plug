#import <Foundation/Foundation.h>


@class PLGConnection;


NS_ASSUME_NONNULL_BEGIN


@protocol PLGConnectionDelegate <NSObject>

- (void)connectionDidClose:(PLGConnection *)connection;

- (void)connection:(PLGConnection *)connection
  didFailWithError:(NSError *)error;

- (void)  connection:(PLGConnection *)connection
didFinishWritingData:(dispatch_data_t)data;

- (void)connection:(PLGConnection *)connection
       didReadData:(dispatch_data_t)data;

- (void)connectionDidReadToEnd:(PLGConnection *)connection;

- (void)connectionDidTimeout:(PLGConnection *)connection;

- (void)connection:(PLGConnection *)connection
     didWriteRange:(NSRange)range
            ofData:(dispatch_data_t)data;

@end


NS_ASSUME_NONNULL_END
