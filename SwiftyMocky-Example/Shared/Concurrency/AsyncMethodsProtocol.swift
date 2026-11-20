import Foundation

//sourcery: AutoMockable
protocol AsyncMethodsProtocol {
    func loadListOfItems() async -> [String]
}
