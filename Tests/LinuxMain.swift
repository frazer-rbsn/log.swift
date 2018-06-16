import XCTest

import LogTests

var tests = [XCTestCaseEntry]()
tests += LogTests.allTests()
XCTMain(tests)