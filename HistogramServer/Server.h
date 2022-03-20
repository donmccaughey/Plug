#import <Plug/Plug.h>


@class Session;
@class PLGListener;


NS_ASSUME_NONNULL_BEGIN


@interface Server : NSObject<PLGListenerDelegate>

@property (readwrite, copy) NSMutableArray<Session *> *sessions;
@property (readwrite) BOOL failed;
@property (readwrite, copy) PLGListener *listener;

- (BOOL)run;

@end


NS_ASSUME_NONNULL_END
