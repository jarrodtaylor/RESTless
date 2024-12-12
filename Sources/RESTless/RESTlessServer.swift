import Foundation
import Network

final class RESTlessServer: Sendable {
  let callback: @Sendable (RESTlessRequest?, RESTlessResponse?, NWError?) -> Void
	let listener: NWListener
	let path: String

	@discardableResult init(path: String, port: UInt16,
	  callback: @escaping @Sendable (RESTlessRequest?, RESTlessResponse?, NWError?) -> Void)
	{
		self.callback = callback
		self.path = path
		self.listener = try! NWListener(using: .tcp, on: NWEndpoint.Port(rawValue: port)!)
		listener.newConnectionHandler = handleConnection
		listener.start(queue: .main)
	}

	@Sendable func handleConnection(_ connection: NWConnection) {
		connection.start(queue: .main)
		receive(from: connection)
	}

	func receive(from connection: NWConnection) {
		connection.receive(minimumIncompleteLength: 1, maximumLength: connection.maximumDatagramSize)
		{ content, _, isComplete, error in
			if let error {
			  self.callback(nil, nil, error)
			}

			else if let content, let request = RESTlessRequest(content) {
				self.respond(on: connection, request: request)
			}

			if !isComplete {
			  self.receive(from: connection)
			}
		}
	}

	func respond(on connection: NWConnection, request: RESTlessRequest) {
		guard request.method == "GET" else {
			let response = RESTlessResponse(.teapot)
			self.callback(request, response, nil)
			connection.send(content: response.data, completion: .idempotent)
			return
		}

		func findFile(_ filePath: String) -> String? {
			guard let foundPath = [filePath, filePath + "/index.html", filePath + "index.htm"]
				.first(where: {
					var isDirectory: ObjCBool = false
					return FileManager.default.fileExists(atPath: $0, isDirectory: &isDirectory)
					? !isDirectory.boolValue : false
				})
			else { return nil }

			return foundPath
		}

		guard
		  let filePath = findFile(self.path + request.path),
			let response = try? RESTlessResponse(filePath: filePath)
		else {
			let response = RESTlessResponse(.notFound)
			callback(request, response, nil)
			connection.send(content: response.data, completion: .idempotent)
			return
		}

		callback(request, response, nil)
		connection.send(content: response.data, completion: .idempotent)
	}
}
