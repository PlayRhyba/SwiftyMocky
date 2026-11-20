import Foundation

//sourcery: AutoMockable
public protocol DataProviding: Sendable {
    func getData<T: Decodable>(from url: String) async throws -> T
}

//sourcery: AutoMockable
protocol SendableService: Sendable {
    var name: String { get set }
    var timeout: Double? { get }
    static var instances: Int { get set }

    func fetch(id: Int) -> String
    func store(_ value: String) throws
}

/// Inherits `Sendable` indirectly, through `SendableService`.
//sourcery: AutoMockable
protocol RefinedSendableService: SendableService {
    func refresh() async
}
