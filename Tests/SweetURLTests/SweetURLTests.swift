import XCTest
@testable import SweetURL
import SnapshotTesting

final class SweetURLTests: XCTestCase {

    override func setUp() async throws {
        try await super.setUp()
        isRecording = false
    }

    func test_asCurlCommand() throws {

        let sut = testURL.asRequest
        assertSnapshot(matching: sut.asCurlCommand!, as: .lines)

    }

    func test_asCurlCommand1() throws {

        struct Payload: Codable {
            let prop1: String
        }

        assertSnapshot(
            matching: testURL
                .asRequest
                .set(method: .post)
                .set(header: .contentType, value: .applicationJSON)
                .set(body: try! JSONEncoder().encode( Payload(prop1: "val1") ))
                .asCurlCommand!,
            as: .lines
        )
    }

    func test_asCurlCommand_keepsAlreadyEncodedURL() throws {
        let url = try XCTUnwrap(URL(string: "https://e.com/a%20b?q=1#frag"))
        let curl = try XCTUnwrap(url.asRequest.asCurlCommand)
        XCTAssertEqual(curl, "curl 'https://e.com/a%20b?q=1#frag'")
    }

    func test_asCurlCommand_shellEscapesSingleQuote() throws {
        let url = try XCTUnwrap(URL(string: "https://e.com/it's"))
        let curl = try XCTUnwrap(url.asRequest.asCurlCommand)
        XCTAssertEqual(curl, "curl 'https://e.com/it'\\''s'")
    }

    func test_firstQueryItem() throws {

        XCTAssertEqual(
            try XCTUnwrap( testURL.queryValues("param1") ),
            ["value1"]
        )

        XCTAssertEqual(
            try XCTUnwrap( testURL.queryValues("param2") ),
            ["value2"]
        )

        XCTAssertEqual(
            try XCTUnwrap( testURL.queryValues("param3") ),
            ["value3", "value3"]
        )
    }
}

private var testURL: URL { URL(string: "https://example.com/endpoint?param1=value1&param2=value2&param3=value3&param3=value3"
)! }


