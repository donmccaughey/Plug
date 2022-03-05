#import <Foundation/Foundation.h>


@class PLGFileDescriptor;
@class PLGVNode;


NS_ASSUME_NONNULL_BEGIN


@protocol PLGVNodeDelegate<NSObject>

- (void)vnodeDataDidChange:(PLGVNode *)vnode;

- (void)vnodeDidClose:(PLGVNode *)vnode;

- (void)vnodeLinkCountDidChange:(PLGVNode *)vnode;

- (void)vnodeMetadataDidChange:(PLGVNode *)vnode;

- (void)vnodeSizeDidChange:(PLGVNode *)vnode;

- (void)vnodeWasDeleted:(PLGVNode *)vnode;

- (void)vnodeWasRenamed:(PLGVNode *)vnode;

- (void)vnodeWasRevoked:(PLGVNode *)vnode;

@end


NS_ASSUME_NONNULL_END
