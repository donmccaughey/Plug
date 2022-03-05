#import "PLGIODispatcher.h"

#import "PLGFileDescriptor.h"
#import "PLGIODispatcherDelegate.h"
#import "PLGPOSIXError.h"


@interface PLGIODispatcher ()

- (void)handleCleanupWithErrorCode:(int)errorCode;

- (void)handleReadDone:(BOOL)done
                  data:(dispatch_data_t)data
             errorCode:(int)errorCode;

- (void)handleWriteData:(dispatch_data_t)dataToWrite
                  range:(NSRange *)rangeWritten
                   done:(BOOL)done
          unwrittenData:(dispatch_data_t)unwrittenData
              errorCode:(int)errorCode;

@end



@implementation PLGIODispatcher
{
    dispatch_io_t _io;
    BOOL _open;
    NSUInteger _unfinishedWriteCount;
    NSUInteger _unwrittenBytes;
}


- (void)close;
{
    id<PLGIODispatcherDelegate> delegate = nil;
    @synchronized (self) {
        if ( ! _open) return;
        _open = NO;
        delegate = _delegate;
    }
    [delegate dispatcherWillClose:self];
    
    @synchronized (self) {
        // TODO: set flags to DISPATCH_IO_STOP if we need to force close
        dispatch_io_close_flags_t flags = 0;
        dispatch_io_close(_io, flags);
    }
}


- (NSString *)description
{
    @synchronized (self) {
        int fileDescriptor = _io ? dispatch_io_get_descriptor(_io) : -1;
        return [NSString stringWithFormat:@"<%@: %p (%i)>",
                [self class], (__bridge void *) self, fileDescriptor];
    }
}


- (void)handleCleanupWithErrorCode:(int)errorCode;
{
    NSError *error = nil;
    id<PLGIODispatcherDelegate> delegate = nil;
    @synchronized (self) {
        if (errorCode) {
            error = [PLGPOSIXError POSIXErrorWithErrorCode:errorCode
                                                    source:[self description]
                                              andOperation:@"dispatch_io_create() cleanup_handler"];
        }
        delegate = _delegate;
    }
    if (error) [delegate dispatcher:self didFailWithError:error];
    [delegate dispatcherDidClose:self];
}


- (void)handleReadDone:(BOOL)done
                  data:(dispatch_data_t)data
             errorCode:(int)errorCode;
{
    NSError *error = nil;
    id<PLGIODispatcherDelegate> delegate = nil;
    @synchronized (self) {
        if (errorCode) {
            error = [PLGPOSIXError POSIXErrorWithErrorCode:errorCode
                                                    source:[self description]
                                              andOperation:@"dispatch_io_read() io_handler"];
        }
        delegate = _delegate;
    }
    if (error) {
        [delegate dispatcher:self didFailWithError:error];
        return;
    }
    if (data && dispatch_data_get_size(data)) {
        [delegate dispatcher:self didReadData:data];
    }
    if (done) {
        [delegate dispatcherDidReadToEnd:self];
    }
}


- (void)handleWriteData:(dispatch_data_t)dataToWrite
                  range:(NSRange *)range
                   done:(BOOL)done
          unwrittenData:(dispatch_data_t)unwrittenData
              errorCode:(int)errorCode;
{
    NSError *error = nil;
    id<PLGIODispatcherDelegate> delegate = nil;
    @synchronized (self) {
        if (errorCode) {
            error = [PLGPOSIXError POSIXErrorWithErrorCode:errorCode
                                                    source:[self description]
                                              andOperation:@"dispatch_io_write() io_handler"];
        } else {
            range->location += range->length;
            if (unwrittenData && dispatch_data_get_size(unwrittenData)) {
                range->length = dispatch_data_get_size(unwrittenData);
            } else {
                range->length = dispatch_data_get_size(dataToWrite) - range->location;
            }
            if (range->length) _unwrittenBytes -= range->length;
            if (done) --_unfinishedWriteCount;
        }
        delegate = _delegate;
    }
    if (error) {
        [delegate dispatcher:self didFailWithError:error];
        return;
    }
    if (range->length) {
        [delegate dispatcher:self didWriteRange:*range ofData:dataToWrite];
    }
    if (done) {
        [delegate dispatcher:self didFinishWritingData:dataToWrite];
    }
}


- (BOOL)isDoneWriting;
{
    @synchronized (self) {
        return 0 == _unfinishedWriteCount;
    }
}


- (BOOL)openWithFileDescriptor:(PLGFileDescriptor *)fileDescriptor
             andCleanupOnQueue:(dispatch_queue_t)cleanupQueue
                         error:(NSError **)error;
{
    @synchronized (self) {
        __weak PLGIODispatcher *weakSelf = self;
        _io = dispatch_io_create(DISPATCH_IO_STREAM, [fileDescriptor intValue], cleanupQueue, ^(int errorCode) {
            [weakSelf handleCleanupWithErrorCode:errorCode];
        });
        if ( ! _io) {
            if (error) *error = [PLGPOSIXError POSIXErrorWithSource:[self description]
                                                       andOperation:@"dispatch_io_create()"];
            return NO;
        }
        _open = YES;
    }
    return YES;
}


- (void)scheduleReadOnQueue:(dispatch_queue_t)readQueue;
{
    @synchronized (self) {
        off_t offset = 0;
        size_t length = SIZE_MAX;
        __weak PLGIODispatcher *weakSelf = self;
        dispatch_io_read(_io, offset, length, readQueue, ^(bool done, dispatch_data_t data, int errorCode) {
            [weakSelf handleReadDone:(done ? YES : NO) data:data errorCode:errorCode];
        });
    }
}


- (void)scheduleWriteWithData:(dispatch_data_t)data
                      onQueue:(dispatch_queue_t)writeQueue;
{
    @synchronized (self) {
        __block dispatch_data_t dataToWrite = data;
        __block NSRange range = NSMakeRange(0, 0);
        off_t offset = 0;
        __weak PLGIODispatcher *weakSelf = self;
        dispatch_io_write(_io, offset, data, writeQueue, ^(bool done, dispatch_data_t unwrittenData, int errorCode) {
            [weakSelf handleWriteData:dataToWrite range:&range done:(done ? YES : NO) unwrittenData:unwrittenData errorCode:errorCode];
        });
        
        _unwrittenBytes += dispatch_data_get_size(data);
        ++_unfinishedWriteCount;
    }
}


- (void)setLowWaterMark:(size_t)lowWaterMark;
{
    @synchronized (self) {
        dispatch_io_set_low_water(_io, lowWaterMark);
    }
}


@end
