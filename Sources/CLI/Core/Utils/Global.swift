import Foundation
import PathKit

public let kSourceryVersion = "2.4.1"
public let kDefaultSourceryCommand: @Sendable (String) -> String = { version in "mint run krzysztofzablocki/Sourcery@\(version) sourcery"}

public protocol AutoMockable {}

public enum MockyError: Swift.Error {
    case targetNotFound
    case projectNotFound
    case mockNotFound
    case internalFailure
    case writingError
    case overrideWarning
    case versionMismatch
}
