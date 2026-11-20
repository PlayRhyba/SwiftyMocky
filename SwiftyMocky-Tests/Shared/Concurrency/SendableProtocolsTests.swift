import XCTest
import SwiftyMocky
#if os(iOS)
    @testable import Mocky_Example_iOS
#elseif os(tvOS)
    @testable import Mocky_Example_tvOS
#else
    @testable import Mocky_Example_macOS
#endif

private struct Item: Decodable, Equatable {
    let id: Int
}

private enum DataProvidingError: Error {
    case failed
}

class SendableProtocolsTests: XCTestCase {

    // MARK: - Generic async throwing method

    func testGenericAsyncThrowingMethodReturnsStub() async throws {
        let mock = DataProvidingMock()
        Given(mock, .getData(from: .value("items/1"), willReturn: Item(id: 1)))

        let item: Item = try await (mock as any DataProviding).getData(from: "items/1")

        XCTAssertEqual(item, Item(id: 1))
        Verify(mock, 1, .getData(from: .value("items/1")))
        Verify(mock, 0, .getData(from: .value("items/2")))
    }

    func testGenericAsyncThrowingMethodThrowsStubbedError() async {
        let mock = DataProvidingMock()
        Given(mock, .getData(from: .any, willThrow: DataProvidingError.failed))

        do {
            let _: Item = try await (mock as any DataProviding).getData(from: "items/1")
            XCTFail("Expected an error")
        } catch {
            XCTAssertTrue(error is DataProvidingError)
        }
    }

    // MARK: - Sendable

    func testMockCanBeCapturedInDetachedTask() async {
        let mock = SendableServiceMock()
        Given(mock, .fetch(id: .any, willReturn: "value"))

        let result = await Task.detached { mock.fetch(id: 1) }.value

        XCTAssertEqual(result, "value")
        Verify(mock, 1, .fetch(id: .value(1)))
    }

    func testIndirectlySendableProtocolMockIsSendable() async {
        let mock = RefinedSendableServiceMock()

        await Task.detached { await (mock as any RefinedSendableService).refresh() }.value

        Verify(mock, 1, .refresh())
    }

    // MARK: - Concurrent access

    func testConcurrentMethodCallsAndPropertyAccessAreRecorded() async {
        let mock = SendableServiceMock()
        Given(mock, .fetch(id: .any, willReturn: "value"))
        Given(mock, .timeout(getter: 1.0))
        let iterations = 1000

        await withTaskGroup(of: Void.self) { group in
            for index in 0..<iterations {
                group.addTask {
                    _ = mock.fetch(id: index)
                    mock.name = "name \(index)"
                    _ = mock.name
                    _ = mock.timeout
                    Given(mock, .fetch(id: .value(-1), willReturn: "other"))
                }
            }
        }

        Verify(mock, .exactly(iterations), .fetch(id: .any))
        Verify(mock, .exactly(iterations), .name(set: .any))
        Verify(mock, .exactly(iterations), .name)
        Verify(mock, .exactly(iterations), .timeout)
    }

    func testConcurrentStaticPropertyAccessIsRecorded() async {
        SendableServiceMock.resetMock()
        defer { SendableServiceMock.resetMock() }
        let iterations = 1000

        await withTaskGroup(of: Void.self) { group in
            for index in 0..<iterations {
                group.addTask {
                    SendableServiceMock.instances = index
                    _ = SendableServiceMock.instances
                }
            }
        }

        Verify(SendableServiceMock.self, .exactly(iterations), .instances(set: .any))
        Verify(SendableServiceMock.self, .exactly(iterations), .instances)
    }
}
