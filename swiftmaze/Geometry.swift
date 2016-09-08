//
//  Geometry.swift
//  swiftmaze
//
//  Created by Kevin Sweeney on 10/10/2015.
//  Copyright © 2015 Kevin Sweeney. All rights reserved.
//

import Foundation

struct Cell: Equatable {
    var xPos : Int
    var yPos : Int
    var visited : Bool
    var filled : Bool
    var parentX : Int
    var parentY : Int
    var tremauxVisited : Bool
    
    var fScore : Int
    
    init(x: Int, y: Int) {
        visited = false
        filled = false
        tremauxVisited = false
        parentX = 0
        parentY = 0
        
        fScore = 0
        
        xPos = x
        yPos = y
    }
}

enum Direction: Int {
    case left
    case up
    case right
    case down
    
    init(num: Int) {
        
        switch num {
        case 0:
            self = .left
        case 1:
            self = .up
        case 2:
            self = .right
        case 3:
            self = .down
        default:
            self = .down
        }
    }
}

struct Point {
    var x : Int
    var y : Int
    
    init(_ x: Int, _ y: Int) {
        self.x = x
        self.y = y
    }
}

struct Size {
    var width : Int
    var height : Int
}

struct Line {
    var start : Point
    var end : Point
    var ghost : Bool = false
    
    init(start: Point, end: Point) {
        self.start = start
        self.end = end
    }
    
    func key() -> String {
        return "start\(start.x)_\(start.y)end\(end.x)_\(end.y)"
    }
    
    func vertical() -> Bool {
        return start.y == end.y
    }
}

struct Rectangle {
    var origin : Point
    var size : Size
}

func == (lhs: Point, rhs: Point) -> Bool {
    return lhs.x == rhs.x && lhs.y == rhs.y
}

func == (lhs: Cell, rhs: Cell) -> Bool {
    return lhs.xPos == rhs.xPos && lhs.yPos == rhs.yPos
}

func ==(lhs: Line, rhs: Line) -> Bool {
    return rhs.start == lhs.start
}
