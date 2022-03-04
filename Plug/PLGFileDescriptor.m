#import "PLGFileDescriptor.h"

#import "PLGPOSIXError.h"


@implementation PLGFileDescriptor


- (NSError *)close;
{
    @synchronized (self) {
        NSError *error = nil;
        if (_fileDescriptor >= 0) {
            int result = close(_fileDescriptor);
            if (-1 == result) {
                error = [PLGPOSIXError POSIXErrorWithSource:[self description]
                                               andOperation:@"close()"];
            }
            _fileDescriptor = -1;
        }
        return error;
    }
}


- (NSString *)description
{
    @synchronized (self) {
        return [NSString stringWithFormat:@"<%@: %p (%i)>",
                [self class], (__bridge void *)self, _fileDescriptor];
    }
}


- (BOOL)getFlags:(int *)flags
           error:(NSError **)error;
{
    @synchronized (self) {
        *flags = fcntl(_fileDescriptor, F_GETFL);
        if (-1 == *flags) {
            if (error) *error = [PLGPOSIXError POSIXErrorWithSource:[self description]
                                                       andOperation:@"fcntl() for F_GETFL"];
            return NO;
        } else {
            return YES;
        }
    }
}


- (id)init;
{
    return [self initWithFileDescriptor:-1];
}


- (id)initWithFileDescriptor:(int)fileDescriptor;
{
    self = [super init];
    if (!self) return nil;
    
    _fileDescriptor = fileDescriptor;
    
    return self;
}


- (int)intValue;
{
    @synchronized (self) {
        return _fileDescriptor;
    }
}


- (BOOL)isOpen;
{
    @synchronized (self) {
        return -1 != _fileDescriptor;
    }
}


- (BOOL)setFlags:(int)flags
           error:(NSError **)error;
{
    @synchronized (self) {
        int result = fcntl(_fileDescriptor, F_SETFL, flags);
        if (-1 == result) {
            if (error) *error = [PLGPOSIXError POSIXErrorWithSource:[self description]
                                                       andOperation:@"fcntl() for F_SETFL"];
            return NO;
        } else {
            return YES;
        }
    }
}


- (BOOL)setNonBlock:(BOOL)nonBlock
              error:(NSError **)error;
{
    @synchronized (self) {
        int flags = 0;
        if (![self getFlags:&flags error:error]) return NO;
        
        if (nonBlock) {
            flags |= O_NONBLOCK;
        } else {
            flags &= ~O_NONBLOCK;
        }
        
        if (![self setFlags:flags error:error]) return NO;
        
        return YES;
    }
}


@end
