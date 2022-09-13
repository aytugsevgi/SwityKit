//
//  MockEquatable.swift
//  
//
//  Created by Aytuğ Sevgi on 13.09.2022.
//

/// It must be conformable to the enum used by mock classes.
public protocol MockEquatable: Equatable {}

public extension MockEquatable {
    var value: String {
        String(describing: self)
    }

    static func ==(lhs: Self, rhs: Self) -> Bool {
        lhs.value == rhs.value
    }
}
