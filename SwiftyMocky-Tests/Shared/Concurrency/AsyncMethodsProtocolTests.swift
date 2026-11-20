import XCTest
import SwiftyMocky
#if os(iOS)
    @testable import Mocky_Example_iOS
#elseif os(tvOS)
    @testable import Mocky_Example_tvOS
#else
    @testable import Mocky_Example_macOS
#endif

class AsyncMethodsProtocolTests: XCTestCase {

    // MARK: - Tests

    func testAsyncMethod() async {
        let mock = AsyncMethodsProtocolMock()

        Given(mock, .loadListOfItems(willReturn: ["aaa", "bbb"]))

        // Async keyword is not yet supported by sourcery, but casting to protocol silences warning about missing async.
        let result = await (mock as any AsyncMethodsProtocol).loadListOfItems()
        XCTAssertEqual(result, ["aaa", "bbb"])
    }
}
