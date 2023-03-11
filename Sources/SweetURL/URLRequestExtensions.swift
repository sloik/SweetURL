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

    /// Defines HTTP methods
    enum HTTPMethod: String {
        /// Requests a representation of the specified resource.
        /// It is used to retrieve information from the server.
        case get = "GET"
        /// Submits an entity to the specified resource,
        /// often causing a change in state or side effects on the server.
        case post = "POST"
        /// Replaces the target resource with the updated content
        /// sent in the request payload.
        case put = "PUT"
        /// Removes all current representations of the target
        /// resource given by a URI.
        case delete = "DELETE"
        /// Applies partial modifications to a resource.
        case patch = "PATCH"
        /// Requests a response identical to a GET request,
        /// but without the response body.
        case head = "HEAD"
        /// Describes the communication options for
        /// the target resource.
        case options = "OPTIONS"
        /// Performs a message loop-back test along the path
        /// to the target resource.
        case trace = "TRACE"
        ///  Establishes a network connection to a server using
        ///  a specified tunnelling protocol.
        case connect = "CONNECT"
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
