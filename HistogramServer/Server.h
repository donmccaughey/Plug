#import <Plug/Plug.h>


@class Session;
@class PLGListener;


NS_ASSUME_NONNULL_BEGIN


@interface Server : NSObject<PLGListenerDelegate>

@property int exit_status;
@property PLGListener *listener;
@property (copy) NSMutableArray<Session *> *sessions;

- (BOOL)start;

@end


NS_ASSUME_NONNULL_END
