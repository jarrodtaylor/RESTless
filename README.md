RESTless
========
Serve static files on MacOS(v13+).

As a CLI Tool
-------------
Download and run the latest [installer][installer] to install RESTless as a CLI tool.

Run `restless -h` for instructions on using the command:

```shell
$ restless -h
USAGE: restless <path> [--port <port>]

ARGUMENTS:
  <path>                  Relative path of the directory to serve.

OPTIONS:
  -p, --port <port>       Port for the localhost server. (default: 8080)
  --version               Show the version.
  -h, --help              Show help information.
```

As a Swift Package
------------------
Add RESTless as a dependency to your `Package.swift` manifest to use it in a Swift project:

```swift
let package = Package(
  ...
  dependencies: [
    .package(url: "https://github.com/jarrodtaylor/RESTless", from: "1.0.0")
  ],
  ...
  targets: [
    .target(name: "...", dependencies: [
      .product(name: "RESTless", package: "RESTless")
    ]),
  ]
  ...
)
```

Give it a path and port to start the server and a callback to see requests:

```swift
import RESTless

RESTless(path: "public/", port: 8080) {(request, response, error) in
  var message: [String] = [""]

  if let request  {message.append(request.path)}
  if let response {message.append("\(response.status.rawValue) \(response.status)")}
  if let error    {message.append("Error: \(error)")}

  print(message.joined(separator: " ").trimmingCharacters(in: .whitespaces))
}

print("Serving \(path.path()) at http://localhost:\(port)")
print("^c to stop")

// Keep the process running.
RunLoop.current.run()
```

[installer]: https://github.com/jarrodtaylor/RESTless/releases/download/v1.0.0/restless-1.0.0.pkg
