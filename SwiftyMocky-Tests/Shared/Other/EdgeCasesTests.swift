//
//  EdgeCasesTests.swift
//  Mocky
//
//  Created by Andrzej Michnia on 29.09.2018.
//  Copyright © 2018 MakeAWishFoundation. All rights reserved.
//

import XCTest
import SwiftyMocky
#if os(iOS)
    #if IOS15
        @testable import Mocky_Example_iOS_15
    #else
        @testable import Mocky_Example_iOS
    #endif
#elseif os(tvOS)
@testable import Mocky_Example_tvOS
#else
@testable import Mocky_Example_macOS
#endif

class EdgeCasesTests: XCTestCase {

    override class func setUp() {
        super.setUp()
        SwiftyMockyTestObserver.setup()
    }

    func test_generics_with_custom_structs() {
        let mock = EdgeCasesGenericsProtocolMock()
        Matcher.default.register(Mytest<String, [Int]>.self) { lhs, rhs in
            return lhs.key == rhs.key
        }
        Matcher.default.register(Mytest<String, String>.self) { lhs, rhs in
            return lhs.key == rhs.key
        }
        Matcher.default.register(Mytest<String, [Int]>.Type.self)
        Matcher.default.register(Mytest<String, String>.Type.self)

        Given(mock, .getter(swapped: .any(Mytest<String,[Int]>.self), willReturn: false))
        Given(mock, .getter(swapped: .value(Mytest(value: [1,2,3], key: "key")), willProduce: { (stub: Stubber<Bool>) in
            stub.return(true)
            stub.return(false)
            stub.return(true)
            stub.return(true)
            stub.return(false)
        }))

        let key1 = Mytest(value: [1,2,3], key: "key")
        let key2 = Mytest(value: [1,1,1], key: "key")
        let key3 = Mytest(value: [1,2,3], key: "other")
        XCTAssertEqual(mock.getter(swapped: key1), true)
        XCTAssertEqual(mock.getter(swapped: key2), false)
        XCTAssertEqual(mock.getter(swapped: key2), true)
        XCTAssertEqual(mock.getter(swapped: key1), true)
        XCTAssertEqual(mock.getter(swapped: key1), false)

        XCTAssertFalse(mock.getter(swapped: key3))
        XCTAssertFalse(mock.getter(swapped: key3))
        XCTAssertFalse(mock.getter(swapped: key3))
        XCTAssertFalse(mock.getter(swapped: key3))
        XCTAssertFalse(mock.getter(swapped: key3))

        Given(mock, .getter(swapped: .any(Mytest<String,String>.self), willReturn: true))

        let key4 = Mytest(value: "[1,2,3]", key: "1")
        let key5 = Mytest(value: "whatever", key: "2")

        XCTAssertTrue(mock.getter(swapped: key4))
        XCTAssertTrue(mock.getter(swapped: key5))
    }

    func test_generics_with_custom_structs_2() {
        let mock = EdgeCasesGenericsProtocolMock()
        Matcher.default.register(Mytest<String, [Int]>.self) { lhs, rhs in
            return lhs.key == rhs.key
        }
        Matcher.default.register(Mytest<String, String>.self) { lhs, rhs in
            return lhs.key == rhs.key
        }
        Matcher.default.register(Mytest<String, [Int]>.Type.self)
        Matcher.default.register(Mytest<String, String>.Type.self)

        Given(mock, .getter(swapped: Parameter<Mytest<String, String>>.value(Mytest(value: "", key: "1")), willReturn: 1,2,3))

        let key4 = Mytest(value: "[1,2,3]", key: "1")

        XCTAssertEqual(mock.getter(swapped: key4), 1)
        XCTAssertEqual(mock.getter(swapped: key4), 2)
        XCTAssertEqual(mock.getter(swapped: key4), 3)
        XCTAssertEqual(mock.getter(swapped: key4), 1)
        XCTAssertEqual(mock.getter(swapped: key4), 2)
        XCTAssertEqual(mock.getter(swapped: key4), 3)
    }

    func test_no_stubbing_needed_for_methods_void() {
        let mock = ShouldAllowNoStubDefinedMock()

        mock.voidMethod("a")
        XCTAssertNoThrow(try mock.throwingVoidMethod("b"))
        XCTAssertNoThrow(try ShouldAllowNoStubDefinedMock.throwingVoidMethod("b"))
    }

    func test_no_stubbing_needed_for_methods_optional() {
        let mock = ShouldAllowNoStubDefinedMock()

        XCTAssertNil(mock.optionalMethod("a"))
        XCTAssertNil(mock.optionalThrowingMethod("b"))
        XCTAssertNil(ShouldAllowNoStubDefinedMock.optionalMethod("a"))
        XCTAssertNil(ShouldAllowNoStubDefinedMock.optionalThrowingMethod("b"))
    }

