//
//  Geometry.swift
//  swiftmaze
//
//  Created by Kevin Sweeney on 10/10/2015.
//  Copyright © 2015 Kevin Sweeney. All rights reserved.
//

import Foundation

struct Cell {
    var xPos : Int
    var yPos : Int
    var visited : Bool
    var filled : Bool
    
    init(x: Int, y: Int) {
        self.visited = false
        self.filled = false
        
        self.xPos = x
        self.yPos = y
    }
}

enum Direction: Int {
    case Left
    case Up
    case Right
    case Down
    
    init(num: Int) {
        
        switch num {
        case 0:
            self = .Left
        case 1:
            self = .Up
        case 2:
            self = .Right
        case 3:
            self = .Down
        default:
            self = .Down
        }
    }
}

struct Point {
    var x : Int
    var y : Int
}

struct Size {
    var width : Int
    var height : Int
}

struct Line {
    var start : Point
    var end : Point
    
    func key() -> String {
        return "start\(start.x)_\(start.y)end\(end.x)_\(end.y)"
    }
    
    func vertical() -> Bool {
        return self.start.y == self.end.y
    }
}

struct Rectangle {
    var origin : Point
    var size : Size
}

func == (lhs: Point, rhs: Point) -> Bool {
    return lhs.x == rhs.x && lhs.y == rhs.y
}

func ==(lhs: Line, rhs: Line) -> Bool {
    return rhs.start == lhs.start
}