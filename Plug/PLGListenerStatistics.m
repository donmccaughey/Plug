#import "PLGListenerStatistics.h"


@implementation PLGListenerStatistics


- (id)copyWithZone:(NSZone *)zone;
{
    PLGListenerStatistics *copy = [[PLGListenerStatistics alloc] init];
    
    copy->_acceptedConnectionCount = _acceptedConnectionCount;
    copy->_failedConnectionCount = _failedConnectionCount;
    
    return copy;
}


@end
