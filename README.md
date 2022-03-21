# Plug

_Plug_ is an Objective-C framework for building TCP services.  It builds on
Apple's [Grand Central Dispatch][1] (GCD) system, particularly
[`dispatch_source_t`][2] and [`dispatch_io_t`][3] to provide a higher-level way
to build socket servers that use GCD for concurrency.  Plug is currently tested
on macOS only -- [YMMV][4] on iOS.  (Running a TCP server on iOS is unusual but
not unprecedented; let me know if iOS support would be useful to you.)

[1]: https://developer.apple.com/documentation/dispatch?language=objc
[2]: https://developer.apple.com/documentation/dispatch/dispatch_source?language=objc
[3]: https://developer.apple.com/documentation/dispatch/dispatch_i_o?language=objc
[4]: https://idioms.thefreedictionary.com/your+mileage+may+vary


## Building

_Plug_ includes an Xcode project that builds a [framework][5] and a static
library.  You can embed _Plug_'s project in your Xcode project using git
submodules, then add _Plug_ as a linked framework.  (The steps in [_Add a
Framework to an iOS App_][6] are the same for macOS.)  If you prefer to
statically link to _Plug_, add `libplug.a` to your target in Xcode under
_General | Frameworks and Libraries_ and make sure to also add the `-ObjC` flag
to your target under _Build Settings | Other Linker Flags_ so that the `NSData
(Plug)` category is correctly linked.

[5]: https://developer.apple.com/library/archive/documentation/MacOSX/Conceptual/BPFrameworks/Concepts/WhatAreFrameworks.html
[6]: https://medium.com/build-an-app-like-lego/add-a-framework-to-an-ios-app-45c06e39bf23


## History

_Plug_ is extracted from an internal app I created many years ago for [Able Pear
Software][7], an iOS-focused consultancy I founded and ran for about eight
years.  It was part of an HTTP application server I wrote in Objective-C and
ran on Able Pear's Mac mini, which we hosted at [Macminicolo][8].  Though most
of the app code was specific to Able Pear and not worth making open source,
_Plug_ (originally called _PSocket_) is a nice, well-factored module that I'm
quite proud of.  Caveat emptor: though I used it in "production", _Plug_ only
supported one application running on one server with one user, and it had an
nginx proxy between it and the Internet.  If you incorporate _Plug_ in your
system, test thoroughly, monitor closely and use a battle-tested proxy if you
have ports open to the public.

[7]: http://blog.ablepear.com
[8]: https://macminicolo.net


## License

_Plug_ is available under a BSD-style license.  See the [`LICENSE.md`][9] file
for details.

[9]: https://github.com/donmccaughey/Plug/blob/main/LICENSE.md


## Class Hierarchy

### Errors

- `PLGPOSIXError`: wraps an `errno` value and gives it an `NSError` interface.
  This class is not used directly, but methods of _Plug_ classes that wrap POSIX
  functions will return these objects as `NSError **` out-params. 

### Socket Addresses

This [class cluster][10] wraps the `sockaddr` family of [type punning][11]
structs used for socket addresses.

- `PLGSocketAddress`: defines the generic interface to a socket address and has
  the polymorphic initializers `-initWithData:` and `-initWithSockaddr:`.

- `PLGInetSocketAddress`: concrete wrapper around a `sockaddr_in` struct that
  holds an IPv4 socket address.

- `PLGUnixSocketAddress`: concrete wrapper around a `sockaddr_un` struct that
  holds a Unix domain socket address.

- `PLGInet6SocketAddress`: concrete wrapper around a `sockaddr_in6` struct that
  holds an IPv6 socket address.

[10]: https://developer.apple.com/library/archive/documentation/General/Conceptual/CocoaEncyclopedia/ClassClusters/ClassClusters.html
[11]: https://en.wikipedia.org/wiki/Type_punning

### File Descriptors

File descriptors are integers used as handles to file-like objects in Unix,
including disk files, network sockets and pseudo-devices like `/dev/null`.  This
small class hierarchy provides interfaces for the different file-like objects.

- `PLGFileDescriptor`: wraps the file descriptor `int` and provides methods for
  common functions like `fcntl()` and `close()`.

- `PLGFile`: any file descriptor that can be created by `open()`.

- `PLGVNode`: a `PLGFile` that receives file system events (write, delete,
  rename, etc).

- `PLGVNodeDelegate`: protocol for an object that handles file system events.

- `PLGSocket`: any file descriptor that can be created by `socket()` or
  returned by `accept()`.

### Listening for Connections

