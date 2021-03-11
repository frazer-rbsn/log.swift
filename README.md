# Log.swift

[![Travis build status](https://travis-ci.org/frazer-rbsn/Log.swift.svg?branch=master)](https://travis-ci.org/frazer-rbsn/Log.swift)

Log.swift is a simple logging class with an API based on Android's `Log`. 

* easy configuration
* prints file name, line number, function name
* prints current thread (optional)
* simple timestamps (optional)
* symbol (optional)
* output to log file -- please set `logFileLocation` and `shouldLogToFile` to `true`
* can output using `print()` or `os_log()` (macOS 10.12 or newer only)


#### How to use:
Log has static log functions that use a private static instance, so you don't need to instantiate a `Log` object to use it, but you can if you wish.

```swift
Log.e("A really bad thing happened!")
```
outputs:
```
14:19:30 [ERROR] Foo.swift 67 buggyFunction(): A really bad thing happened!
```

Likewise:

```swift
let eventLogger = Log(identifier: "system")
eventLogger.e("A really bad thing happened!")
```
outputs:
```
14:19:30 [ERROR] Foo.swift 67 buggyFunction(): A really bad thing happened!
```


#### Log levels:

```swift
Log.v() // [VERBOSE]
Log.d() // [DEBUG]
Log.i() // [INFO]
Log.w() // [WARNING]
Log.e() // [ERROR]
Log.f() // [FATAL] (Calls fatalError() to crash the application/service.)
```
