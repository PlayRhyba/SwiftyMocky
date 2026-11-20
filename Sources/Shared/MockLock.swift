import Foundation

/// [Internal] Lock used by generated mocks to protect their state
/// (invocations, stubs, performs and property values), so mocks can be used
/// from multiple threads and conform to `Sendable`.
///
/// The lock is recursive, so generated helpers can nest calls. Generated code
/// never calls user closures (perform closures, stub producers) while holding it.
public final class MockLock: @unchecked Sendable {
    private let lock = NSRecursiveLock()

    public init() {}

    /// Runs `body` while holding the lock.
    @discardableResult
    public func sync<T>(_ body: () throws -> T) rethrows -> T {
        lock.lock()
        defer { lock.unlock() }
        return try body()
    }
}
