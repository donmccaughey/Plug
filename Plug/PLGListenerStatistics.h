#import <Foundation/Foundation.h>


NS_ASSUME_NONNULL_BEGIN


@interface PLGListenerStatistics : NSObject<NSCopying>

@property (assign, nonatomic) uint32_t acceptedConnectionCount;
@property (assign, nonatomic) uint32_t failedConnectionCount;

@end


NS_ASSUME_NONNULL_END
