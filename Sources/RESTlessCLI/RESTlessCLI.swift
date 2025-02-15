import ArgumentParser
import Foundation
import RESTless

@main
struct RESTlessCLI: ParsableCommand {
  static let configuration = CommandConfiguration(
    commandName: "restless", version: "1.0.0")

  @Argument(
          help: "Relative path of the directory to serve.",
    completion: .directory,
     transform: {URL(string: $0, relativeTo: URL.currentDirectory())!})
  var path: URL

  @Option(
    name: .shortAndLong,
    help: "Port for the localhost server.")
  var port: UInt16 = 8080

  func validate() throws {
    guard FileManager.default.fileExists(atPath: path.path())
    else {throw ValidationError("'\(path.path())' does not exist")}
  }

  mutating func run() {
    RESTless(path: path.path(), port: port) {(request, response, error) in
      var message: [String] = [""]

      if let request  {message.append(request.path)}
      if let response {message.append("\(response.status.rawValue) \(response.status)")}
      if let error    {message.append("Error: \(error)")}

      log(message.joined(separator: " ").trimmingCharacters(in: .whitespaces))
    }

    log("Serving \(path.path()) at http://localhost:\(port)")
    log("^c to stop")

    RunLoop.current.run()
  }
}
