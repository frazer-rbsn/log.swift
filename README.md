# Log.swift

[![Travis build status](https://travis-ci.org/frazer-rbsn/Log.swift.svg?branch=master)](https://travis-ci.org/frazer-rbsn/Log.swift)

Be gone, `print()` statements! A simple *static* logging class in Swift, with an API based on Android's `Log`. 

* easy configuration
* prints file name, line number and function name
* simple timestamps (optional)
* emoji (optional)
* output to log file -- please set `logFileLocation` and `shouldLogToFile` to `true`
* can output using `print()` or `os_log()` (macOS 10.12 or newer only)

#### How to use:
Log is a static class - it is not instantiable and is intended to be accessible from anywhere.

```swift
Log.e("A really bad thing happened!")
```
outputs:
```
14:19:30 ❌ [ERROR] Foo.swift 67 buggyFunction(): A really bad thing happened!
```

#### Log levels:

```swift
Log.v() // [VERBOSE]
Log.d() // [DEBUG]
Log.i() // [INFO]
Log.w() // ⚠️ [WARNING]
Log.e() // ❌ [ERROR]
Log.f() // ☠️ [FATAL] (Calls fatalError() to crash the application/service.)
```
