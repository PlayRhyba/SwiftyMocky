#if canImport(XCTest) && !SWIFTY_PROTOTYPE
import XCTest
#endif
import Foundation

/// You can use this class if there is need to define custom
/// assertion handler. You can use its static handler closure to alter default
/// behaviour.
///
/// If it is `nil`, the default `assert` method would be used.
public final class MockyAssertion {
    /// You can use it to define assertion behaviour.
    /// Leave blank to not assert at all.
    public static var handler: ((Bool, String, StaticString, UInt) -> Void)? {
        get { _handler.value }
        set { _handler.value = newValue }
    }
    private static let _handler = LockedValue<((Bool, String, StaticString, UInt) -> Void)?>(nil)
}

/// [internal] Assertion used by mocks and Verify methods
///
/// - Parameters:
///   - expression: Expression to assert on
///   - message: Message
///   - file: File name (leave default)
///   - line: Line (leave default)
public func MockyAssert(
    _ expression: @autoclosure () -> Bool,
    _ message: @autoclosure () -> String = "Verify failed",
    file: StaticString = #filePath,
    line: UInt = #line
) {
    guard let handler = MockyAssertion.handler else {
        return XCTMockyAssert(expression(), message(), file: file, line: line)
    }

    handler(expression(), message(), file, line)
}


/// [internal] Assertion used by mocks and Verify methods
///
/// - Parameters:
///   - expression: Expression to assert on
///   - message: Message
///   - file: File name (leave default)
///   - line: Line (leave default)
private func XCTMockyAssert(
    _ expression: @autoclosure () -> Bool,
    _ message: @autoclosure () -> String = "Verify failed",
    file: StaticString = #filePath,
    line: UInt = #line
) {
    #if canImport(XCTest) && !SWIFTY_PROTOTYPE
    XCTAssert(expression(), message(), file: file, line: line)
    #else
    // `assert` defaults to `#file`; passing our `#filePath` on is intended (parentheses silence the mismatch warning).
    assert(expression(), message(), file: (file), line: line)
    #endif
}
