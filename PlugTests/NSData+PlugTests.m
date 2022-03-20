#import <XCTest/XCTest.h>
#import <Plug/Plug.h>


@interface NSData_PlugTests : XCTestCase
@end


@implementation NSData_PlugTests


- (void)testDispatchDataOnQueue;
{
    NSData *data = [@"The rain in Spain falls mainly on the plains." dataUsingEncoding:NSUTF8StringEncoding];
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_data_t ddata = [data dispatchDataOnQueue:queue];
    XCTAssertEqual(dispatch_data_get_size(ddata), data.length);
    dispatch_data_apply(ddata, ^bool(dispatch_data_t  _Nonnull region, size_t offset, const void * _Nonnull buffer, size_t size) {
        XCTAssert(0 == memcmp(buffer, data.bytes + offset, size));
    });
}


- (void)testDispatchDataOnQueue_when_empty;
{
    NSData *data = [NSData new];
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_data_t ddata = [data dispatchDataOnQueue:queue];
    XCTAssertEqual(dispatch_data_get_size(ddata), data.length);
}


@end
