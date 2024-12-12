import ArgumentParser
import Foundation
import RESTless

@main
struct RESTlessCLI: ParsableCommand {
  static let configuration = CommandConfiguration(
    commandName: "restless",
    abstract: "Static web server for MacOS.",
    discussion: "Visit https://github.com/jarrodtaylor/RESTless to learn more.",
    version: "1.0.0")

  @Argument(help: "Path to the directory to serve.")
  var source: String = "."

  @Option(name: .shortAndLong, help: "Port for the localhost server. (default: 80)")
  var port: UInt16?

  mutating func run() throws {
    source = source.split(separator: "/").joined(separator: "/")
    if port == nil { port = 80 }

    URL(string: source, relativeTo: URL.currentDirectory())!.restless(port: port!)
    { req, res, err in
      var message: [String] = [""]
      if let req { message.append(req.path) }
      if let res { message.append("(\(res.status.rawValue) \(res.status))") }
      if let err { message.append("Error: \(err)") }
      print(message.joined(separator: " ").trimmingCharacters(in: .whitespaces))
    }

    print("Serving \(source) at http://localhost:\(port!)\n^c to stop")

    RunLoop.current.run()
  }
}
