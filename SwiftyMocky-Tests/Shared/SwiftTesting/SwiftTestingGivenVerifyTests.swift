import Testing
import SwiftyMocky
#if os(iOS)
    @testable import Mocky_Example_iOS
#elseif os(tvOS)
    @testable import Mocky_Example_tvOS
#else
    @testable import Mocky_Example_macOS
#endif

private struct Record: Decodable, Equatable {
    let id: Int
}

/// Regular SwiftyMocky usage from Swift Testing tests.
@Suite("Given / Verify / Perform in Swift Testing")
struct SwiftTestingGivenVerifyTests {

    @Test func givenReturnsStubbedValues() {
        let mock = SimpleProtocolWithMethodsMock()
        Given(mock, .simpleMehtodThatReturns(willReturn: 1, 2))
        Given(mock, .simpleMehtodThatReturns(param: .value("a"), willReturn: "A"))
        Given(mock, .simpleMehtodThatReturns(param: .any, willReturn: "other"))

        #expect(mock.simpleMehtodThatReturns() == 1)
        #expect(mock.simpleMehtodThatReturns() == 2)
        #expect(mock.simpleMehtodThatReturns(param: "a") == "A")
        #expect(mock.simpleMehtodThatReturns(param: "b") == "other")
    }

    @Test func verifyCountsInvocations() {
        let mock = SimpleProtocolWithMethodsMock()

        mock.simpleMethod()
        mock.simpleMethod()

        Verify(mock, .simpleMethod())
        Verify(mock, 2, .simpleMethod())
        Verify(mock, .moreOrEqual(to: 1), .simpleMethod())
        Verify(mock, .never, .simpleMehtodThatReturns(param: .any))
    }

    @Test func performRunsClosureWithArguments() {
        let mock = SimpleProtocolWithMethodsMock()
        let received = LockedValue<[String]>([])
        Given(mock, .simpleMehtodThatReturns(param: .any, willReturn: ""))
        Perform(mock, .simpleMehtodThatReturns(param: .any, perform: { value in
            received.withValue { $0.append(value) }
        }))

        _ = mock.simpleMehtodThatReturns(param: "x")
        _ = mock.simpleMehtodThatReturns(param: "y")

        #expect(received.value == ["x", "y"])
    }

    @Test(arguments: [1, 2, 3])
    func parameterizedSendableMock(id: Int) async throws {
        let mock = DataProvidingMock()
        Given(mock, .getData(from: .value("records/\(id)"), willReturn: Record(id: id)))

        let record: Record = try await (mock as any DataProviding).getData(from: "records/\(id)")

        #expect(record == Record(id: id))
        Verify(mock, 1, .getData(from: .value("records/\(id)")))
    }
}