The `PLGListener` class creates objects that listen on an address and accept
connections as they come in.  It will do its work on a given dispatch queue.
Internally, it pairs a `PLGSocket` with a `dispatch_source_t`.

- `PLGListener`: listens on a given `PLGSocketAddress`.

- `PLGListenerDelegate`: protocol for an object that handles listener events.

### Timer

- `PLGTimout`: provides a wrapper around a `DISPATCH_SOURCE_TYPE_TIMER` with a
  target-action interface.

### Asynchronous Reading and Writing

- `PLGIODispatcher`: wraps a `dispatch_io_t` struct used to schedule
  asynchronous reads and writes to a file descriptor.

- `PLGIODispatcherDelegate`: protocol for an object that handles asynchronous
  read and write events.

### Connections

The `PLGConnection` class represents a single read-write socket connection.  It
wraps a `PLGSocket`, a `PLGIODispatcher` and a `PLGTimeout`, and implements the
`PLGIODispatcherDelegate` protocol.

- `PLGConnection`: an open client-server socket connection that performs
  asynchronous reads and writes.

- `PLGConnectionDelegate`: protocol for an object that handles connection
  events.

### Utilities

The `NSData (Plug)` category adds the `-dispatchDataOnQueue:` method to
`NSData` for easy conversion to `dispatch_data_t`.  The given dispatch queue
specifies where the dispatch data destructor block will run.


## HistogramServer Example

The `HistogramServer` shows how to build a simple request-response TCP server
using _Plug_.  The client sends a string ending with a new line ('\n') to the
server on port 2000.  You can use netcat (`nc`) as the client:

        $ nc -v localhost 2000
        Connection to localhost port 2000 [tcp/callbook] succeeded!
        $ The rain in Spain stays mainly in the plain.⏎

The `HistogramServer` responds with a table of character frequencies and 
closes the connection:

        Value, Char, Count
           32,     ,     8
          105,    i,     6
          110,    n,     6
           97,    a,     5
          101,    e,     2
          104,    h,     2
          108,    l,     2
          112,    p,     2
          115,    s,     2
          116,    t,     2
          121,    y,     2
           46,    .,     1
           83,    S,     1
           84,    T,     1
          109,    m,     1
          114,    r,     1

### Example Architecture

The `HistogramServer` shows the typical architecture of a server built with
_Plug_.  There are four classes in `HistogramServer`: `Entry`, `Histogram`,
`Server` and `Session` plus the `main()` function.  Of these, `Entry` and
`Histogram` are domain classes specific to handling our "histogram protocol".
Of general interest are `main()`, `Server` and `Session`.

     +--------+     +--------------+
     | Server |-----| PLGListeners |....+
     +--------+     +--------------+    :
         |                              :
    +----------+    +---------------+   :
    | Sessions |----| PLGConnection |<..+
    +----------+    +---------------+
         |
    +-----------+
    | Histogram |
    +-----------+

At a high level, the server is a container of listeners and sessions.  Listeners
provide connections to the server, which wraps each connection in a session.
Sessions also contain the code for processing our protocol, represented by the
`Histogram` class in this example.

#### The `main()` Function

Like most C/C++/Objective-C programs, `main()` is where execution starts.  The
main function for the `HistogramServer` looks like this:

        int main(int argc, const char * argv[]) {
            @autoreleasepool {
                Server *server = [Server new];
                if (!server) return EXIT_FAILURE;
                if (![server run]) return EXIT_FAILURE;
                dispatch_main();
            }
            return EXIT_SUCCESS;
        }

Things you typically do in `main()` include:

 - create the top-level [autorelease pool][12]
 - parse command line arguments
 - load configuration files
 - initialize and start the server
 - call [`dispatch_main()`][13] to start the GCD run loop

[12]: https://developer.apple.com/documentation/foundation/nsautoreleasepool
[13]: https://developer.apple.com/documentation/dispatch/1452860-dispatch_main

If you do a lot of initialization and setup work before you start your server,
you may want to put a nested autorelease block around that start up code:

        @autoreleasepool {
            Server *server = nil;
            @autoreleasepool {
                // parse arguments, load config files, etc ...
                server = [Server new];
                if (!server) return EXIT_FAILURE;
                if (![server run]) return EXIT_FAILURE;
            }
            dispatch_main();
        }

This will release all the temporary objects created during setup before entering
the main run loop.  (Don't forget to hold a reference to your server instance
_outside_ the nested startup block.)

