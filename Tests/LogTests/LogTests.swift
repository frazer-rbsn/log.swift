import XCTest
@testable import Log


final class LogTests: XCTestCase {
  
  // Called once before all tests are run
  override class func setUp() {
    super.setUp()
  }
  
  // Called before every test
  override func setUp() {
    super.setUp()
    Log.shouldLogToFile = true
    Log.useOSLog = false
    let url = try! FileManager.default.url(for: .applicationSupportDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
    Log.logFileDirectory = url.appendingPathComponent("Log.swift/logs")
  }
  
  // Called after every test
  override func tearDown() {
    super.tearDown()
    guard Log.logFileDirectory != nil else { return }
    print("Removing test log file...")
    try? FileManager.default.removeItem(atPath: Log.logFileDirectory.path)
  }
  
  
  // MARK: - Tests
  
  func testV() {
    Log.enabledLevels[.verbose] = true
    let queue = DispatchQueue(label: #function)
    Log.v("testV", queue: queue)
    queue.sync {} // Issue an empty closure on the queue and wait for it to be executed
    let logFileString = try! String.init(contentsOfFile: Log.logFilePath, encoding: .utf8)
    XCTAssert(logFileString.contains("\(#function): testV"))
  }
  
  func testD() {
    Log.enabledLevels[.debug] = true
    let queue = DispatchQueue(label: #function)
    Log.d("testD", queue: queue)
    queue.sync {} // Issue an empty closure on the queue and wait for it to be executed
    let logFileString = try! String.init(contentsOfFile: Log.logFilePath, encoding: .utf8)
    XCTAssert(logFileString.contains("\(#function): testD"))
  }
  
  func testI() {
    Log.enabledLevels[.info] = true
    let queue = DispatchQueue(label: #function)
    Log.i("testI", queue: queue)
    queue.sync {} // Issue an empty closure on the queue and wait for it to be executed
    let logFileString = try! String.init(contentsOfFile: Log.logFilePath, encoding: .utf8)
    XCTAssert(logFileString.contains("\(#function): testI"))
  }
  
  func testW() {
    Log.enabledLevels[.warning] = true
    let queue = DispatchQueue(label: #function)
    Log.w("testW", queue: queue)
    queue.sync {} // Issue an empty closure on the queue and wait for it to be executed
    let logFileString = try! String.init(contentsOfFile: Log.logFilePath, encoding: .utf8)
    XCTAssert(logFileString.contains("\(#function): testW"))
  }
  
  func testE() {
    Log.enabledLevels[.error] = true
    let queue = DispatchQueue(label: #function)
    Log.e("testE", queue: queue)
    queue.sync {} // Issue an empty closure on the queue and wait for it to be executed
    let logFileString = try! String.init(contentsOfFile: Log.logFilePath, encoding: .utf8)
    XCTAssert(logFileString.contains("\(#function): testE"))
  }
  
  func testLogWhenLevelDisabled() {
    Log.enabledLevels[.verbose] = false
    let queue = DispatchQueue(label: #function)
    Log.v("testV", queue: queue)
    queue.sync {} // Issue an empty closure on the queue and wait for it to be executed
    XCTAssert(Log.shouldLogToFile)
    XCTAssertThrowsError(try String.init(contentsOfFile: Log.logFilePath, encoding: .utf8))
  }
  
  func testLogToFileDisabled() {
    Log.shouldLogToFile = false
    Log.enabledLevels[.error] = true
    let queue = DispatchQueue(label: #function)
    Log.e("testE", queue: queue)
    queue.sync {} // Issue an empty closure on the queue and wait for it to be executed
    XCTAssertFalse(Log.shouldLogToFile)
    XCTAssertThrowsError(try String.init(contentsOfFile: Log.logFilePath, encoding: .utf8))
  }
  
  func testLoggingLocationNil() {
    Log.logFileDirectory = nil
    Log.enabledLevels[.error] = true
    let queue = DispatchQueue(label: #function)
    Log.e("testE", queue: queue)
    queue.sync {} // Issue an empty closure on the queue and wait for it to be executed
    XCTAssertFalse(Log.shouldLogToFile)
    XCTAssertThrowsError(try String.init(contentsOfFile: Log.logFilePath, encoding: .utf8))
  }
  
  func testOSLog() {
    Log.useOSLog = true
    Log.enabledLevels[.error] = true
    let queue = DispatchQueue(label: #function)
    Log.e("testE", queue: queue)
    queue.sync {} // Issue an empty closure on the queue and wait for it to be executed
    let logFileString = try! String.init(contentsOfFile: Log.logFilePath, encoding: .utf8)
    XCTAssert(logFileString.contains("\(#function): testE"))
  }
  
  
  // MARK: - Linux compatibility
  
  static var allTests = [
    ("testV", testV),
    ("testD", testD),
    ("testI", testI),
    ("testW", testW),
    ("testE", testE),
    ("testLogWhenLevelDisabled", testLogWhenLevelDisabled),
    ("testLogToFileDisabled", testLogToFileDisabled),
    ("testLoggingLocationNil", testLoggingLocationNil),
    ("testOSLog", testOSLog),
    ]
}
