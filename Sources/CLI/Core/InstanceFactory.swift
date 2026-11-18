import Foundation
import PathKit

public enum Instance {
    // The CLI runs single-threaded; tests swap the factory in setUp.
    nonisolated(unsafe) public internal(set) static var factory: any InstanceFactory = InstanceFactoryConcrete()
}

public protocol InstanceFactory: AnyObject, AutoMockable {

    // MARK: - Generation
    func resolveGenerationCommand(root: Path) throws -> any GenerationCommand
    func resolveGenerationCommand(root: Path, mockfile: Mockfile) -> any GenerationCommand
}

public class InstanceFactoryConcrete: InstanceFactory {

    fileprivate init() { }

    // MARK: - Generation
    public func resolveGenerationCommand(root: Path) throws -> any GenerationCommand {
        return try GenerationController(root: root)
    }

    public func resolveGenerationCommand(root: Path, mockfile: Mockfile) -> any GenerationCommand {
        return GenerationController(root: root, mockfile: mockfile)
    }
}