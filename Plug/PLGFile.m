#import "PLGFile.h"

#import "PLGPOSIXError.h"


@implementation PLGFile


- (BOOL)createWithPath:(NSString *)path
                 flags:(int)flags
                  mode:(mode_t)mode
                 error:(NSError **)error;
{
    flags |= O_CREAT;
    @synchronized (self) {
        _fileDescriptor = open([path fileSystemRepresentation], flags, mode);
        if (-1 == _fileDescriptor) {
            if (error) *error = [PLGPOSIXError POSIXErrorWithSource:[self description]
                                                       andOperation:@"open()"];
            return NO;
        } else{
            return YES;
        }
    }
}


- (BOOL)openWithPath:(NSString *)path
               flags:(int)flags
               error:(NSError **)error;
{
    @synchronized (self) {
        _fileDescriptor = open([path fileSystemRepresentation], flags);
        if (-1 == _fileDescriptor) {
            if (error) *error = [PLGPOSIXError POSIXErrorWithSource:[self description]
                                                       andOperation:@"open()"];
            return NO;
        } else{
            return YES;
        }
    }
}


@end
