import Foundation

public extension URLRequest {
    var asCurlCommand: String? {

        guard let escapedURL = url?.absoluteString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else { return nil }

        var lines: [String] = []
        lines.append(
            """
            curl '\(escapedURL)'
            """
            )

        if let method = httpMethod, method.uppercased() != "GET" {
            lines.append( "   -X \(method)" )
        }

        if let headers = allHTTPHeaderFields {
            for (key, value) in headers {
                let escapedValue = value.replacingOccurrences(of: "'", with: "'\\''")
                lines.append( "   -H '\(key): \(escapedValue)'" )
            }
        }

        if let bodyData = httpBody, let bodyString = String(data: bodyData, encoding: .utf8) {
            let escapedBody = bodyString.replacingOccurrences(of: "'", with: "'\\''")
            lines.append("   -d '\(escapedBody)'")

        }


        return lines.joined(separator: " \\\n")
    }
}

public extension URLRequest {
    @discardableResult
    func set(body: Data) -> Self {
        var copy = self

        copy.httpBody = body

        return copy
    }
}

public extension URLRequest {

    enum HTTPMethod: String {
        case get = "GET"
        case post = "POST"
    }

    @discardableResult
    func set(method: HTTPMethod) -> Self {
        var copy = self
        copy.httpMethod = method.rawValue
        return copy
    }
}

public extension URLRequest {

    enum Header: String {
        case contentType = "Content-Type"
    }

    @discardableResult
    func set(header: Header, value: String) -> Self {
        var copy = self
        var headers = copy.allHTTPHeaderFields ?? [:]

        headers[header.rawValue] = value

        copy.allHTTPHeaderFields = headers
        return copy
    }

}

extension URL {
    var asRequest: URLRequest { .init(url: self) }
}
