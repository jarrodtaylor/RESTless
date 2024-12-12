import Foundation
import Network

extension URL {
  public func restless(port: UInt16,
    callback: @escaping @Sendable (RESTlessRequest?, RESTlessResponse?, NWError?) -> Void)
  {
    let maskedPath = path(percentEncoded: false)
      .replacingOccurrences(of: FileManager.default.currentDirectoryPath, with: "")
      .replacingOccurrences(of: "file:///", with: "")
      .split(separator: "/")
      .joined(separator: "/")

    RESTlessServer(path: maskedPath, port: port, callback: callback)
  }
}