    func test_no_stubbing_needed_for_optional_properties() {
        let mock = ShouldAllowNoStubDefinedMock()

        XCTAssertNil(mock.property)
        XCTAssertNil(ShouldAllowNoStubDefinedMock.property)
    }

    func test_no_stubbing_needed_for_optional_subscripts() {
        let mock = ShouldAllowNoStubDefinedMock()

        XCTAssertNil(mock[0])
    }

    func test_autoclosures_flow() {
        let mock = FailsWithAutoClosureOnSwift5Mock()
        Given(mock, .connect(.any, willReturn: true))
        Perform(mock, .connect(.any, perform: { (closure: () -> String) in
            XCTAssert(closure() == "Test123")
        }))

        XCTAssert(mock.connect("Test123"))
    }

    func test_protocol_constrained_to_self_within_generic() {
        let mock = FailsWithReturnedTypeBeingGenericOfSelfMock()

        Given(mock, .methodWillReturnSelfTypedArray(willReturn: [mock]))
        XCTAssertEqual(mock.methodWillReturnSelfTypedArray().count, 1)
        Verify(mock, .methodWillReturnSelfTypedArray())

        Given(mock, .methodWillReturnSelfTypedArray2(willReturn: [mock, mock]))
        XCTAssertEqual(mock.methodWillReturnSelfTypedArray2().count, 2)
        Verify(mock, .methodWillReturnSelfTypedArray2())

        let custom = CustomGeneric(t: mock)
        Given(mock, .methodWillReturnSelfTypedCustom(willProduce: { stubber in
            stubber.return(custom)
            stubber.return(custom)
        }))
        XCTAssert(mock.methodWillReturnSelfTypedCustom().t === mock)
        Verify(mock, .methodWillReturnSelfTypedCustom())
    }

    func test_that_matcher_can_fail_gracefully() {
        // This test should be commented, as it works when it fails instead of fatal erroring
//        let mock = ProtocolWithGenericMethodsMock()
//        mock.matcher = Matcher() // Make sure there are no registrations from other tests
//
//        struct CustomObject { }
//        struct OtherObject { }
//
//        mock.matcher.register(OtherObject.self) { (_, _) -> Bool in
//            return true
//        }
//
//        Given(mock, .methodWithGeneric(lhs: .value(CustomObject()), rhs: .value(CustomObject()), willReturn: false))
//        Given(mock, .methodWithGeneric(lhs: .value(OtherObject()), rhs: .value(OtherObject()), willReturn: false))
//
//        // Should fail under mock definition
//        _ = mock.methodWithGeneric(lhs: CustomObject(), rhs: CustomObject())
//        _ = mock.methodWithGeneric(lhs: OtherObject(), rhs: OtherObject())
    }
}

// MARK: - Existential types (`any P`)

private struct ServiceStub: ExistentialService, ExistentialOther {
    let identifier: String
}

private struct ExistentialError: Error, Equatable {
    let code: Int
}

class ExistentialAnyTests: XCTestCase {

    override class func setUp() {
        super.setUp()
        SwiftyMockyTestObserver.setup()
    }

    func test_stubbing_existential_properties() {
        let mock = ExistentialAnyProtocolMock()
        let first = ServiceStub(identifier: "first")
        let second = ServiceStub(identifier: "second")

        Given(mock, .service(getter: first))
        Given(mock, .optionalService(getter: nil))
        Given(mock, .services(getter: [first, second]))
        Given(mock, .servicesById(getter: ["2": second]))
        Given(mock, .composed(getter: second))
        Given(mock, .optionalComposed(getter: nil))
        Given(mock, .numbers(getter: [1, 2, 3]))

        XCTAssertEqual(mock.service.identifier, "first")
        XCTAssertNil(mock.optionalService)
        XCTAssertEqual(mock.services.map(\.identifier), ["first", "second"])
        XCTAssertEqual(mock.servicesById["2"]?.identifier, "second")
        XCTAssertEqual(mock.composed.identifier, "second")
        XCTAssertNil(mock.optionalComposed)
        XCTAssertEqual(mock.numbers.map { Array($0) }, [1, 2, 3])
        Verify(mock, 1, .service)
        Verify(mock, 1, .optionalService)

        mock.service = second
        XCTAssertEqual(mock.service.identifier, "second")
        Verify(mock, .service(set: .matching { $0.identifier == "second" }))
    }

