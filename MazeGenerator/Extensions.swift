//
//  Extensions.swift
//  swiftmaze
//
//  Created by Kevin Sweeney on 25/10/2015.
//  Copyright © 2015 Kevin Sweeney. All rights reserved.
//

// shuffle taken from : http://stackoverflow.com/questions/24026510/how-do-i-shuffle-an-array-in-swift

import Cocoa

extension Collection {
    /// Return a copy of `self` with its elements shuffled
    func shuffle() -> [Iterator.Element] {
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
            self.swapAt(i, j)
        }
    }
}

// taken from http://stackoverflow.com/questions/1275662/saving-uicolor-to-and-loading-from-nsuserdefaults

extension UserDefaults {
    
    func color(forKey key: String) -> NSColor? {
        var color: NSColor?
        if let colorData = data(forKey: key) {
            color = NSKeyedUnarchiver.unarchiveObject(with: colorData) as? NSColor
        }
        return color
    }
    
    func set(color: NSColor?, forKey key: String) {
        var colorData: NSData?
        if let color = color {
            colorData = NSKeyedArchiver.archivedData(withRootObject: color) as NSData?
        }
        set(colorData, forKey: key)
    }
    
}
