import Foundation

//sourcery: AutoMockable
protocol ThrowingVarProtocol {
    var testVariableThatThrow: Bool { get throws }
}
