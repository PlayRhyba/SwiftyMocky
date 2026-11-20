//
//  ItemsRepositoryMock.swift
//  Mocky
//
//  Created by przemyslaw.wosko on 19/05/2017.
//  Copyright © 2017 MakeAWishFoundation. All rights reserved.
//

import Foundation
import SwiftyMocky
import XCTest
@testable import Mocky_Example_tvOS

// sourcery: mock = "ItemsRepository"
class ItemsRepositoryMock: ItemsRepository, Mock {
// sourcery:inline:auto:ItemsRepositoryMock.autoMocked
    /// [Internal] All mutable mock state. Only reachable through `state`, which is lock-protected.
    private struct MockState {
        var matcher: Matcher = Matcher.default
        var stubbingPolicy: StubbingPolicy = .wrap
        var sequencingPolicy: SequencingPolicy = .lastWrittenResolvedFirst
        var invocations: [MethodType] = []
        var methodReturnValues: [Given] = []
        var methodPerformValues: [Perform] = []
        var file: StaticString?
        var line: UInt?
    }
    private let state = LockedValue(MockState())

    var matcher: Matcher {
        get { state.withValue { $0.matcher } }
        set { state.withValue { $0.matcher = newValue } }
    }
    var stubbingPolicy: StubbingPolicy {
        get { state.withValue { $0.stubbingPolicy } }
        set { state.withValue { $0.stubbingPolicy = newValue } }
    }
    var sequencingPolicy: SequencingPolicy {
        get { state.withValue { $0.sequencingPolicy } }
        set { state.withValue { $0.sequencingPolicy = newValue } }
    }

    public typealias PropertyStub = Given
    public typealias MethodStub = Given
    public typealias SubscriptStub = Given

    /// Convenience method - call setupMock() to extend debug information when failure occurs
    public func setupMock(file: StaticString = #filePath, line: UInt = #line) {
        state.withValue { state in
            state.file = file
            state.line = line
        }
    }

    /// Clear mock internals. You can specify what to reset (invocations aka verify, givens or performs) or leave it empty to clear all mock internals
    public func resetMock(_ scopes: MockScope...) {
        let scopes: [MockScope] = scopes.isEmpty ? [.invocation, .given, .perform] : scopes
        state.withValue { state in
            if scopes.contains(.invocation) { state.invocations = [] }
            if scopes.contains(.given) { state.methodReturnValues = [] }
            if scopes.contains(.perform) { state.methodPerformValues = [] }
        }
    }






    open func storeItems(items: [Item]) {
        addInvocation(.m_storeItems__items_items(Parameter<[Item]>.value(`items`)))
		let perform = methodPerformValue(.m_storeItems__items_items(Parameter<[Item]>.value(`items`))) as? ([Item]) -> Void
		perform?(`items`)
    }

    open func storeDetails(details: ItemDetails) {
        addInvocation(.m_storeDetails__details_details(Parameter<ItemDetails>.value(`details`)))
		let perform = methodPerformValue(.m_storeDetails__details_details(Parameter<ItemDetails>.value(`details`))) as? (ItemDetails) -> Void
		perform?(`details`)
    }

    open func storedItems() -> [Item]? {
        addInvocation(.m_storedItems)
		let perform = methodPerformValue(.m_storedItems) as? () -> Void
		perform?()
		var __value: [Item]? = nil
		do {
		    __value = try methodReturnValue(.m_storedItems).casted()
		} catch {
			// do nothing
		}
		return __value
    }

    open func storedDetails(item: Item) -> ItemDetails? {
        addInvocation(.m_storedDetails__item_item(Parameter<Item>.value(`item`)))
		let perform = methodPerformValue(.m_storedDetails__item_item(Parameter<Item>.value(`item`))) as? (Item) -> Void
		perform?(`item`)
		var __value: ItemDetails? = nil
		do {
		    __value = try methodReturnValue(.m_storedDetails__item_item(Parameter<Item>.value(`item`))).casted()
		} catch {
			// do nothing
		}
		return __value
    }


