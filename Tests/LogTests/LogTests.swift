import XCTest
@testable import Log

/// These obviously don't test anything - they're just here for a sanity check.
final class LogTests: XCTestCase {
  
  func testV() {
    Log.v("Test")
  }
  
  func testD() {
    Log.d("Test")
  }
  
  func testI() {
    Log.i("Test")
  }
  
  func testW() {
    Log.w("Test")
  }
  
  func testE() {
    Log.e("Test")
  }
  
  static var allTests = [
    ("testV", testV),
    ("testD", testD),
    ("testI", testI),
    ("testW", testW),
    ("testE", testE),
    ]
}
