#import <Foundation/Foundation.h>


NS_ASSUME_NONNULL_BEGIN


@interface Entry : NSObject

@property NSNumber *byte;
@property NSNumber *count;

+ (NSArray<Entry *> *)sortedArrayOfEntriesWithDictionary:(NSDictionary<NSNumber *, NSNumber *> *)dictionary;

- (instancetype)initWithByte:(NSNumber *)byte
                    andCount:(NSNumber *)count;

@end


NS_ASSUME_NONNULL_END