    fileprivate enum MethodType {
        case m_storeItems__items_items(Parameter<[Item]>)
        case m_storeDetails__details_details(Parameter<ItemDetails>)
        case m_storedItems
        case m_storedDetails__item_item(Parameter<Item>)

        static func compareParameters(lhs: MethodType, rhs: MethodType, matcher: Matcher) -> Matcher.ComparisonResult {
            switch (lhs, rhs) {
            case (.m_storeItems__items_items(let lhsItems), .m_storeItems__items_items(let rhsItems)):
				var results: [Matcher.ParameterComparisonResult] = []
				results.append(Matcher.ParameterComparisonResult(Parameter.compare(lhs: lhsItems, rhs: rhsItems, with: matcher), lhsItems, rhsItems, "items"))
				return Matcher.ComparisonResult(results)

            case (.m_storeDetails__details_details(let lhsDetails), .m_storeDetails__details_details(let rhsDetails)):
				var results: [Matcher.ParameterComparisonResult] = []
				results.append(Matcher.ParameterComparisonResult(Parameter.compare(lhs: lhsDetails, rhs: rhsDetails, with: matcher), lhsDetails, rhsDetails, "details"))
				return Matcher.ComparisonResult(results)

            case (.m_storedItems, .m_storedItems): return .match

            case (.m_storedDetails__item_item(let lhsItem), .m_storedDetails__item_item(let rhsItem)):
				var results: [Matcher.ParameterComparisonResult] = []
				results.append(Matcher.ParameterComparisonResult(Parameter.compare(lhs: lhsItem, rhs: rhsItem, with: matcher), lhsItem, rhsItem, "item"))
				return Matcher.ComparisonResult(results)
            default: return .none
            }
        }

        func intValue() -> Int {
            switch self {
            case let .m_storeItems__items_items(p0): return p0.intValue
            case let .m_storeDetails__details_details(p0): return p0.intValue
            case .m_storedItems: return 0
            case let .m_storedDetails__item_item(p0): return p0.intValue
            }
        }
        func assertionName() -> String {
            switch self {
            case .m_storeItems__items_items: return ".storeItems(items:)"
            case .m_storeDetails__details_details: return ".storeDetails(details:)"
            case .m_storedItems: return ".storedItems()"
            case .m_storedDetails__item_item: return ".storedDetails(item:)"
            }
        }
    }

    open class Given: StubbedMethod {
        fileprivate var method: MethodType

        private init(method: MethodType, products: [StubProduct]) {
            self.method = method
            super.init(products)
        }


        public static func storedItems(willReturn: [Item]?...) -> MethodStub {
            return Given(method: .m_storedItems, products: willReturn.map({ StubProduct.return($0 as Any) }))
        }
        public static func storedDetails(item: Parameter<Item>, willReturn: ItemDetails?...) -> MethodStub {
            return Given(method: .m_storedDetails__item_item(`item`), products: willReturn.map({ StubProduct.return($0 as Any) }))
        }
        public static func storedItems(willProduce: (Stubber<[Item]?>) -> Void) -> MethodStub {
            let willReturn: [[Item]?] = []
			let given: Given = { return Given(method: .m_storedItems, products: willReturn.map({ StubProduct.return($0 as Any) })) }()
			let stubber = given.stub(for: ([Item]?).self)
			willProduce(stubber)
			return given
        }
        public static func storedDetails(item: Parameter<Item>, willProduce: (Stubber<ItemDetails?>) -> Void) -> MethodStub {
            let willReturn: [ItemDetails?] = []
			let given: Given = { return Given(method: .m_storedDetails__item_item(`item`), products: willReturn.map({ StubProduct.return($0 as Any) })) }()
			let stubber = given.stub(for: (ItemDetails?).self)
			willProduce(stubber)
			return given
        }
    }

    public struct Verify {
        fileprivate var method: MethodType

        public static func storeItems(items: Parameter<[Item]>) -> Verify { return Verify(method: .m_storeItems__items_items(`items`))}
        public static func storeDetails(details: Parameter<ItemDetails>) -> Verify { return Verify(method: .m_storeDetails__details_details(`details`))}
        public static func storedItems() -> Verify { return Verify(method: .m_storedItems)}
        public static func storedDetails(item: Parameter<Item>) -> Verify { return Verify(method: .m_storedDetails__item_item(`item`))}
    }

    public struct Perform {
        fileprivate var method: MethodType
        var performs: Any

        public static func storeItems(items: Parameter<[Item]>, perform: @escaping ([Item]) -> Void) -> Perform {
            return Perform(method: .m_storeItems__items_items(`items`), performs: perform)
        }
        public static func storeDetails(details: Parameter<ItemDetails>, perform: @escaping (ItemDetails) -> Void) -> Perform {
            return Perform(method: .m_storeDetails__details_details(`details`), performs: perform)
        }
        public static func storedItems(perform: @escaping () -> Void) -> Perform {
            return Perform(method: .m_storedItems, performs: perform)
        }
        public static func storedDetails(item: Parameter<Item>, perform: @escaping (Item) -> Void) -> Perform {
            return Perform(method: .m_storedDetails__item_item(`item`), performs: perform)
        }
    }

