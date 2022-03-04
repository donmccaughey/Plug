#import <Foundation/Foundation.h>


NS_ASSUME_NONNULL_BEGIN


@interface PLGFileDescriptor : NSObject
{
    int _fileDescriptor;
}

- (NSError *)close;

- (BOOL)getFlags:(int *)flags
           error:(NSError **)error;

- (id)initWithFileDescriptor:(int)fileDescriptor;

- (int)intValue;

- (BOOL)isOpen;

- (BOOL)setFlags:(int)flags
           error:(NSError **)error;

- (BOOL)setNonBlock:(BOOL)nonBlock
              error:(NSError **)error;

@end


NS_ASSUME_NONNULL_END
