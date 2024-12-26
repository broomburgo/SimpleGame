// swift-tools-version:6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "SimpleGame",
  platforms: [.iOS(.v18), .macOS(.v15)],
  products: [
    .executable(
      name: "SimpleGame",
      targets: ["SimpleGame"]
    ),
    .library(
      name: "SimpleHandler",
      targets: ["SimpleHandler"]
    ),
    .library(
      name: "SimpleSetting",
      targets: ["SimpleSetting"]
    ),
    .library(
      name: "SimpleStory",
      targets: ["SimpleStory"]
    ),
    .library(
      name: "AdvancedSetting",
      targets: ["AdvancedSetting"]
    ),
  ],
  dependencies: [
    .package(url: "https://github.com/broomburgo/Narratore", branch: "strict-concurrency-checking"),
  ],
  targets: [
    .executableTarget(
      name: "SimpleGame",
      dependencies: ["Narratore", "SimpleHandler", "SimpleSetting", "SimpleStory"]
    ),
    .target(
      name: "SimpleHandler",
      dependencies: ["Narratore"]
    ),
    .target(
      name: "SimpleSetting",
      dependencies: ["Narratore"]
    ),
    .target(
      name: "SimpleStory",
      dependencies: ["Narratore", "SimpleSetting"]
    ),
    .target(
      name: "AdvancedSetting",
      dependencies: ["Narratore", "SimpleSetting"]
    ),
  ]
)
