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

_Plug_ includes an Xcode project that builds a [framework][5].  You can embed
_Plug_'s project in your Xcode project using git submodules and adding _Plug_ as
a linked framework.  (The steps in [_Add a Framework to an iOS App_][6] are the
same for macOS.)

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

[9]: https://github.com/donmccaughey/Plug/master/LICENSE.md


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

- `PLGSocket`: any file descriptor that can be created by `socket()`.

### Listening for Connections

The `PLGListener` class creates objects that will listen on an address and
accept connections as they come in.  It will do its work on a given dispatch
queue.  Internally, it pairs a `PLGSocket` with a `dispatch_source_t`.

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

