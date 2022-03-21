#import <Plug/Plug.h>
#import "Server.h"


int main(int argc, const char * argv[]) {
    @autoreleasepool {
        Server *server = [Server new];
        if (!server) return EXIT_FAILURE;
        if (![server start]) return EXIT_FAILURE;
        dispatch_main();
    }
    return EXIT_SUCCESS;
}
