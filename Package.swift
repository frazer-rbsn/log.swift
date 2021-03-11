// swift-tools-version:5.2
import PackageDescription

let package = Package(
  name: "Log",
  platforms: [
    .macOS(.v10_14),
    .iOS(.v12),
  ],
  products: [
    .library(
      name: "Log",
      targets: ["Log"]),
  ],
  dependencies: [],
  targets: [
    .target(
      name: "Log",
      dependencies: [],
      path: "Sources"),
    .testTarget(
      name: "LogTests",
      dependencies: ["Log"]),
  ]
)
