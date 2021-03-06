//
//  Geometry.swift
//  swiftmaze
//
//  Created by Kevin Sweeney on 10/10/2015.
//  Copyright © 2015 Kevin Sweeney. All rights reserved.
//

import Foundation

class Cell: Equatable, Hashable {
    var xPos : Int
    var yPos : Int
    var visited : Bool
    var filled : Bool
    var parent : Cell?
    var solverVisited : Bool
    var direction: Direction = .none
    var fScore : Int
    
    init(x: Int, y: Int) {
        visited = false
        filled = false
        solverVisited = false
        
        fScore = 0
        
        xPos = x
        yPos = y
    }
    
    func directionsToTest(inside gridSize: Size) -> [Direction] {
        
        var directions = [Direction]()
        
        if xPos > 0                     { directions.append(.left) }
        if xPos < gridSize.width - 1    { directions.append(.right) }
        if yPos > 0                     { directions.append(.down) }
        if yPos < gridSize.height - 1   { directions.append(.up) }
        
        return directions
    }
    
    var hashValue: Int {
        return "\(xPos)\(yPos)".hashValue
    }
}

enum Direction {
    case left
    case up
    case right
    case down
    case none
    
    func opposite() -> Direction {
        switch self {
        case .up: return .down
        case .down: return .up
        case .left: return .right
        case .right: return .left
        case .none: return .none
        }
    }
}

struct Point {
    var x : Int
    var y : Int
    
    static var zero: Point {
        return Point(0, 0)
    }
    
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
    
    init(start: Point, end: Point) {
        self.start = start
        self.end = end
    }
    
    func key() -> String {
        return "start\(start.x)_\(start.y)end\(end.x)_\(end.y)"
    }
    
    func vertical() -> Bool {
        return start.x == end.x
    }
}

struct Rectangle {
    var origin : Point
    var size : Size
}

class Tree<T: Equatable> {
    var parent: Tree?
    var element: T
    
    init(element: T, parent: Tree? = nil) {
        self.element = element
        self.parent = parent
    }
    
    func root() -> Tree {
        if let parent = parent {
            return parent.root()
        }
        else {
            return self
        }
    }
    
    func connect(to tree: Tree) {
        tree.root().parent = self
    }
    
    func connected(to tree: Tree) -> Bool {
        return root().element == tree.root().element
    }
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
