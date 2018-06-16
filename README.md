# Log.swift

[![Travis build status](https://travis-ci.org/frazer-rbsn/Log.swift.svg?branch=master)](https://travis-ci.org/frazer-rbsn/Log.swift)

Be gone, `print()` statements! A simple *static* logging class in Swift, with an API based on Android's `Log`.  
* easy configuration
* emoji (optional)
* output to log file -- please set `logFileLocation`


#### How to use:
Log is a static class - it is not instantiable and is intended to be accessible from anywhere.

```swift
Log.e("A really bad thing happened!")
```
outputs:
```
14:19:30 ❌ [ERROR] Foo.swift 32 buggyFunction(): A really bad thing happened!
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

Instead of added Log.swift as a package dependency, I'd recommend just copying the file and customising it yourself.
You can use it as a basic, batteries-included template for making your own logging class.
