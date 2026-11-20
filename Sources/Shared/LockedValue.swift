import Foundation

/// [Internal] Thread-safe box for mutable state.
///
/// Backs library-wide state (like `Matcher.default`) and the internal state of
/// generated mocks, so they can be read and mutated from any thread or
/// concurrency domain. State kept inside the box can only be reached through
/// the lock.
///
/// The lock is not recursive: code running inside `withValue` must not access
/// the same box again. Generated mocks copy what they need out of the box and
/// call user code (perform closures, parameter matchers) outside of it.
public final class LockedValue<Value>: @unchecked Sendable {
    private let lock = NSLock()
    private var storage: Value

    public init(_ value: Value) {
        storage = value
    }

    /// Current value. Every read and write takes the lock.
    public var value: Value {
        get { lock.lock(); defer { lock.unlock() }; return storage }
        set { lock.lock(); defer { lock.unlock() }; storage = newValue }
    }

    /// Performs read-modify-write atomically.
    @discardableResult
    public func withValue<Result>(_ body: (inout Value) throws -> Result) rethrows -> Result {
        lock.lock(); defer { lock.unlock() }
        return try body(&storage)
    }
}
