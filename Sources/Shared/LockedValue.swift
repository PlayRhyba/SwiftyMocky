import Foundation

/// [Internal] Thread-safe box for library-wide mutable state.
///
/// Used to back public static properties (like `Matcher.default`), so they can be
/// read and reassigned from any thread or concurrency domain.
final class LockedValue<Value>: @unchecked Sendable {
    private let lock = NSLock()
    private var storage: Value

    init(_ value: Value) {
        storage = value
    }

    var value: Value {
        get { lock.lock(); defer { lock.unlock() }; return storage }
        set { lock.lock(); defer { lock.unlock() }; storage = newValue }
    }

    /// Performs read-modify-write atomically.
    @discardableResult
    func withValue<Result>(_ body: (inout Value) throws -> Result) rethrows -> Result {
        lock.lock(); defer { lock.unlock() }
        return try body(&storage)
    }
}
