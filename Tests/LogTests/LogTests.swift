import XCTest
@testable import Log

extension LoggerID {
  static let test = LoggerID("test")
}

final class LogTests: XCTestCase {
  
  private var log = Log(identifer: .test)
  
  // Called once before all tests are run
  override class func setUp() {
    super.setUp()
  }
  
  // Called before every test
  override func setUp() {
    super.setUp()
    self.log = Log(identifer: .test)
    log.shouldLogToFile = true
    if #available(macOS 10.12, *) {
      log.setUseOSLogDisabled()
    }
    let url = try! FileManager.default.url(for: .applicationSupportDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
    log.logFileDirectory = url.appendingPathComponent("Log.swift/logs")
  }
  
  // Called after every test
  override func tearDown() {
    super.tearDown()
    guard let logFileDirectory = log.logFileDirectory else { return }
    print("Removing test log file...")
    try? FileManager.default.removeItem(atPath: logFileDirectory.path)
  }
  
  
  // MARK: - Tests
  
  func testLogFunctions() {
    let queue = DispatchQueue(label: #function)
    logFunction(level: .verbose, queue: queue) { log.v(Log.Level.verbose.rawValue, logFileWriteQueue: queue) }
    logFunction(level: .debug, queue: queue) { log.d(Log.Level.debug.rawValue, logFileWriteQueue: queue) }
    logFunction(level: .info, queue: queue) { log.i(Log.Level.info.rawValue, logFileWriteQueue: queue) }
    logFunction(level: .warning, queue: queue) { log.w(Log.Level.warning.rawValue, logFileWriteQueue: queue) }
    logFunction(level: .error, queue: queue) { log.e(Log.Level.error.rawValue, logFileWriteQueue: queue) }
  }
  
  func logFunction(level : Log.Level, queue : DispatchQueue, function : () -> ()) {
    log.enabledLevels[level] = true
    function()
    queue.sync {} // Issue an empty closure on the queue and wait for it to be executed
    let logFileString = try! String.init(contentsOfFile: log.logFilePath, encoding: .utf8)
    XCTAssert(logFileString.contains(": \(level.rawValue)"))
    tearDown()
  }
  
  func testLogWhenLevelDisabled() {
    log.enabledLevels[.verbose] = false
    let queue = DispatchQueue(label: #function)
    log.v("testV", logFileWriteQueue: queue)
    queue.sync {} // Issue an empty closure on the queue and wait for it to be executed
    XCTAssert(log.shouldLogToFile)
    XCTAssertThrowsError(try String.init(contentsOfFile: log.logFilePath, encoding: .utf8))
  }
  
  func testLogToFileDisabled() {
    log.shouldLogToFile = false
    log.enabledLevels[.error] = true
    let queue = DispatchQueue(label: #function)
    log.e("testE", logFileWriteQueue: queue)
    queue.sync {} // Issue an empty closure on the queue and wait for it to be executed
    XCTAssertFalse(log.shouldLogToFile)
    XCTAssertThrowsError(try String.init(contentsOfFile: log.logFilePath, encoding: .utf8))
  }
  
  func testLoggingLocationNil() {
    log.logFileDirectory = nil
    log.enabledLevels[.error] = true
    let queue = DispatchQueue(label: #function)
    log.e("testE", logFileWriteQueue: queue)
    queue.sync {} // Issue an empty closure on the queue and wait for it to be executed
    XCTAssertFalse(log.shouldLogToFile)
    XCTAssertThrowsError(try String.init(contentsOfFile: log.logFilePath, encoding: .utf8))
  }
  
  func testLogBackgroundThread() {
    log.showCurrentThread = true
    log.shouldLogToFile = false
    log.enabledLevels[.error] = true
    let queue = DispatchQueue(label: "Banana", qos: .utility, attributes: [])
    queue.async {
      self.log.e("testE")
    }
    queue.sync {}
  }
  
  @available(macOS 10.12, *)
  func testOSLog() {
    log.setUseOSLogEnabled(osLogSubsystemName: "swift.Log", category: "TEST")
    let queue = DispatchQueue(label: #function)
    logFunction(level: .error, queue: queue) { log.e(Log.Level.error.rawValue, logFileWriteQueue: queue) }
  }
  
  
  // MARK: - Linux compatibility
  
  static var allTests = [
    ("testLogFunctions", testLogFunctions),
    ("testLogWhenLevelDisabled", testLogWhenLevelDisabled),
    ("testLogToFileDisabled", testLogToFileDisabled),
    ("testLoggingLocationNil", testLoggingLocationNil),
    ("testLogBackgroundThread", testLogBackgroundThread)
    ]
}

