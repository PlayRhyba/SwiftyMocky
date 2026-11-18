//
//  ExampleProtocols.swift
//  Mocky_Example
//
//  Created by Andrzej Michnia on 25.10.2017.
//  Copyright © 2017 MakeAWishFoundation. All rights reserved.
//

import Foundation

//sourcery: AutoMockable
protocol UserStorageType {
    func surname(for name: String) -> String
    func storeUser(name: String, surname: String)
}

//sourcery: AutoMockable
protocol UserNetworkType {
    init(config: NetworkConfig)
    init(baseUrl: String)

    func getUser(for id: String, completion: (User?) -> Void)
    func getUserEscaping(for id: String, completion: @escaping (User?,(any Error)?) -> Void)
    func doSomething(prop: @autoclosure () -> String)
    func testDefaultValues(value: String)
}

extension UserNetworkType {
    func testDefaultValues(value: String = "asd") {

    }
}

//sourcery: AutoMockable
protocol EmptyProtocol { }

// Used by ExampleTests - declared here, so the conformance is not retroactive.
extension String: EmptyProtocol { }

//sourcery: AutoMockable
protocol AMassiveTestProtocol {
    var nonOptionalClosure: () -> Void { get set }
    var optionalClosure: (() -> Int)? { get set }
    var implicitelyUnwrappedClosure: (() -> Void)! { get set }

    static var optionalClosure: (() -> Int)? { get set }

    func methodThatThrows() throws
    func methodThatReturnsAndThrows(param: String) throws -> Int
    func methodThatRethrows(param: (String) throws -> Int) rethrows -> Int

    static func methodThatThrows() throws
    static func methodThatReturnsAndThrows(param: String) throws -> Int
    static func methodThatRethrows(param: (String) throws -> Int) rethrows -> Int

    init()
    init(_ sth: Int)
}

// MARK: - Existential types (`any P`)

protocol ExistentialService {
    var identifier: String { get }
}
protocol ExistentialOther {}

/// Uses `any` in every supported position, so generated mocks are verified to compile
/// with the `ExistentialAny` upcoming feature enabled.
//sourcery: AutoMockable
protocol ExistentialAnyProtocol {
    var service: any ExistentialService { get set }
    var optionalService: (any ExistentialService)? { get set }
    var services: [any ExistentialService] { get }
    var servicesById: [String: any ExistentialService] { get }
    var composed: any ExistentialService & ExistentialOther { get }
    var optionalComposed: (any ExistentialService & ExistentialOther)? { get }
    var numbers: (any Collection<Int>)? { get }
    static var shared: any ExistentialService { get set }

    func take(_ service: any ExistentialService)
    func takeOptional(_ service: (any ExistentialService)?)
    func takeMany(_ services: [any ExistentialService])
    func takeVariadic(_ services: any ExistentialService...)
    func takeInout(_ service: inout any ExistentialService)
    func takeCompletion(_ completion: @escaping ((any Error)?) -> Void)
    func takeResult(_ completion: @escaping (Result<Int, any Error>) -> Void)
    func makeService() -> any ExistentialService
    func makeOptionalService() -> (any ExistentialService)?
    func makeThrowing() throws -> any ExistentialService
    func makeAsync() async throws -> any ExistentialService
    func takeGeneric<T: ExistentialService>(_ value: T, other: any ExistentialOther) -> T
    func convert(_ error: any Error) -> any Error
    static func makeShared() -> any ExistentialService

    subscript(index: Int) -> any ExistentialService { get set }
    subscript(key: String) -> (any ExistentialService)? { get }
}
