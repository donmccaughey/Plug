#import <Foundation/Foundation.h>


@class PLGListener;


NS_ASSUME_NONNULL_BEGIN


@protocol PLGListenerDelegate <NSObject>

- (void)    listener:(PLGListener *)listener
didAcceptConnections:(NSArray *)connections;

- (void)listenerDidClose:(PLGListener *)listener;

- (void)listener:(PLGListener *)listener
didFailWithError:(NSError *)error;

@end


NS_ASSUME_NONNULL_END
