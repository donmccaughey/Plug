#import "Entry.h"


@implementation Entry


+ (NSArray<Entry *> *)sortedArrayOfEntriesWithDictionary:(NSDictionary<NSNumber *, NSNumber *> *)dictionary;
{
    NSMutableArray<Entry *> *entries = [NSMutableArray new];
    [dictionary enumerateKeysAndObjectsUsingBlock:^(NSNumber * _Nonnull key, NSNumber * _Nonnull obj, BOOL * _Nonnull stop) {
        Entry *entry = [[Entry alloc] initWithByte:key andCount:obj];
        [entries addObject:entry];
    }];
    NSArray<NSSortDescriptor *> *descriptors = @[
        [NSSortDescriptor sortDescriptorWithKey:@"count" ascending:NO],
        [NSSortDescriptor sortDescriptorWithKey:@"byte" ascending:YES],
    ];
    [entries sortUsingDescriptors:descriptors];
    return entries;
}


- (instancetype)init;
{
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}


- (instancetype)initWithByte:(NSNumber *)byte
                    andCount:(NSNumber *)count;
{
    self = [super init];
    if (!self) return nil;
    
    _byte = byte;
    _count = count;
    
    return self;
}


@end
