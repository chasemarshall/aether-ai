import Foundation

struct HTTPClient {
    static let shared = HTTPClient()
    
    private let session: URLSession
    
    init() {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 60
        config.timeoutIntervalForResource = 300
        self.session = URLSession(configuration: config)
    }
    
    func bytes(for request: URLRequest) async throws -> (URLSession.AsyncBytes, URLResponse) {
        return try await session.bytes(for: request)
    }
    
    func data(for request: URLRequest) async throws -> (Data, URLResponse) {
        return try await session.data(for: request)
    }
}
