#import <Foundation/Foundation.h>


NS_ASSUME_NONNULL_BEGIN


extern NSString *const PLGSourceErrorKey;
extern NSString *const PLGOperationErrorKey;


@interface PLGPOSIXError : NSError

- (id)initWithErrorCode:(int)errorCode
                 source:(NSString *)source
           andOperation:(NSString *)format, ...;

- (id)initWithErrorCode:(int)errorCode
                 source:(NSString *)source
              operation:(NSString *)format
           andArguments:(va_list)arguments;

- (id)initWithSource:(NSString *)source
        andOperation:(NSString *)format, ...;

- (id)initWithSource:(NSString *)source
           operation:(NSString *)format
        andArguments:(va_list)arguments;

- (NSString *)operation;

+ (id)POSIXErrorWithErrorCode:(int)errorCode
                       source:(NSString *)source
                 andOperation:(NSString *)format, ...;

+ (id)POSIXErrorWithSource:(NSString *)source
              andOperation:(NSString *)format, ...;

- (NSString *)source;

@end


NS_ASSUME_NONNULL_END
