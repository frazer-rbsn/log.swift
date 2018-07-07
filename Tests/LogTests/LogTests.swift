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
    Log.default.shouldLogToFile = true
    if #available(macOS 10.12, *) {
      Log.default.setUseOSLogDisabled()
    }
    let url = try! FileManager.default.url(for: .applicationSupportDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
    Log.default.logFileDirectory = url.appendingPathComponent("Log.swift/logs")
  }
  
  // Called after every test
  override func tearDown() {
    super.tearDown()
    guard let logFileDirectory = Log.default.logFileDirectory else { return }
    print("Removing test log file...")
    try? FileManager.default.removeItem(atPath: logFileDirectory.path)
  }
  
  
  // MARK: - Tests
  
  func testV() {
    Log.default.enabledLevels[.verbose] = true
    Log.v("testV")
    let logFileString = try! String.init(contentsOfFile: Log.default.logFilePath, encoding: .utf8)
    XCTAssert(logFileString.contains("\(#function): testV"))
  }
  
  func testD() {
    Log.default.enabledLevels[.debug] = true
    Log.d("testD")
    let logFileString = try! String.init(contentsOfFile: Log.default.logFilePath, encoding: .utf8)
    XCTAssert(logFileString.contains("\(#function): testD"))
  }
  
  func testI() {
    Log.default.enabledLevels[.info] = true
    Log.i("testI")
    let logFileString = try! String.init(contentsOfFile: Log.default.logFilePath, encoding: .utf8)
    XCTAssert(logFileString.contains("\(#function): testI"))
  }
  
  func testW() {
    Log.default.enabledLevels[.warning] = true
    Log.w("testW")
    let logFileString = try! String.init(contentsOfFile: Log.default.logFilePath, encoding: .utf8)
    XCTAssert(logFileString.contains("\(#function): testW"))
  }
  
  func testE() {
    Log.default.enabledLevels[.error] = true
    Log.e("testE")
    let logFileString = try! String.init(contentsOfFile: Log.default.logFilePath, encoding: .utf8)
    XCTAssert(logFileString.contains("\(#function): testE"))
  }
  
  func testLogWhenLevelDisabled() {
    Log.default.enabledLevels[.verbose] = false
    Log.v("testV")
    XCTAssert(Log.default.shouldLogToFile)
    XCTAssertThrowsError(try String.init(contentsOfFile: Log.default.logFilePath, encoding: .utf8))
  }
  
  func testLogToFileDisabled() {
    Log.default.showCurrentThread = true
    Log.default.shouldLogToFile = false
    Log.default.enabledLevels[.error] = true
    Log.e("testE")
    XCTAssertFalse(Log.default.shouldLogToFile)
    XCTAssertThrowsError(try String.init(contentsOfFile: Log.default.logFilePath, encoding: .utf8))
  }
  
  func testLoggingLocationNil() {
    Log.default.logFileDirectory = nil
    Log.default.enabledLevels[.error] = true
    Log.e("testE")
    XCTAssertFalse(Log.default.shouldLogToFile)
    XCTAssertThrowsError(try String.init(contentsOfFile: Log.default.logFilePath, encoding: .utf8))
  }
  
  func testLogBackgroundThread() {
    Log.default.showCurrentThread = true
    Log.default.shouldLogToFile = false
    Log.default.enabledLevels[.error] = true
    let queue = DispatchQueue(label: "Banana", qos: .utility, attributes: [])
    queue.async {
      Log.e("testE")
    }
    queue.sync {}
  }
  
  func testCreateNewLog() {
    let newLog = Log()
    newLog.showCurrentThread = true
    newLog.shouldLogToFile = false
    newLog.enabledLevels[.error] = true
    let queue = DispatchQueue(label: "Banana", qos: .utility, attributes: [])
    queue.async {
      newLog.e("testE")
    }
    queue.sync {}
  }
  
  @available(macOS 10.12, *)
  func testOSLog() {
    Log.default.setUseOSLogEnabled(osLogSubsystemName: "swift.Log", category: "TEST")
    Log.default.enabledLevels[.error] = true
    Log.e("testE")
    let logFileString = try! String.init(contentsOfFile: Log.default.logFilePath, encoding: .utf8)
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
    ]
}
