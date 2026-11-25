import Testing
import SwiftyMocky
#if os(iOS)
    @testable import Mocky_Example_iOS
#elseif os(tvOS)
    @testable import Mocky_Example_tvOS
#else
    @testable import Mocky_Example_macOS
#endif

/// SwiftyMocky failures inside a `@Test` are recorded with Swift Testing's `Issue.record`
/// (issue kind `.unconditional`), not routed through XCTest interop.
@Suite("Failure reporting in Swift Testing")
struct SwiftTestingFailureReportingTests {

    @Test func verifyFailureIsRecordedAsIssue() {
        let mock = SimpleProtocolWithMethodsMock()
        let line = #line + 3

        withKnownIssue {
            Verify(mock, .simpleMethod())
        } matching: { issue in
            isSwiftyMockyIssue(
                issue,
                containing: "Expected: more than or equal to 1 invocations of `.simpleMethod()`, but was: 0.",
                line: line
            )
        }
    }

    @Test func verifyCountFailureIsRecordedAsIssue() {
        let mock = SimpleProtocolWithMethodsMock()
        mock.simpleMethod()
        let line = #line + 3

        withKnownIssue {
            Verify(mock, .never, .simpleMethod())
        } matching: { issue in
            isSwiftyMockyIssue(
                issue,
                containing: "Expected: none invocations of `.simpleMethod()`, but was: 1.",
                line: line
            )
        }
    }

    #if os(macOS)
    @Test func missingStubTerminatesWithFailure() async {
        await #expect(processExitsWith: .failure) {
            _ = SimpleProtocolWithMethodsMock().simpleMehtodThatReturns()
        }
    }
    #endif

    // MARK: - Helpers

    private func isSwiftyMockyIssue(_ issue: Issue, containing message: String, line: Int) -> Bool {
        guard case .unconditional = issue.kind else { return false }
        return issue.comments.contains { $0.rawValue.contains(message) }
            && issue.sourceLocation?.fileName == "SwiftTestingFailureReportingTests.swift"
            && issue.sourceLocation?.line == line
    }
}