If your server is embedded in an iOS or macOS app instead of a command line
tool, you already have a `main()` method that starts your app's run loop, so
there's no need for an additional call to `dispatch_main()`.  In this case,
you'll want to initialize and run your server at the appropriate time for your
app, such as when your application delegate receives the
`-application:didFinishLaunchingWithOptions:` or
`-applicationDidFinishLaunching:` notification.

Note that `dispatch_main()` never exits.  If you need to exit gracefully, your
server will need to call `exit()` at some point.

#### The `Server` Class

At a high level, the `Server` is a container for listening sockets and active
sessions.  It's also typically the holder of configuration information such as
which addresses and ports to listen on and the location of data to serve.  The
`Server` is also typically the delegate for `PLGListener`s and conforms to the
`PLGListenerDelegate` protocol.

        @interface Server : NSObject<PLGListenerDelegate>

        @property int exit_status;
        @property PLGListener *listener;
        @property (copy) NSMutableArray<Session *> *sessions;

        - (BOOL)run;

        @end

The example `Server` class is intentionally very simple, with only a single
listener.  A real server might listen on multiple addresses and ports.  The
`sessions` collection holds any currently active sessions.  The example `Server`
also has an `exit_status` property -- this is used to track if the server has
encountered an unrecoverable error, and becomes the value passed to `exit()`
when shutting down.  (Look at `-listener:didFailWithError:` and
`-listenerDidClose:` to see how this is used.)

You can see the core server lifecycle by looking at the `-init`, `-start` and
`-listener:didAcceptConnections:` methods of `Server`.

In the `-init` method, we create our listener socket, but don't yet bind and
open it.

        - (instancetype)init;
        {
            self = [super init];
            if (!self) return nil;
            
            _exit_status = EXIT_SUCCESS;
            
            PLGInetSocketAddress *address = [PLGInetSocketAddress anyInternetAddressWithPort:2000];
            _listener = [[PLGListener alloc] initWithServerAddress:address];
            _listener.delegate = self;
            
            _sessions = [NSMutableArray new];
            
            return self;
        }

Note that we set the listener's delegate to our `Server` instance.  The `-start`
method is where we bind and open listening sockets:

        - (BOOL)start;
        {
            dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
            NSError *error = nil;
            BOOL opened = [_listener openOnQueue:queue error:&error];
            if (opened) {
                NSLog(@"Listening on %@", _listener.serverAddress);
                return YES;
            } else {
                NSLog(@"Error: (%li) %@", (long)error.code, error.description);
                return NO;
            }
        }

The heart of the `Server` class is accepting connections.  This happens when the
listener socket calls its `-listener:didAcceptConnections:` delegate method:

        - (void)listener:(nonnull PLGListener *)listener
        didAcceptConnections:(nonnull NSArray *)connections;
        {
            for (PLGConnection *connection in connections) {
                NSLog(@"Accepted connection from %@", connection.remoteAddress);
                Session *session = [[Session alloc] initWithConnection:connection];

                NSError *error = nil;
                BOOL started = [session startWithError:&error];
                if (started) {
                    [_sessions addObject:session];
                    session.server = self;
                } else {
                    NSLog(@"Error: (%li): %@", (long)error.code, error.description);
                    [connection close];
                }
            }
        }

Since it's possible for a listening socket to have multiple connections waiting
to be accepted, this delegate method provides the connections in an array.

In this example architecture, the `Session` class is a wrapper around a
`PLGConnection` object.  After wrapping the connection in a `Session`, we try to
start the session, which will prepare the connection for reading; if this fails,
we log the error and close the connection.

#### The `Session` Class

A `Session` manages the lifecycle of a `PLGConnection`.  As such, it conforms to
the `PLGConnectionDelegate` Objective-C protocol and acts to shuttle data
between the connection and the `Histogram` class, which is responsible for
implementing the simple request-response network protocol of this example.

        @interface Session : NSObject<PLGConnectionDelegate>

        @property PLGConnection *connection;
        @property Histogram *histogram;
        @property dispatch_queue_t queue;
        @property (weak) Server *server;

        - (instancetype)initWithConnection:(PLGConnection *)connection;

        - (BOOL)startWithError:(NSError **)error;

        @end

In addition to the connection and `Histogram` instances, the `Session` also
contains a queue used for reads and writes and a weak reference to the `Server`,
so that it can let the `Server` know when it's done.  Similar to the server,
I've structured `Session` creation into two parts: the non-fallible
`-initWithConnection:` method and the fallible `startWithError:` method which
prepares the connection for IO by creating an associated `dispatch_io_t` object
to manage asynchronous reading and writing.