    public func given(_ method: Given) {
        state.withValue { $0.methodReturnValues.append(method) }
    }

    public func perform(_ method: Perform) {
        state.withValue { state in
            state.methodPerformValues.append(method)
            state.methodPerformValues.sort { $0.method.intValue() < $1.method.intValue() }
        }
    }

    public func verify(_ method: Verify, count: Count = Count.moreOrEqual(to: 1), file: StaticString = #filePath, line: UInt = #line) {
        let fullMatches = matchingCalls(method, file: file, line: line)
        let success = count.matches(fullMatches)
        let assertionName = method.method.assertionName()
        let feedback: String = {
            guard !success else { return "" }
            let (invocations, matcher) = state.withValue { ($0.invocations, $0.matcher) }
            return Utils.closestCallsMessage(
                for: invocations.map { invocation in
                    matcher.set(file: file, line: line)
                    defer { matcher.clearFileAndLine() }
                    return MethodType.compareParameters(lhs: invocation, rhs: method.method, matcher: matcher)
                },
                name: assertionName
            )
        }()
        MockyAssert(success, "Expected: \(count) invocations of `\(assertionName)`, but was: \(fullMatches).\(feedback)", file: file, line: line)
    }

    private func addInvocation(_ call: MethodType) {
        state.withValue { $0.invocations.append(call) }
    }
    /// Parameters are matched outside the lock (matchers may run user closures);
    /// the matching stub is then picked and advanced under it.
    private func methodReturnValue(_ method: MethodType) throws -> StubProduct {
        let (candidates, matcher, stubbingPolicy, file, line) = state.withValue { state in
            (state.sequencingPolicy.sorted(state.methodReturnValues, by: { $0.method.intValue() > $1.method.intValue() }).filter { $0.isValid }, state.matcher, state.stubbingPolicy, state.file, state.line)
        }
        matcher.set(file: file, line: line)
        defer { matcher.clearFileAndLine() }
        for candidate in candidates where MethodType.compareParameters(lhs: candidate.method, rhs: method, matcher: matcher).isFullMatch {
            let product = state.withValue { _ in candidate.isValid ? candidate.getProduct(policy: stubbingPolicy) : nil }
            if let product { return product }
        }
        throw MockError.notStubed
    }
    private func methodPerformValue(_ method: MethodType) -> Any? {
        let (performs, matcher, file, line) = state.withValue { ($0.methodPerformValues, $0.matcher, $0.file, $0.line) }
        matcher.set(file: file, line: line)
        defer { matcher.clearFileAndLine() }
        return performs.reversed().first { MethodType.compareParameters(lhs: $0.method, rhs: method, matcher: matcher).isFullMatch }?.performs
    }
    private func matchingCalls(_ method: MethodType, file: StaticString?, line: UInt?) -> [MethodType] {
        let (invocations, matcher, mockFile, mockLine) = state.withValue { ($0.invocations, $0.matcher, $0.file, $0.line) }
        matcher.set(file: file ?? mockFile, line: line ?? mockLine)
        defer { matcher.clearFileAndLine() }
        return invocations.filter { MethodType.compareParameters(lhs: $0, rhs: method, matcher: matcher).isFullMatch }
    }
    private func matchingCalls(_ method: Verify, file: StaticString?, line: UInt?) -> Int {
        return matchingCalls(method.method, file: file, line: line).count
    }
    private func givenGetterValue<Value>(_ method: MethodType, _ message: String) -> Value {
        do {
            return try methodReturnValue(method).casted()
        } catch {
            onFatalFailure(message)
            Failure(message)
        }
    }
    private func optionalGivenGetterValue<Value>(_ method: MethodType, _ message: String) -> Value? {
        do {
            return try methodReturnValue(method).casted()
        } catch {
            return nil
        }
    }
    private func onFatalFailure(_ message: String) {
        let (file, line) = state.withValue { ($0.file, $0.line) }
        guard let file, let line else { return } // Let if fail if cannot handle gratefully
        SwiftyMockyTestObserver.handleFatalError(message: message, file: file, line: line)
    }
    
// sourcery:end
}
