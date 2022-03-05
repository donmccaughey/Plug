#import "PLGTimeout.h"


static void performActionOnTarget(id target, SEL action);


@implementation PLGTimeout
{
    dispatch_source_t _source;
    dispatch_once_t _sourceCreated;
    int64_t _timeoutDelta;
    uint64_t _timeoutLeeway;
}


- (void)dealloc;
{
    dispatch_source_cancel(_source);
}


- (id)init;
{
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}


- (id)initWithTimeout:(NSTimeInterval)timeout
              onQueue:(dispatch_queue_t)queue
            forTarget:(id)target
            andAction:(SEL)action;
{
    self = [super init];
    if (!self) return nil;
    
    if (timeout <= 0.0) {
        [NSException raise:NSInvalidArgumentException
                    format:@"timeout must be > 0.0 (%f given)", timeout];
    }
    NSParameterAssert(queue);
    NSParameterAssert(target);
    NSParameterAssert(action);
    
    _timeoutDelta = (int64_t)(timeout * NSEC_PER_SEC);
    _timeoutLeeway = ((uint64_t)_timeoutDelta) / 8;
    
    _source = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);
    if (!_source) {
        NSLog(@"dispatch_source_create() failed");
        return nil;
    }
    
    __weak id weakTarget = target;
    dispatch_source_set_event_handler(_source, ^{
        performActionOnTarget(weakTarget, action);
    });
    
    return self;
}


- (void)reset;
{
    dispatch_time_t timeoutStart = dispatch_time(DISPATCH_TIME_NOW, _timeoutDelta);
    dispatch_source_set_timer(_source, timeoutStart, DISPATCH_TIME_FOREVER, _timeoutLeeway);
    dispatch_once(&_sourceCreated, ^{
        dispatch_resume(_source);
    });
}


@end


static void performActionOnTarget(id target, SEL action)
{
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
    [target performSelector:action];
#pragma clang diagnostic pop
}