In `-startWithError:`, we call `-scheduleReadOnQueue:` on the connection, which
will cause the connection to call its `-connection:didReadData:` delegate method
when data from the client arrives.  This method drives our `Histogram` class by
feeding it chunks of data:

        - (void)connection:(nonnull PLGConnection *)connection
               didReadData:(nonnull dispatch_data_t)data;
        {
            NSLog(@"Connection %@ read %zu bytes", connection, dispatch_data_get_size(data));
            BOOL shouldReadMore = YES;
            [_histogram addData:data shouldReadMore:&shouldReadMore];
            if (shouldReadMore) {
                [_connection scheduleReadOnQueue:_queue];
            } else {
                dispatch_data_t report = [_histogram generateReport];
                [_connection scheduleWriteWithData:report onQueue:_queue];
            }
        }

The out-param `shouldReadMore` tells us if our request is incomplete; when it is
`NO`, we generate our response and schedule it to be written.  In our simple
example, we can close the connection as soon as we're done writing the output.

          - (void)connection:(nonnull PLGConnection *)connection
        didFinishWritingData:(nonnull dispatch_data_t)data;
        {
            NSLog(@"Connection %@ finished writing %zu bytes", connection, dispatch_data_get_size(data));
            [connection close];
        }

A service that needed to do asynchronous work or IO would probably query its
protocol object here to determine when the response is complete.  Finally, when
the connection is closed, we remove the completed `Session` from the `Server`.

        - (void)connectionDidClose:(nonnull PLGConnection *)connection;
        {
            NSLog(@"Connection %@ closed", connection);
            Server *server = _server; // take a strong reference
            if (server) [server.sessions removeObject:self];
        }

#### The `Histogram` Class

This class isolates the core logic of our network protocol from the socket and
server machinery.  We shovel data into it using the `-addData:shouldReadMore:`
method and get data out via the `-generateReport` method.

        @interface Histogram : NSObject

        @property NSUInteger bytesCounted;
        @property (copy) NSMutableDictionary<NSNumber *, NSNumber *> *counts;

        - (void)addData:(nonnull dispatch_data_t)data
         shouldReadMore:(nonnull BOOL *)shouldReadMore;

        - (dispatch_data_t)generateReport;

        @end

Real world protocol implementations will usually be a lot more complicated.
Configuration data and useful things like database connections and external API
credentials will typically flow from the `Server` through the `Session` to the
protocol object to allow it to do useful work.

The `Entry` class is a small helper object used by `Histogram` to produce the
desired sort order for the generated table.

## Notes on Dispatch Queues

If you read the `HistogramServer` code closely, you'll notice that it passes
`dispatch_queue_t` objects to _Plug_ methods in a number of places.  The example
code always uses the default global queue by calling

        dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);

and this works just fine for many use cases.  If you have more specific needs,
you can customize your use of queues in several ways.

The `PLGListener` class accepts a queue parameter to its `-openOnQueue:error:`
and `-openWithBacklog:onQueue:error:` methods.  This is the queue that incoming
connections will be accepted on.  It's used by `PLGListener` to create the
`dispatch_source_t` that monitors the underlying listener socket.

The `PLGConnection` class uses queues for four different operations: timeouts,
reading, writing and `dispatch_io_t` cleanup.  When reading and writing data,
the methods `-scheduleReadOnQueue:` and `-scheduleWriteWithData:onQueue:` let
the caller select the queue to use when data is ready to read or write,
respectively.

The
`-openWithTimeoutInterval:timeoutQueue:andCleanupOnQueue:error:` method asks for
two queues.  The `timeoutQueue` is used to create the `dispatch_source_t` that
runs the timer; if the connection doesn't read or write any data in the given
timeout interval, the connection closes.  The cleanup queue is used by the
`dispatch_io_t` object that manages reads and writes to the socket underlying
the `PLGConnection`.  In _Plug_, the `PLGIODispatcher` wraps and manages the
complexity of using a `dispatch_io_t`.  When the `PLGConnection` is closed, it
closes it's `PLGIODispatcher`, which in turn closes its `dispatch_io_t`.  This
in turn triggers a cleanup block to run on the given cleanup queue.  In _Plug_,
this cleanup code checks for errors and will trigger the
`-connection:didFailWithError:` delegate method if there's an IO error and
`-connectionDidClose:` (error nor not).

## Unfinished Bits

The `PLGConnectionStatistics` and `PLGListenerStatistics` classes are used to
accumulate some statistics about connections and listeners, but don't currently
have a public interface.

