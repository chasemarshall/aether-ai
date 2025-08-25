import Foundation

struct SSEStreamDecoder {
    private let onToken: (String) -> Void
    private let onComplete: (Result<Void, Error>) -> Void
    private var buffer = ""
    
    init(onToken: @escaping (String) -> Void, onComplete: @escaping (Result<Void, Error>) -> Void) {
        self.onToken = onToken
        self.onComplete = onComplete
    }
    
    mutating func process(bytes: URLSession.AsyncBytes) async {
        do {
            for try await byte in bytes {
                guard let char = String(bytes: [byte], encoding: .utf8) else { continue }
                buffer += char
                
                // Process complete lines
                while let lineEndIndex = buffer.firstIndex(of: "\n") {
                    let line = String(buffer[..<lineEndIndex]).trimmingCharacters(in: .whitespacesAndNewlines)
                    buffer.removeSubrange(...lineEndIndex)
                    
                    await processLine(line)
                }
            }
            onComplete(.success(()))
        } catch {
            onComplete(.failure(error))
        }
    }
    
    private func processLine(_ line: String) async {
        // Skip empty lines and non-data lines
        guard !line.isEmpty, line.hasPrefix("data: ") else { return }
        
        let data = String(line.dropFirst(6)) // Remove "data: " prefix
        
        // Check for stream end
        if data == "[DONE]" {
            onComplete(.success(()))
            return
        }
        
        // Parse JSON delta
        guard let jsonData = data.data(using: .utf8) else { return }
        
        do {
            if let json = try JSONSerialization.jsonObject(with: jsonData) as? [String: Any],
               let choices = json["choices"] as? [[String: Any]],
               let firstChoice = choices.first,
               let delta = firstChoice["delta"] as? [String: Any] {
                
                // Try content first, then text as fallback
                let content = delta["content"] as? String ?? delta["text"] as? String
                
                if let content = content, !content.isEmpty {
                    await MainActor.run {
                        onToken(content)
                    }
                }
            }
        } catch {
            // Silently ignore JSON parsing errors for malformed chunks
        }
    }
}
