
import Foundation

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
    var asRequest: URLRequest { self.asRequest(method: URLRequest.HTTPMethod.get ) }

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
    func asRequest(method: URLRequest.HTTPMethod) -> URLRequest {
        var request = asRequest
        request.httpMethod = method.rawValue
        return request
    }
}
