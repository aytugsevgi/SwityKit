//
//  BaseMockAssertable.swift
//  
//
//  Created by Aytuğ Sevgi on 13.09.2022.
//

public protocol BaseMockAssertable: AnyObject {
    func tearDown()
    func assertions(name: String)
    func assertInvokes(_ message: (String) -> String,
                       file: StaticString,
                       line: UInt)
}
