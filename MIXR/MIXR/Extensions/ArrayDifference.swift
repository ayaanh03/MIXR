//
//  ArrayDifference.swift
//  MIXR
//
//  Created by Christopher Haas on 11/12/20.
//

import Foundation

// https://www.hackingwithswift.com/example-code/language/how-to-find-the-difference-between-two-arrays
extension Array where Element: Hashable {
    func difference(from other: [Element]) -> [Element] {
        let thisSet = Set(self)
        let otherSet = Set(other)
        return Array(thisSet.symmetricDifference(otherSet))
    }
}
