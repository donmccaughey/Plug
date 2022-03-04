#import "PLGPOSIXError.h"


NSString *const PLGOperationErrorKey = @"PLGOperation";
NSString *const PLGSourceErrorKey = @"PLGSource";

static NSDictionary *errorNames;


@implementation PLGPOSIXError


- (NSString *)description;
{
    NSString *errorName = errorNames[@([self code])];
    int errorCode = (int) [self code];
    return [NSString stringWithFormat:@"%@ Code=%@ (%i) \"%s\" Source=%@ Operation=\"%@\"",
            [self class], errorName, errorCode, strerror(errorCode),
            [self source], [self operation]];
}


- (id)init;
{
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}


+ (void)initialize;
{
    if ([PLGPOSIXError class] == self) {
        errorNames = @{
            @EPERM : @"EPERM",
            @ENOENT : @"ENOENT",
            @ESRCH : @"ESRCH",
            @EINTR : @"EINTR",
            @EIO : @"EIO",
            @ENXIO : @"ENXIO",
            @E2BIG : @"E2BIG",
            @ENOEXEC : @"ENOEXEC",
            @EBADF : @"EBADF",
            @ECHILD : @"ECHILD",
            @EDEADLK : @"EDEADLK",
            @ENOMEM : @"ENOMEM",
            @EACCES : @"EACCES",
            @EFAULT : @"EFAULT",
            @ENOTBLK : @"ENOTBLK",
            @EBUSY : @"EBUSY",
            @EEXIST : @"EEXIST",
            @EXDEV : @"EXDEV",
            @ENODEV : @"ENODEV",
            @ENOTDIR : @"ENOTDIR",
            @EISDIR : @"EISDIR",
            @EINVAL : @"EINVAL",
            @ENFILE : @"ENFILE",
            @EMFILE : @"EMFILE",
            @ENOTTY : @"ENOTTY",
            @ETXTBSY : @"ETXTBSY",
            @EFBIG : @"EFBIG",
            @ENOSPC : @"ENOSPC",
            @ESPIPE : @"ESPIPE",
            @EROFS : @"EROFS",
            @EMLINK : @"EMLINK",
            @EPIPE : @"EPIPE",
            @EDOM : @"EDOM",
            @ERANGE : @"ERANGE",
            @EAGAIN : @"EAGAIN",
            @EINPROGRESS : @"EINPROGRESS",
            @EALREADY : @"EALREADY",
            @ENOTSOCK : @"ENOTSOCK",
            @EDESTADDRREQ : @"EDESTADDRREQ",
            @EMSGSIZE : @"EMSGSIZE",
            @EPROTOTYPE : @"EPROTOTYPE",
            @ENOPROTOOPT : @"ENOPROTOOPT",
            @EPROTONOSUPPORT : @"EPROTONOSUPPORT",
            @ESOCKTNOSUPPORT : @"ESOCKTNOSUPPORT",
            @ENOTSUP : @"ENOTSUP",
            @EPFNOSUPPORT : @"EPFNOSUPPORT",
            @EAFNOSUPPORT : @"EAFNOSUPPORT",
            @EADDRINUSE : @"EADDRINUSE",
            @EADDRNOTAVAIL : @"EADDRNOTAVAIL",
            @ENETDOWN : @"ENETDOWN",
            @ENETUNREACH : @"ENETUNREACH",
            @ENETRESET : @"ENETRESET",
            @ECONNABORTED : @"ECONNABORTED",
            @ECONNRESET : @"ECONNRESET",
            @ENOBUFS : @"ENOBUFS",
            @EISCONN : @"EISCONN",
            @ENOTCONN : @"ENOTCONN",
            @ESHUTDOWN : @"ESHUTDOWN",
            @ETOOMANYREFS : @"ETOOMANYREFS",
            @ETIMEDOUT : @"ETIMEDOUT",
            @ECONNREFUSED : @"ECONNREFUSED",
            @ELOOP : @"ELOOP",
            @ENAMETOOLONG : @"ENAMETOOLONG",
            @EHOSTDOWN : @"EHOSTDOWN",
            @EHOSTUNREACH : @"EHOSTUNREACH",
            @ENOTEMPTY : @"ENOTEMPTY",
            @EPROCLIM : @"EPROCLIM",
            @EUSERS : @"EUSERS",
            @EDQUOT : @"EDQUOT",
            @ESTALE : @"ESTALE",
            @EREMOTE : @"EREMOTE",
            @EBADRPC : @"EBADRPC",
            @ERPCMISMATCH : @"ERPCMISMATCH",
            @EPROGUNAVAIL : @"EPROGUNAVAIL",
            @EPROGMISMATCH : @"EPROGMISMATCH",
            @EPROCUNAVAIL : @"EPROCUNAVAIL",
            @ENOLCK : @"ENOLCK",
            @ENOSYS : @"ENOSYS",
            @EFTYPE : @"EFTYPE",
            @EAUTH : @"EAUTH",
            @ENEEDAUTH : @"ENEEDAUTH",
            @EPWROFF : @"EPWROFF",
            @EDEVERR : @"EDEVERR",
            @EOVERFLOW : @"EOVERFLOW",
            @EBADEXEC : @"EBADEXEC",
            @EBADARCH : @"EBADARCH",
            @ESHLIBVERS : @"ESHLIBVERS",
            @EBADMACHO : @"EBADMACHO",
            @ECANCELED : @"ECANCELED",
            @EIDRM : @"EIDRM",
            @ENOMSG : @"ENOMSG",
            @EILSEQ : @"EILSEQ",
            @ENOATTR : @"ENOATTR",
            @EBADMSG : @"EBADMSG",
            @EMULTIHOP : @"EMULTIHOP",
            @ENODATA : @"ENODATA",
            @ENOLINK : @"ENOLINK",
            @ENOSR : @"ENOSR",
            @ENOSTR : @"ENOSTR",
            @EPROTO : @"EPROTO",
            @ETIME : @"ETIME",
            @EOPNOTSUPP : @"EOPNOTSUPP",
            @ENOPOLICY : @"ENOPOLICY",
            @ENOTRECOVERABLE : @"ENOTRECOVERABLE",
            @EOWNERDEAD : @"EOWNERDEAD",
            @EQFULL : @"EQFULL",
        };
    }
}


