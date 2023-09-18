import Foundation

public extension URLRequest {

    /// Returns a curl command that can be used to reproduce the request.
    ///
    /// - Note: This is a very simple implementation that will not work for
    ///         all requests. But you can create a PR to improve it.
    ///
    /// ```swift
    /// let request = URLRequest(url: URL(string: "https://example.com/api/data")!
    ///     .asRequest
    ///     .set(method: .post)
    ///     .set(header: .contentType, value: .applicationJSON)
    ///     .set(body: try! JSONEncoder().encode( Payload(prop1: "val1", prop2: 42) ))
    ///
    /// let curlCommand = request.asCurlCommand
    /// 
    /// print(curlCommand ?? "Failed to generate curl command")
    /// ```
    /// Example will print a cURL command string with a caveat that
    /// strings will be escaped so you will have to sanitise them before
    /// pasting in to terminal.
    ///
    /// ```
    /// curl 'https://example.com/endpoint?param1=value1&param2=value2' \
    ///     -X POST \
    ///     -H 'Content-Type: application/json' \
    ///     -d '{"prop1":"val1","prop2":42}'
    /// ```
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

    /// Set the body of the request to the given `Data` object.
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
    /// Set the HTTP method of the request.
    func set(method: HTTPMethod) -> Self {
        var copy = self
        copy.httpMethod = method.rawValue
        return copy
    }
}

public extension URLRequest {

    /// Defines HTTP headers
    enum Header {

        /// Defines HTTP header keys
        public enum Key: String {
            case contentType = "Content-Type"
            case authorization = "Authorization"
        }

        /// Defines HTTP header values
        public enum Value: String {
            case applicationJSON = "application/json"
        }
    }

    /// Set the HTTP header of the request.
    @discardableResult
    func set(header: Header.Key, value: Header.Value) -> Self {
        set(header: header.rawValue, value: value.rawValue)
    }

    /// Set the HTTP header of the request.
    @discardableResult
    func set(header: Header.Key, value: String) -> Self {
        set(header: header.rawValue, value: value)
    }

    /// Set the HTTP header of the request.
    @discardableResult
    func set(header: String, value: String) -> Self {
        var copy = self
        var headers = copy.allHTTPHeaderFields ?? [:]

        headers[header] = value

        copy.allHTTPHeaderFields = headers
        return copy
    }
}
