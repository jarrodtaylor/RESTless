import ArgumentParser
import Foundation
import RESTless

@main
struct RESTlessCLI: ParsableCommand {
  static let configuration = CommandConfiguration(commandName: "restless", version: "1.0.0")

  mutating func run() {
    print("Hello, world!")
  }
}
