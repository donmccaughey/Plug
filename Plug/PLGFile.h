#import "PLGFileDescriptor.h"


NS_ASSUME_NONNULL_BEGIN


@interface PLGFile : PLGFileDescriptor

- (BOOL)createWithPath:(NSString *)path
                 flags:(int)flags
                  mode:(mode_t)mode
                 error:(NSError **)error;

- (BOOL)openWithPath:(NSString *)path
               flags:(int)flags
               error:(NSError **)error;

@end


NS_ASSUME_NONNULL_END
