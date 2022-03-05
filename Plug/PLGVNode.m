#import "PLGVNode.h"

#import "PLGPOSIXError.h"
#import "PLGVNodeDelegate.h"


@implementation PLGVNode
{
    dispatch_source_t _source;
}


- (NSError *)close;
{
    NSError *error = nil;
    @synchronized (self) {
        error = [super close];
        dispatch_source_cancel(_source);
    }
    return error;
}


- (BOOL)createWithPath:(NSString *)path
                 flags:(int)flags
                  mode:(mode_t)mode
                 error:(NSError **)error;
{
    [self doesNotRecognizeSelector:_cmd];
    return NO;
}


- (BOOL)createWithPath:(NSString *)path
                 flags:(int)flags
                  mode:(mode_t)mode
       andWatchOnQueue:(dispatch_queue_t)queue
                 error:(NSError **)error;
{
    if ( ! [super createWithPath:path flags:flags mode:mode error:error]) return NO;
    return [self watchOnQueue:queue error:error];
}


- (BOOL)openWithPath:(NSString *)path
               flags:(int)flags
               error:(NSError **)error;
{
    [self doesNotRecognizeSelector:_cmd];
    return NO;
}


- (BOOL)openWithPath:(NSString *)path
               flags:(int)flags
     andWatchOnQueue:(dispatch_queue_t)queue
               error:(NSError **)error;
{
    if ( ! [super openWithPath:path flags:flags error:error]) return NO;
    return [self watchOnQueue:queue error:error];
}


- (BOOL)watchOnQueue:(dispatch_queue_t)queue
               error:(NSError **)error;
{
    
    dispatch_source_vnode_flags_t vnodeFlags = DISPATCH_VNODE_DELETE
    | DISPATCH_VNODE_WRITE
    | DISPATCH_VNODE_EXTEND
    | DISPATCH_VNODE_ATTRIB
    | DISPATCH_VNODE_LINK
    | DISPATCH_VNODE_RENAME
    | DISPATCH_VNODE_REVOKE;
    _source = dispatch_source_create(DISPATCH_SOURCE_TYPE_VNODE, (uintptr_t) _fileDescriptor, vnodeFlags, queue);
    if ( ! _source) {
        if (error) *error = [[PLGPOSIXError alloc] initWithSource:[self description] andOperation:@"dispatch_source_create()"];
        return NO;
    }
    
    __weak PLGVNode *weakSelf = self;
    dispatch_source_set_event_handler(_source, ^{
        dispatch_source_vnode_flags_t event = dispatch_source_get_data(self->_source);
        if (event & DISPATCH_VNODE_DELETE) {
            [[weakSelf delegate] vnodeWasDeleted:weakSelf];
        }
        if (event & DISPATCH_VNODE_WRITE) {
            [[weakSelf delegate] vnodeDataDidChange:weakSelf];
        }
        if (event & DISPATCH_VNODE_EXTEND) {
            [[weakSelf delegate] vnodeSizeDidChange:weakSelf];
        }
        if (event & DISPATCH_VNODE_ATTRIB) {
            [[weakSelf delegate] vnodeMetadataDidChange:weakSelf];
        }
        if (event & DISPATCH_VNODE_LINK) {
            [[weakSelf delegate] vnodeLinkCountDidChange:weakSelf];
        }
        if (event & DISPATCH_VNODE_RENAME) {
            [[weakSelf delegate] vnodeWasRenamed:weakSelf];
        }
        if (event & DISPATCH_VNODE_REVOKE) {
            [[weakSelf delegate] vnodeWasRevoked:weakSelf];
        }
    });
    
    
    dispatch_source_set_cancel_handler(_source, ^{
        PLGVNode *vnode = weakSelf;
        if (vnode) vnode->_source = NULL;
        [[weakSelf delegate] vnodeDidClose:weakSelf];
    });
    
    dispatch_resume(_source);
    return YES;
}


@end
