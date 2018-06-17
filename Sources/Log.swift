//
//  Log.Swift
//
//  Created by Frazer Robinson on 01/03/2018.
//

import Foundation
import os

/// A static class wrapper around `print()` and `os_log()` to make logging simple and quick.
public final class Log {
  
  private init() {}
  
  
  //
  // MARK: - Configuration
  //
  
  // MARK: Optional functionality
  
  /// Emoji can be used for making certain log levels stand out.
  /// - Recommended setting: true.
  public static var showEmoji = true
  
  /// Show a timestamp of the local time on each log message.
  /// - Recommended setting: false for debugging, true for production logging.
  public static var showTimeStamp = false
  
  /// Output logs to a file if `logFileDirectory` is set to a valid URL.
  /// - Recommended setting: false for debugging, true for production logging.
  public static var shouldLogToFile = false
  
  /// The directory in which the log file will be created.
  /// If you want to enable logging to a file, set the desired location here.
  public static var logFileDirectory : URL!
  
  
  // MARK: Levels
  
  enum Level : String { case verbose, debug, info, warning, error, fatal }
  
  /// A log is only outputted if it's `Level` has a value of `true` here.
  static var enabledLevels : [Level : Bool] = [.verbose: false,
                                               .debug: true,
                                               .info: true,
                                               .warning: true,
                                               .error: true,
                                               .fatal: true]
  
  
  // MARK: Queue
  
  /// The default queue for logs to be printed on. Also used for creation of and writing to log files.
  /// Default value is a new Serial DispatchQueue.
  public static var queue = DispatchQueue(label: "LogQueue")
  
  
  // MARK: OSLog
  
  /// Uses OS_Log so that logs will appear in the Console app, even when you're not debugging.
  /// Default value is `false`.
  /// - NOTE: If this is `false`, logs are output using `print()`.
  public static var useOSLog = false
  
  /// Set this to your identifer in reverse DNS notation, e.g. "com.yourcompany.yourappname"
  private static var osLogSubsystemName = "com.yourcompany.yourappname"
  
  /// Set this category which will be used for filtering your logs in the Console app.
  private static var osLogCategory = "categoryname"
  
  private static var osLog = OSLog(subsystem: osLogSubsystemName, category: osLogCategory)
  
  
  //
  // MARK: - Private functions
  //
  
  // MARK: Emoji
  
  private static func emojiIfEnabled(for level : Level) -> String {
    guard showEmoji else { return "" }
    switch level {
    case .warning: return "⚠️ "
    case .error: return "❌ "
    case .fatal: return "☠️ "
    default: return ""
    }
  }
  
  
  // MARK: Date & Time
  
  private static let timeFormat = "HH:mm:ss"
  private static let dateFormat = "yyyy-MM-dd"
  
  private static func formatter(with format : String) -> DateFormatter {
    let f = DateFormatter()
    f.timeZone = TimeZone.current
    f.dateFormat = format
    return f
  }
  
  private static let timeFormatter : DateFormatter = {
    return formatter(with: timeFormat)
  }()
  
  private static let dateFormatter : DateFormatter = {
    return formatter(with: dateFormat)
  }()
  
  private static func string(with dateFormatter : DateFormatter) -> String {
    let now = Date()
    return dateFormatter.string(from: now)
  }
  
  private static var timestampString : String {
    return string(with: timeFormatter)
  }
  
  private static var timestampStringIfEnabled : String {
    guard showTimeStamp else { return "" }
    return timestampString
  }
  
  private static var dateString : String {
    return string(with: dateFormatter)
  }
  
  
  // MARK: Log file
  
  private static let fileManager = FileManager.default
  
  private static var logFileName : String {
    return "LogFile-\(Log.dateString).txt"
  }
  
  static var logFilePath : String {
    guard logFileDirectory != nil else { return "" }
    return logFileDirectory.appendingPathComponent(logFileName, isDirectory: false).path
  }
  
  private static func disableLoggingToFileBecauseOfError() {
    shouldLogToFile = false
    Log.w("`shouldLogToFile` has now been set to `false` due to an error.")
  }
  