    func test_stubbing_static_existential_members() {
        ExistentialAnyProtocolMock.resetMock()
        Given(ExistentialAnyProtocolMock.self, .shared(getter: ServiceStub(identifier: "shared")))
        Given(ExistentialAnyProtocolMock.self, .makeShared(willReturn: ServiceStub(identifier: "made")))

        XCTAssertEqual(ExistentialAnyProtocolMock.shared.identifier, "shared")
        XCTAssertEqual(ExistentialAnyProtocolMock.makeShared().identifier, "made")
        Verify(ExistentialAnyProtocolMock.self, 1, .makeShared())
    }

    func test_existential_parameters() {
        let mock = ExistentialAnyProtocolMock()
        let first = ServiceStub(identifier: "first")
        let second = ServiceStub(identifier: "second")

        mock.take(first)
        mock.takeOptional(nil)
        mock.takeMany([first, second])
        mock.takeVariadic(first, second)

        Verify(mock, 1, .take(.matching { $0.identifier == "first" }))
        Verify(mock, 0, .take(.matching { $0.identifier == "second" }))
        Verify(mock, 1, .takeOptional(.matching { $0 == nil }))
        Verify(mock, 1, .takeMany(.matching { $0.count == 2 }))
        Verify(mock, 1, .takeVariadic(.matching { $0.map(\.identifier) == ["first", "second"] }))
    }

    func test_inout_existential_parameter() {
        let mock = ExistentialAnyProtocolMock()
        Perform(mock, .takeInout(.any, perform: { service in
            service = ServiceStub(identifier: "replaced")
        }))

        var service: any ExistentialService = ServiceStub(identifier: "original")
        mock.takeInout(&service)

        XCTAssertEqual(service.identifier, "replaced")
        Verify(mock, 1, .takeInout(.matching { $0.identifier == "original" }))
    }

    func test_closures_with_existential_errors() {
        let mock = ExistentialAnyProtocolMock()
        Perform(mock, .takeCompletion(.any, perform: { completion in
            completion(ExistentialError(code: 1))
        }))
        Perform(mock, .takeResult(.any, perform: { completion in
            completion(.failure(ExistentialError(code: 2)))
        }))

        var receivedError: (any Error)?
        mock.takeCompletion { receivedError = $0 }
        var receivedResult: Result<Int, any Error>?
        mock.takeResult { receivedResult = $0 }

        XCTAssertEqual(receivedError as? ExistentialError, ExistentialError(code: 1))
        guard case .failure(let error)? = receivedResult else {
            return XCTFail("Expected failure result")
        }
        XCTAssertEqual(error as? ExistentialError, ExistentialError(code: 2))
    }

    func test_existential_returns_and_throwing() async throws {
        let mock = ExistentialAnyProtocolMock()
        Given(mock, .makeService(willReturn: ServiceStub(identifier: "made")))
        Given(mock, .makeOptionalService(willReturn: nil))
        Given(mock, .makeThrowing(willThrow: ExistentialError(code: 3)))
        Given(mock, .makeAsync(willReturn: ServiceStub(identifier: "async")))
        Given(mock, .convert(.any, willReturn: ExistentialError(code: 4)))

        XCTAssertEqual(mock.makeService().identifier, "made")
        XCTAssertNil(mock.makeOptionalService())
        XCTAssertThrowsError(try mock.makeThrowing()) { error in
            XCTAssertEqual(error as? ExistentialError, ExistentialError(code: 3))
        }
        let sut: any ExistentialAnyProtocol = mock
        let asyncService = try await sut.makeAsync()
        XCTAssertEqual(asyncService.identifier, "async")
        XCTAssertEqual(mock.convert(ExistentialError(code: 0)) as? ExistentialError, ExistentialError(code: 4))
        Verify(mock, 1, .convert(.matching { ($0 as? ExistentialError)?.code == 0 }))
    }

    func test_generic_method_with_existential_parameter() {
        let mock = ExistentialAnyProtocolMock()
        let value = ServiceStub(identifier: "generic")
        Given(mock, .takeGeneric(.any(ServiceStub.self), other: .any, willReturn: value))

        XCTAssertEqual(mock.takeGeneric(value, other: value).identifier, "generic")
        Verify(mock, 1, .takeGeneric(.any(ServiceStub.self), other: .any))
    }

    func test_existential_subscripts() {
        let mock = ExistentialAnyProtocolMock()
        Given(mock, .subscript(index: .value(0), willReturn: ServiceStub(identifier: "zero")))
        Given(mock, .subscript(key: .value("missing"), willReturn: nil))

        XCTAssertEqual(mock[0].identifier, "zero")
        XCTAssertNil(mock["missing"])

        mock[1] = ServiceStub(identifier: "one")
        Verify(mock, 1, .subscript(index: .value(1), set: .matching { $0.identifier == "one" }))
    }
}
