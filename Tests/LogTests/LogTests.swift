import XCTest
@testable import Log


final class LogTests: XCTestCase {
  
  // Called once before all tests are run
  override class func setUp() {
    super.setUp()
    print("Log class setup...")
    Log.shouldLogToFile = true
    let url = try! FileManager.default.url(for: .applicationSupportDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
    Log.logFileDirectory = url.appendingPathComponent("Log.swift/logs")
  }
  
  // Called after every test
  override func tearDown() {
    super.tearDown()
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
    XCTAssert(logFileString.contains("testV(): testV"))
  }
  
  func testD() {
    Log.enabledLevels[.debug] = true
    let queue = DispatchQueue(label: #function)
    Log.d("testD", queue: queue)
    queue.sync {} // Issue an empty closure on the queue and wait for it to be executed
    let logFileString = try! String.init(contentsOfFile: Log.logFilePath, encoding: .utf8)
    XCTAssert(logFileString.contains("testD(): testD"))
  }
  
  func testI() {
    Log.enabledLevels[.info] = true
    let queue = DispatchQueue(label: #function)
    Log.i("testI", queue: queue)
    queue.sync {} // Issue an empty closure on the queue and wait for it to be executed
    let logFileString = try! String.init(contentsOfFile: Log.logFilePath, encoding: .utf8)
    XCTAssert(logFileString.contains("testI(): testI"))
  }
  
  func testW() {
    Log.enabledLevels[.warning] = true
    let queue = DispatchQueue(label: #function)
    Log.w("testW", queue: queue)
    queue.sync {} // Issue an empty closure on the queue and wait for it to be executed
    let logFileString = try! String.init(contentsOfFile: Log.logFilePath, encoding: .utf8)
    XCTAssert(logFileString.contains("testW(): testW"))
  }
  
  func testE() {
    Log.enabledLevels[.error] = true
    let queue = DispatchQueue(label: #function)
    Log.e("testE", queue: queue)
    queue.sync {} // Issue an empty closure on the queue and wait for it to be executed
    let logFileString = try! String.init(contentsOfFile: Log.logFilePath, encoding: .utf8)
    XCTAssert(logFileString.contains("testE(): testE"))
  }
  
  func testLogWhenDisabled() {
    Log.enabledLevels[.verbose] = false
    let queue = DispatchQueue(label: #function)
    Log.v("testV", queue: queue)
    queue.sync {} // Issue an empty closure on the queue and wait for it to be executed
    XCTAssertThrowsError(try String.init(contentsOfFile: Log.logFilePath, encoding: .utf8))
  }
  
  
  // MARK: - Linux compatibility
  
  static var allTests = [
    ("testV", testV),
    ("testD", testD),
    ("testI", testI),
    ("testW", testW),
    ("testE", testE),
    ]
}
