#import "PLGConnectionStatistics.h"


@implementation PLGConnectionStatistics


- (id)copyWithZone:(NSZone *)zone;
{
    PLGConnectionStatistics *copy = [[PLGConnectionStatistics alloc] init];
    
    copy->_bytesRead = _bytesRead;
    copy->_bytesWritten = _bytesWritten;
    copy->_readCount = _readCount;
    copy->_writeCount = _writeCount;
    
    return copy;
}


@end
