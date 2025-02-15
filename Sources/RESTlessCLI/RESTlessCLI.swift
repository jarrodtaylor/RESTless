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
    print(path, port)
  }
}
