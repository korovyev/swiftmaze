//
//  Extensions.swift
//  swiftmaze
//
//  Created by Kevin Sweeney on 25/10/2015.
//  Copyright © 2015 Kevin Sweeney. All rights reserved.
//

// shuffle taken from : http://stackoverflow.com/questions/24026510/how-do-i-shuffle-an-array-in-swift

import Foundation

extension Collection {
    /// Return a copy of `self` with its elements shuffled
    func shuffle() -> [Generator.Element] {
        var list = Array(self)
        list.shuffled()
        return list
    } }

extension MutableCollection where Index == Int {
    /// Shuffle the elements of `self` in-place.
    mutating func shuffled() {
        // empty and single-element collections don't shuffle
        if count < 2 { return }
        let countInt = count as! Int
        
        for i in 0..<countInt - 1 {
            let j = Int(arc4random_uniform(UInt32(countInt - i))) + i
            guard i != j else { continue }
            swap(&self[i], &self[j])
        }
    }
}
