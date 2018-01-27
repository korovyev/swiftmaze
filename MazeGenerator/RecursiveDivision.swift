//
//  RecursiveDivision.swift
//  swiftmaze
//
//  Created by Kevin Sweeney on 08/09/2016.
//  Copyright © 2016 Kevin Sweeney. All rights reserved.
//

import Foundation

class RecursiveDivision: Algorithm {
    
    private struct State: AlgorithmState {
        let rectangle: Rectangle
    }
    
    func begin(in grid: Grid) -> [AlgorithmState] {
        grid.buildFrame()
        return [State(rectangle: Rectangle(origin: .zero, size: grid.size))]
    }
    
    func step(state: AlgorithmState, in grid: Grid) -> [AlgorithmState] {
        guard let state = state as? RecursiveDivision.State else {
            return []
        }
        return addLine(to: state.rectangle, in: grid)
    }
    
    private func addLine(to rectangle: Rectangle, in grid: Grid) -> [AlgorithmState] {
        var begin: Point?
        var end: Point?
        
        var newState = [State]()
        
        if rectangle.size.width < rectangle.size.height {
            // split rectangle into two horizontally
            
            let yVal = Int(arc4random_uniform(UInt32(rectangle.size.height - 1))) + 1
            
            begin = Point(rectangle.origin.x, rectangle.origin.y + yVal)
            end = Point(rectangle.origin.x + rectangle.size.width, rectangle.origin.y + yVal)
            
            let topRect = Rectangle(origin: rectangle.origin, size: Size(width: rectangle.size.width, height: yVal))
            let bottomRect = Rectangle(origin: Point(rectangle.origin.x, rectangle.origin.y + yVal), size: Size(width: rectangle.size.width, height: rectangle.size.height - yVal))
            
            if topRect.size.height > 1 {
                newState.append(State(rectangle: topRect))
            }
            
            if bottomRect.size.height > 1 {
                newState.append(State(rectangle: bottomRect))
            }
        }
        else if rectangle.size.width > 1 {
            // split rectangle into two vertically
            
            let xVal = Int(arc4random_uniform(UInt32(rectangle.size.width - 1))) + 1
            
            begin = Point(rectangle.origin.x + xVal, rectangle.origin.y)
            end = Point(rectangle.origin.x + xVal, rectangle.origin.y + rectangle.size.height)
            
            let leftRect = Rectangle(origin: rectangle.origin, size: Size(width: xVal, height: rectangle.size.height))
            let rightRect = Rectangle(origin: Point(rectangle.origin.x + xVal, rectangle.origin.y), size: Size(width: rectangle.size.width - xVal, height: rectangle.size.height))
            
            if leftRect.size.width > 1 {
                newState.append(State(rectangle: leftRect))
            }
            
            if rightRect.size.width > 1 {
                newState.append(State(rectangle: rightRect))
            }
        }
        
        if let begin = begin, let end = end {
            grid.drawGridLineWithDoor(line: Line(start: begin, end: end))
        }
        
        return newState
    }
}
