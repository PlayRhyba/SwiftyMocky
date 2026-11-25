import Foundation
#if canImport(Testing) && !SWIFTY_PROTOTYPE
import Testing
#endif

/// [Internal] Reports SwiftyMocky failures to Swift Testing when they happen inside a running `@Test`.
enum SwiftTestingSupport {
    /// Records `message` as a Swift Testing issue when called from a running `@Test`.
    ///
    /// `Test.current` is task-local, so calls made outside the test's task tree (detached tasks,
    /// unstructured threads) are not attributed to it and return `false`.
    ///
    /// - Parameters:
    ///   - message: Failure message
    ///   - file: File path (`#filePath`) where the failure should be reported
    ///   - line: Line where the failure should be reported
    /// - Returns: `true` if the issue was recorded, `false` if no Swift Testing test is running
    ///   (the caller should fall back to XCTest).
    static func recordIssueIfTestRunning(_ message: String, file: StaticString, line: UInt) -> Bool {
        #if canImport(Testing) && !SWIFTY_PROTOTYPE
        guard Test.current != nil else { return false }
        let path = file.description
        let url = URL(fileURLWithPath: path)
        // SwiftyMocky only captures `#filePath`; Swift Testing displays the file name part of `fileID`.
        let fileID = "\(url.deletingLastPathComponent().lastPathComponent)/\(url.lastPathComponent)"
        Issue.record(
            Comment(rawValue: message),
            sourceLocation: SourceLocation(fileID: fileID, filePath: path, line: max(Int(line), 1), column: 1)
        )
        return true
        #else
        return false
        #endif
    }
}
