// swift-tools-version: 6.0

import PackageDescription

let package = Package(
  name: "RESTless",
  platforms: [.macOS(.v13)],
  products: [
    .library(name: "RESTless", targets: ["RESTless"])
  ],
  dependencies: [
    .package(url: "https://github.com/apple/swift-argument-parser", from: "1.5.0")
  ],
  targets: [
    .target(name: "RESTless"),
    .executableTarget(
      name: "RESTlessCLI",
      dependencies: [
        "RESTless",
        .product(name: "ArgumentParser", package: "swift-argument-parser")
      ]
    )
  ]
)
