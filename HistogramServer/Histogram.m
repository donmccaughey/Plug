#import "Histogram.h"

#include <Plug/Plug.h>
#include "Entry.h"


@implementation Histogram


- (void)addData:(nonnull dispatch_data_t)data
 shouldReadMore:(nonnull BOOL *)shouldReadMore;
{
    dispatch_data_apply(data, ^(dispatch_data_t region, size_t offset, void const *buffer, size_t size) {
        *shouldReadMore = YES;
        char const *bytes = buffer;
        for (size_t i = 0; i < size; ++i) {
            char byte = bytes[i];
            if ('\n' == byte) {
                *shouldReadMore = NO;
                return (bool)false;
            }
            NSNumber *ch = [NSNumber numberWithChar:byte];
            NSUInteger count = [_counts[ch] unsignedIntegerValue] + 1;
            _counts[ch] = [NSNumber numberWithUnsignedInteger:count];
            ++_bytesCounted;
            if (_bytesCounted > 1024) *shouldReadMore = NO;
        }
        return (bool)true;
    });
}


- (dispatch_data_t)generateReport;
{
    NSMutableString *report = [NSMutableString new];
    [report appendString:@"Value, Char, Count\n"];
    NSArray<Entry *> *entries = [Entry sortedArrayOfEntriesWithDictionary:_counts];
    for (Entry *entry in entries) {
        NSUInteger chValue = [entry.byte unsignedIntegerValue];
        char ch = ' ';
        if (chValue >= ' ' && chValue <= '~') {
            ch = (char)chValue;
        }
        NSUInteger count = [entry.count unsignedIntegerValue];
        [report appendFormat:@"%5lu,    %C, %5lu\n", chValue, ch, count];
    }
    NSData *ascii = [report dataUsingEncoding:NSASCIIStringEncoding];
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    return [ascii dispatchDataOnQueue:queue];
}


- (instancetype)init;
{
    self = [super init];
    if (!self) return nil;
    
    _bytesCounted = 0;
    _counts = [NSMutableDictionary new];
    
    return self;
}


@end