  private static func logToFile(_ message : String) {
    guard shouldLogToFile else { return }
    guard logFileDirectory != nil else {
      disableLoggingToFileBecauseOfError()
      Log.e("`Log.logFileDirectory` is not set, please set this to enable output of logs to a file.")
      return
    }
    let messageWithReturn = "\(message)\n"
    guard let messageData = messageWithReturn.data(using: .utf8) else { return }
    if !fileManager.fileExists(atPath: logFilePath) {
      var isDir : ObjCBool = true
      if !fileManager.fileExists(atPath: logFileDirectory.path, isDirectory: &isDir) {
        do {
          try fileManager.createDirectory(atPath: logFileDirectory.path, withIntermediateDirectories: true, attributes: nil)
        } catch {
          disableLoggingToFileBecauseOfError()
          Log.e("Error when creating log file directory: \(error.localizedDescription)")
          return
        }
      }
      let fileCreated = fileManager.createFile(atPath: logFilePath, contents: messageData, attributes: nil)
      if fileCreated {
        Log.i("Log file created successfully. Path: \(logFilePath)")
      } else {
        disableLoggingToFileBecauseOfError()
        Log.e("Log file creation failed. Tried to create file at path: \(logFilePath)")
      }
    } else {
      guard let fileHandle = FileHandle.init(forUpdatingAtPath: logFilePath) else {
        disableLoggingToFileBecauseOfError()
        Log.e("FileHandle init failed. Log file path: \(logFilePath)")
        return
      }
      fileHandle.seekToEndOfFile()
      fileHandle.write(messageData)
      fileHandle.closeFile()
    }
  }
  
  
  // MARK: Main log function

  private static func log(level : Level, message : String, functionName : String = #function, filePath : String = #file, lineNumber : Int = #line, queue : DispatchQueue = queue) {
    guard enabledLevels[level, default: false] else { return }
    queue.async {
      let fileName = filePath.components(separatedBy: "/").last!
      let printMessage = "\(timestampStringIfEnabled) \(emojiIfEnabled(for: level))[\(level.rawValue.uppercased())] \(fileName) \(lineNumber) \(functionName): \(message)"
      if useOSLog {
        os_log("%@[%@] %@ %d %@: %@", log: osLog, type: osLogType(for: level), emojiIfEnabled(for: level), level.rawValue.uppercased(), fileName, lineNumber, functionName, message)
      } else {
        print(printMessage)
      }
      logToFile(printMessage)
      if level == .fatal {
        fatalError(message)
      }
    }
  }
  
  private static func osLogType(for logLevel : Level) -> OSLogType {
    switch logLevel {
    case .verbose: return OSLogType.default
    case .info, .warning: return OSLogType.info
    case .debug: return OSLogType.debug
    case .error, .fatal: return OSLogType.error
    }
  }
  
  
  //
  // MARK: - Public log functions
  //
  
  /// **VERBOSE**
  /// Use for the most insignificant of messages that should only be logged if we desire to see a very detailed trace of application operation.
  public static func v(_ message : String, functionName : String = #function, filePath : String = #file, lineNumber : Int = #line, queue : DispatchQueue = queue) {
    log(level: .verbose, message: message, functionName: functionName, filePath: filePath, lineNumber: lineNumber, queue: queue)
  }
  
  /// **DEBUG**
  /// Debugging information when diagnosing an issue. These logs are intended to be removed when problem is confirmed as fixed and tested.
  public static func d(_ message : String, functionName : String = #function, filePath : String = #file, lineNumber : Int = #line, queue : DispatchQueue = queue) {
    log(level: .debug, message: message, functionName: functionName, filePath: filePath, lineNumber: lineNumber, queue: queue)
  }
  
  /// **INFO**
  /// Useful information, e.g. service start-up, configuration etc. Use sparingly and only when they would be useful for analysing crash/error reports.
  public static func i(_ message : String, functionName : String = #function, filePath : String = #file, lineNumber : Int = #line, queue : DispatchQueue = queue) {
    log(level: .info, message: message, functionName: functionName, filePath: filePath, lineNumber: lineNumber, queue: queue)
  }
  
  /// **WARNING**
  /// Warnings about odd/unexpected behaviour but are easily recoverable and probably shouldn't be notified to the user but notified to the team.
  /// Also for uses of deprecated APIs or incorrect uses of APIs.
  /// Other examples: value that is expected to be positive was actually negative, so it was clamped to zero, etc.
  public static func w(_ message : String, functionName : String = #function, filePath : String = #file, lineNumber : Int = #line, queue : DispatchQueue = queue) {
    log(level: .warning, message: message, functionName: functionName, filePath: filePath, lineNumber: lineNumber, queue: queue)
  }
  
  /// **ERROR**
  /// Errors that mean an operation has failed and we need to cancel it but keep the application or service running.
  /// Usually need user intervention or notification.
  /// Support and development teams should investigate.
  public static func e(_ message : String, functionName : String = #function, filePath : String = #file, lineNumber : Int = #line, queue : DispatchQueue = queue) {
    log(level: .error, message: message, functionName: functionName, filePath: filePath, lineNumber: lineNumber, queue: queue)
  }
  
  /// **FATAL**
  /// Catastrophic failures that mean we need to force-crash the application/service immediately.
  /// Use only when we absolutely cannot continue execution or there is potential for data loss or corruption.
  /// Requires urgent investigation from support and development teams.
  public static func f(_ message : String, functionName : String = #function, filePath : String = #file, lineNumber : Int = #line, queue : DispatchQueue = queue) {
    log(level: .fatal, message: message, functionName: functionName, filePath: filePath, lineNumber: lineNumber, queue: queue)
  }
}