- (id)initWithErrorCode:(int)errorCode
                 source:(NSString *)source
           andOperation:(NSString *)format, ...;
{
    va_list arguments;
    va_start(arguments, format);
    id posixError = [self initWithErrorCode:errorCode
                                     source:source
                                  operation:format
                               andArguments:arguments];
    va_end(arguments);
    return posixError;
}


- (id)initWithErrorCode:(int)errorCode
                 source:(NSString *)source
              operation:(NSString *)format
           andArguments:(va_list)arguments;
{
    NSString *operation = nil;
    if (format) {
        operation = [[NSString alloc] initWithFormat:format
                                           arguments:arguments];
    } else {
        operation = @"(unspecified)";
    }
    NSDictionary *userInfo = @{
        PLGSourceErrorKey : [source copy],
        PLGOperationErrorKey : [operation copy],
    };
    self = [super initWithDomain:NSPOSIXErrorDomain
                            code:errorCode
                        userInfo:userInfo];
    if ( ! self) return nil;
    
    return self;
}


- (id)initWithSource:(NSString *)source
        andOperation:(NSString *)format, ...;
{
    va_list arguments;
    va_start(arguments, format);
    id posixError = [self initWithSource:source
                               operation:format
                            andArguments:arguments];
    va_end(arguments);
    return posixError;
}


- (id)initWithSource:(NSString *)source
           operation:(NSString *)format
        andArguments:(va_list)arguments;
{
    return [self initWithErrorCode:errno source:source
                         operation:format
                      andArguments:arguments];
}


- (NSString *)operation;
{
    return [self userInfo][PLGOperationErrorKey];
}


+ (id)POSIXErrorWithErrorCode:(int)errorCode
                       source:(NSString *)source
                 andOperation:(NSString *)format, ...;
{
    va_list arguments;
    va_start(arguments, format);
    id posixError = [[self alloc] initWithErrorCode:errorCode
                                             source:source
                                          operation:format
                                       andArguments:arguments];
    va_end(arguments);
    return posixError;
}


+ (id)POSIXErrorWithSource:(NSString *)source
              andOperation:(NSString *)format, ...;
{
    va_list arguments;
    va_start(arguments, format);
    id posixError = [[self alloc] initWithSource:source
                                       operation:format
                                    andArguments:arguments];
    va_end(arguments);
    return posixError;
}


- (NSString *)source;
{
    return [self userInfo][PLGSourceErrorKey];
}


@end
