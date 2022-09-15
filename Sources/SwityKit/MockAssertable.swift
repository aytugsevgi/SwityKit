//
//  MockAssertable.swift
//  
//
//  Created by Aytuğ Sevgi on 13.09.2022.
//

import XCTest

fileprivate enum AssertionError {
    case remove
    case add
    case notEqualAndDistinct
    case order

    func message(invokes: String) -> String {
        switch self {
        case .remove:
            return "\n\tRemove - \(invokes) is not invoked."
        case .add:
            return "\n\tAdd - \(invokes) is invoked."
        case .notEqualAndDistinct:
            return " Expected;\n\t\(invokes)"
        case .order:
            return "Order of invokes not expected.\n"
        }
    }
}

/// Must conform to mock classes.
public protocol MockAssertable: BaseMockAssertable {
    associatedtype MockIdentifier: MockEquatable

    var invokedList: [MockIdentifier] { get set }
}

extension MockAssertable {
    private func isGivenAndExpectedInvokesNotEqual(_ givenInvokes: [MockIdentifier]) -> Bool {
        givenInvokes != invokedList
    }

    private func isSortedGivenAndExpectedInvokesEqual(_ givenInvokes: [MockIdentifier]) -> Bool {
        givenInvokes.sorted(by: { $0.value > $1.value }) == invokedList.sorted(by: { $0.value > $1.value })
    }


    private func hasDistinctInvokes(_ givenInvokes: [MockIdentifier]) -> Bool {
        Set(invokedList.map(\.value)).count == invokedList.count && Set(givenInvokes.map(\.value)).count == givenInvokes.count
    }

    /// It tests to what is being called from the mock.
    /// - Parameters:
    ///   - givenInvokes: Expected to be invokes
    public func assertInvokes(_ givenInvokes: [MockIdentifier],
                              _ message: (String) -> String = { $0 },
                              file: StaticString = #filePath, line: UInt = #line) {
        if isGivenAndExpectedInvokesNotEqual(givenInvokes) {
            guard hasDistinctInvokes(givenInvokes) else {
                XCTFail(message(AssertionError.notEqualAndDistinct.message(invokes: invokedList.map(\.value).joined(separator: ",\n\t"))),
                        file: file,
                        line: line)
                return
            }

            if isSortedGivenAndExpectedInvokesEqual(givenInvokes) {
                XCTFail(message(AssertionError.order.message(invokes: "") + AssertionError.notEqualAndDistinct.message(invokes: invokedList.map(\.value).joined(separator: ",\n\t"))),
                        file: file,
                        line: line)
                return
            }

            let removeMessage = givenInvokes.compactMap { !invokedList.contains($0) ? AssertionError.remove.message(invokes: $0.value) : nil }.joined()
            let addMessage = invokedList.compactMap { !givenInvokes.contains($0) ? AssertionError.add.message(invokes: $0.value) : nil }.joined()

            XCTFail(message(removeMessage + addMessage), file: file, line: line)
        }
    }

    /// It tests that nothing is called from the mock.
    public func assertInvokes(_ message: (String) -> String = { $0 },
                              file: StaticString = #filePath,
                              line: UInt = #line) {
        if !invokedList.isEmpty {
            let addMessage = invokedList.compactMap { AssertionError.add.message(invokes: $0.value) }.joined()
            XCTFail(message(addMessage), file: file, line: line)
        }
    }

    /// Generates what is invoked from the mock.
    /// - Parameter name: Mock variable should be given the same name.
    public func assertions(name: String) {
        var assertions = [String]()
        guard !invokedList.isEmpty else {
            print("\t\(name).assertInvokes()")
            return
        }
        assertions.append("\t\(name).assertInvokes([\(invokedList.map { "." + $0.value}.joined(separator: ",\n\t\t\t\t\t\(String(repeating: " ", count: name.count))"))])")
        print(assertions.joined())
    }

    /// Empties the invokedList array of a given mock.
    public func tearDown() {
        invokedList.removeAll()
    }
}
