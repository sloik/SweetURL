import Foundation

public extension URLRequest {
    var asCurlCommand: String? {
        guard let url = url else { return nil }
        var baseCommand = "curl '\(url.absoluteString)'"
        if let httpMethod = httpMethod, httpMethod.uppercased() != "GET" {
            baseCommand += " -X \(httpMethod.uppercased())"
        }
        if let headers = allHTTPHeaderFields {
            for (key, value) in headers {
                let escapedValue = value.replacingOccurrences(of: "'", with: "'\\''")
                baseCommand += " -H '\(key): \(escapedValue)'"
            }
        }
        if let bodyData = httpBody, let bodyString = String(data: bodyData, encoding: .utf8) {
            let escapedBody = bodyString.replacingOccurrences(of: "'", with: "'\\''")
            baseCommand += " -d '\(escapedBody)'"
        }
        return baseCommand
    }
}
