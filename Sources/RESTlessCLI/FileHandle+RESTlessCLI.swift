import Foundation

extension FileHandle: @retroactive TextOutputStream {
  nonisolated(unsafe) static var stderr = FileHandle.standardError
  public func write(_ message: String)
    {write(message.data(using: .utf8)!)}
}

func log(_ message: String)
  {print(message, to:&FileHandle.stderr)}
