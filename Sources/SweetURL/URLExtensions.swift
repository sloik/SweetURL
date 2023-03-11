
import Foundation

public extension URL {

    /// `URLRequest` object form url.
    var asRequest: URLRequest { .init(url: self) }
}
