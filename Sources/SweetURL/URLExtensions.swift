
import Foundation

import HTTPTypes
import HTTPTypesFoundation

public extension URL {

    /// `URLRequest` object form url.
    /// Request has it's HTTP method set to `GET`
    ///
    /// ```
    /// // Create a URL
    /// let url = URL(string: "https://example.com/api/data")!
    /// // Create a URLRequest using the URL
    /// let request = url.asRequest
    ///     ```
    var asRequest: URLRequest {
        var req = URLRequest(url: self)
        req.httpMethod = HTTPRequest.Method.get.rawValue
        return req
    }

    /// `URLComponents` object form url.
    var urlComponents: URLComponents? { URLComponents(url: self, resolvingAgainstBaseURL: false) }

    /// `URLQueryItem` array form url.
    var queryItems: [URLQueryItem]? { urlComponents?.queryItems }

    /// Creates a `URLRequest` object form url with a given HTTP method.
    /// - Parameter method: HTTP method to use
    /// - Returns: `URLRequest` object
    /// ```
    /// // Create a URL
    /// let url = URL(string: "https://example.com/api/data")!
    ///
    /// // Create a URLRequest using the URL
    /// let request = url.asRequest(method: .post)
    /// ```
    func asRequest(method: HTTPRequest.Method) -> URLRequest {
        var request = asRequest
        request.httpMethod = method.rawValue
        return request
    }

    /// Gets all query values matching name.
    /// - Parameter name: Name of the query parameter that is used as a predicate.
    /// - Returns: `[String]` with values for given parameters or
    ///             `.none` where no query parameters match name.
    ///
    /// Example:
    ///
    /// ```
    /// let url = URL(string: "https://example.com/endpoint?param3=value3&param3=value3")
    ///
    /// url.queryValues("param3") // ["value3", "value3"]
    ///
    /// ```
    func queryValues(_ name: String) -> [String]? {
        queryItems?
            .filter { item in
                item.name == name
            }
            .compactMap( \.value )
    }
}
