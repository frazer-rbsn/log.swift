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
    if #available(macOS 10.12, *) {
      Log.setUseOSLogDisabled()
    }
    let url = try! FileManager.default.url(for: .applicationSupportDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
    Log.logFileDirectory = url.appendingPathComponent("Log.swift/logs")
  }
  
  // Called after every test
  override func tearDown() {
    super.tearDown()
    guard let logFileDirectory = Log.logFileDirectory else { return }
    print("Removing test log file...")
    try? FileManager.default.removeItem(atPath: logFileDirectory.path)
  }
  
  
  // MARK: - Tests
  
  func testV() {
    Log.enabledLevels[.verbose] = true
    Log.v("testV")
    let logFileString = try! String.init(contentsOfFile: Log.logFilePath, encoding: .utf8)
    XCTAssert(logFileString.contains("\(#function): testV"))
  }
  
  func testD() {
    Log.enabledLevels[.debug] = true
    Log.d("testD")
    let logFileString = try! String.init(contentsOfFile: Log.logFilePath, encoding: .utf8)
    XCTAssert(logFileString.contains("\(#function): testD"))
  }
  
  func testI() {
    Log.enabledLevels[.info] = true
    Log.i("testI")
    let logFileString = try! String.init(contentsOfFile: Log.logFilePath, encoding: .utf8)
    XCTAssert(logFileString.contains("\(#function): testI"))
  }
  
  func testW() {
    Log.enabledLevels[.warning] = true
    Log.w("testW")
    let logFileString = try! String.init(contentsOfFile: Log.logFilePath, encoding: .utf8)
    XCTAssert(logFileString.contains("\(#function): testW"))
  }
  
  func testE() {
    Log.enabledLevels[.error] = true
    Log.e("testE")
    let logFileString = try! String.init(contentsOfFile: Log.logFilePath, encoding: .utf8)
    XCTAssert(logFileString.contains("\(#function): testE"))
  }
  
  func testLogWhenLevelDisabled() {
    Log.enabledLevels[.verbose] = false
    Log.v("testV")
    XCTAssert(Log.shouldLogToFile)
    XCTAssertThrowsError(try String.init(contentsOfFile: Log.logFilePath, encoding: .utf8))
  }
  
  func testLogToFileDisabled() {
    Log.showCurrentThread = true
    Log.shouldLogToFile = false
    Log.enabledLevels[.error] = true
    Log.e("testE")
    XCTAssertFalse(Log.shouldLogToFile)
    XCTAssertThrowsError(try String.init(contentsOfFile: Log.logFilePath, encoding: .utf8))
  }
  
  func testLoggingLocationNil() {
    Log.logFileDirectory = nil
    Log.enabledLevels[.error] = true
    Log.e("testE")
    XCTAssertFalse(Log.shouldLogToFile)
    XCTAssertThrowsError(try String.init(contentsOfFile: Log.logFilePath, encoding: .utf8))
  }
  
  func testLogBackgroundThread() {
    Log.showCurrentThread = true
    Log.shouldLogToFile = false
    Log.enabledLevels[.error] = true
    let queue = DispatchQueue(label: "Banana", qos: .utility, attributes: [])
    queue.async {
      Log.e("testE")
    }
    queue.sync {}
  }
  
  @available(macOS 10.12, *)
  func testOSLog() {
    Log.setUseOSLogEnabled(osLogSubsystemName: "swift.Log", category: "TEST")
    Log.enabledLevels[.error] = true
    Log.e("testE")
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
    ]
}
