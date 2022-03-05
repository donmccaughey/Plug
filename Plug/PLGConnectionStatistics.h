#import <Foundation/Foundation.h>


NS_ASSUME_NONNULL_BEGIN


@interface PLGConnectionStatistics : NSObject<NSCopying>

@property (assign, nonatomic) uint64_t bytesRead;
@property (assign, nonatomic) uint64_t bytesWritten;
@property (assign, nonatomic) uint32_t readCount;
@property (assign, nonatomic) uint32_t writeCount;

@end


NS_ASSUME_NONNULL_END
