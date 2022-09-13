//
//  BaseTestCaseInterface.swift
//  
//
//  Created by Aytuğ Sevgi on 13.09.2022.
//

/// Must conform to test classes.
public protocol BaseTestCaseInterface {
    var mocks: [BaseMockAssertable] { get }
}

public extension BaseTestCaseInterface {
    /// Used to empty the invokedList array of mocks.
    func tearDownMocks() {
        mocks.forEach { $0.tearDown() }
    }

    /// Checks all mocks. It makes sure nothing is called.
    /// - Parameters:
    ///   - excepts: It is used to disable the mock that something is invoked.
    func invokedNothing(excepts: [BaseMockAssertable] = [], _ message: (String) -> String = { $0 }, file: StaticString = #filePath, line: UInt = #line) {
        mocks
            .filter{ mock in !excepts.contains{ type(of: mock) == type(of: $0) } }
            .forEach{ $0.assertInvokes(message, file: file, line: line) }
    }
}
