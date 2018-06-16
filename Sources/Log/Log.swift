//
//  Log.Swift
//
//  Created by Frazer Robinson on 01/03/2018.
//

import Foundation


public final class Log {
  
  
  // MARK: Configuration
  
  private static let showEmoji = true         // Recommended setting: true
  private static let showTimeStamp = false    // Recommended setting: false for debugging, true for production logging
  private static let shouldLogToFile = false  // Recommended setting: false for debugging, true for production logging. (Set `logFileLocation` below!)
  
  private enum Level : String { case verbose, debug, info, warning, error, fatal }
  
  private static let enabledLevels : [Level : Bool] = [.verbose: false,
                                                       .debug: true,
                                                       .info: true,
                                                       .warning: true,
                                                       .error: true,
                                                       .fatal: true]
  
  
  // MARK: Emoji
  
  private static func emojiIfEnabled(for level : Level) -> String {
    guard showEmoji else { return "" }
    switch level {
    case .warning: return "⚠️  "
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
  
  private static let logFileLocation : URL = URL(string: "")! // TODO: If you want to enable logging to a file, set the desired location here.
  
  private static var logFileName : String {
    return "LogFile-\(Log.dateString).txt"
  }
  
  static var logFilePath : String {
    return logFileLocation.appendingPathComponent(logFileName, isDirectory: false).path
  }
  
  private static func logToFile(_ message : String) {
    guard shouldLogToFile else { return }
    let messageWithReturn = "\(message)\n"
    guard let messageData = messageWithReturn.data(using: .utf8) else { return }
    if !fileManager.fileExists(atPath: logFilePath) {
      var isDir : ObjCBool = true
      if !fileManager.fileExists(atPath: logFileLocation.path, isDirectory: &isDir) {
        try! fileManager.createDirectory(atPath: logFileLocation.path, withIntermediateDirectories: true, attributes: nil)
      }
      let fileCreated = fileManager.createFile(atPath: logFilePath, contents: messageData, attributes: nil)
      if fileCreated { Log.i("Log file created successfully in location: \(logFilePath)") }
      else { print("[ERROR] Log.swift: Log file creation failed. Tried to create file at path: \(logFilePath)") }
    } else {
      guard let fileHandle = FileHandle.init(forUpdatingAtPath: logFilePath) else { return }
      fileHandle.seekToEndOfFile()
      fileHandle.write(messageData)
      fileHandle.closeFile()
    }
  }
  
  
  // MARK: Internal log function
  
  private static let queue = DispatchQueue(label: "LogQueue")
  
  private static func log(level : Level, message : String, functionName : String = #function, filePath : String = #file, lineNumber : Int = #line) {
    guard enabledLevels[level, default: false] else { return }
    queue.sync {
      let fileName = filePath.components(separatedBy: "/").last!
      let message = "\(timestampStringIfEnabled) \(emojiIfEnabled(for: level))[\(level.rawValue.uppercased())] \(fileName) \(lineNumber) \(functionName): \(message)"
      print(message)
      logToFile(message)
      if level == .fatal {
        fatalError(message)
      }
    }
  }
  
  
  // MARK: Public log functions
  
  /// Use for the most insignificant of messages that should only be logged if we desire to see a very detailed trace of application operation.
  public static func v(_ message : String, functionName : String = #function, filePath : String = #file, lineNumber : Int = #line) {
    log(level: .verbose, message: message, functionName: functionName, filePath: filePath, lineNumber: lineNumber)
  }
  
  /// Debugging information when diagnosing an issue. These logs are intended to be removed when problem is confirmed as fixed and tested.
  public static func d(_ message : String, functionName : String = #function, filePath : String = #file, lineNumber : Int = #line) {
    log(level: .debug, message: message, functionName: functionName, filePath: filePath, lineNumber: lineNumber)
  }
  
  /// Useful information, e.g. service start-up, configuration etc. Use sparingly and only when they would be useful for analysing crash/error reports.
  public static func i(_ message : String, functionName : String = #function, filePath : String = #file, lineNumber : Int = #line) {
    log(level: .info, message: message, functionName: functionName, filePath: filePath, lineNumber: lineNumber)
  }
  
  /// Warnings about odd/unexpected behaviour but are easily recoverable and probably shouldn't be notified to the user but notified to the team.
  /// Also for uses of deprecated APIs or incorrect uses of APIs.
  /// Other examples: value that is expected to be positive was actually negative, so it was clamped to zero, etc.
  public static func w(_ message : String, functionName : String = #function, filePath : String = #file, lineNumber : Int = #line) {
    log(level: .warning, message: message, functionName: functionName, filePath: filePath, lineNumber: lineNumber)
  }
  
  /// Errors that mean an operation has failed and we need to cancel it but keep the application or service running. Usually need user intervention or notification.
  /// Support and development teams should investigate.
  public static func e(_ message : String, functionName : String = #function, filePath : String = #file, lineNumber : Int = #line) {
    log(level: .error, message: message, functionName: functionName, filePath: filePath, lineNumber: lineNumber)
  }
  
  /// Catastrophic failures that mean we need to force-crash the application/service immediately.
  /// Use only when we absolutely cannot continue execution or there is potential for data loss or corruption.
  /// Requires urgent investigation from support and development teams.
  public static func f(_ message : String, functionName : String = #function, filePath : String = #file, lineNumber : Int = #line) {
    log(level: .fatal, message: message, functionName: functionName, filePath: filePath, lineNumber: lineNumber)
  }
}
