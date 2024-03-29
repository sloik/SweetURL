import Foundation

import HTTPTypes
import HTTPTypesFoundation

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

        let sortedHeaders = allHTTPHeaderFields?
            .sorted(by: { (l: (key: String, value: String), r: (key: String, value: String)) in
                return l.key > r.key
        })

        if let headers = sortedHeaders {
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

    @discardableResult
    /// Set the HTTP method of the request.
    func set(method: HTTPRequest.Method) -> Self {
        var copy = self
        copy.httpMethod = method.rawValue
        return copy
    }
}

public extension HTTPField {
    enum Value: String {
        case applicationJSON = "application/json"
    }
}

public extension URLRequest {

    @discardableResult
    func set(header: HTTPField.Name, value: HTTPField.Value) -> Self {
        set(field: HTTPField(name: header, value: value.rawValue))
    }

    @discardableResult
    func set(field: HTTPField) -> Self {
        set(header: field.name.canonicalName, value: field.value)
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
