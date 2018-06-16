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


No need to add this as a package dependency, I'd recommend just copying the file and customising it yourself.
Think of it as a basic, batteries-included template for making your own logging class.
