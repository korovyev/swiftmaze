//
//  RecursiveDivision.swift
//  swiftmaze
//
//  Created by Kevin Sweeney on 08/09/2016.
//  Copyright © 2016 Kevin Sweeney. All rights reserved.
//

import Foundation

class RecursiveDivision: Generator {
    var updateInterval: Float
    var state: GeneratorState
    var rectangles = [Rectangle]()
    
    init(updateInterval: Float) {
        self.updateInterval = updateInterval
        state = .generating
    }
    
    func generateMaze(in grid: Grid, step: @escaping () -> Void) {
        grid.buildFrame()
        
        step()
        
        let rectangle = Rectangle(origin: Point(0, 0), size: grid.size)
        
        addLine(to: grid, in: rectangle, step: step)
    }
    
    func addLine(to grid: Grid, in rectangle: Rectangle, step: @escaping () -> Void) {
        var begin: Point?
        var end: Point?
        
        if rectangle.size.width < rectangle.size.height && rectangle.size.height > 1 {
            // split rectangle into two horizontally
            
            let yVal = Int(arc4random_uniform(UInt32(rectangle.size.height - 1))) + 1
            
            begin = Point(rectangle.origin.x, rectangle.origin.y + yVal)
            end = Point(rectangle.origin.x + rectangle.size.width, rectangle.origin.y + yVal)
            
            let topRect = Rectangle(origin: rectangle.origin, size: Size(width: rectangle.size.width, height: yVal))
            let bottomRect = Rectangle(origin: Point(rectangle.origin.x, rectangle.origin.y + yVal), size: Size(width: rectangle.size.width, height: rectangle.size.height - yVal))
            
            if topRect.size.height > 1 {
                rectangles.append(topRect)
            }
            
            if bottomRect.size.height > 1 {
                rectangles.append(bottomRect)
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
                rectangles.append(leftRect)
            }
            
            if rightRect.size.width > 1 {
                rectangles.append(rightRect)
            }
        }
        
        if let begin = begin, let end = end {
            grid.drawGridLineWithDoor(line: Line(start: begin, end: end))
        }
        
        step()
        
        if let nextRectangle = rectangles.popLast() {
            delay(step: {
                self.addLine(to: grid, in: nextRectangle, step: step)
            })
        }
        else {
            state = .finished
            step()
        }
    }
}
