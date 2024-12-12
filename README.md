# RESTless

...is a static web server for MacOS.

> Requires MacOS v13+.

## Use it in your own Swift app

Include the package in your app:

```swift
// swift-tools-version: 6.0

import PackageDescription

let package = Package(
  name: "YourApp",
  platforms: [.macOS(.v13)],
  dependencies: [
    .package(url: "https://github.com/jarrodtaylor/RESTless.git", from: "1.0.0")
  ],
  targets: [
    .executableTarget(
      name: "YourApp", dependencies: [
        .product(name: "RESTless", package: "RESTless")
      ]
    )
  ]
)
```

Start a server:

```swift
import Foundation
import RESTless

URL(string: "path/to/serve")!.restless(port: 8080) { req, res, err in
  var message: [String] = [""]
  if let req { message.append(req.path) }
  if let res { message.append("(\(res.status.rawValue) \(res.status))") }
  if let err { message.append("Error: \(err)") }
  print(message.joined(separator: " ").trimmingCharacters(in: .whitespaces))
}

print("Serving \(source) at http://localhost:8080\n^c to stop")

RunLoop.current.run()
```

## Or as a standalone CLI

> TBD (soon, waiting on Apple, there's a bunch of code signing involved)
