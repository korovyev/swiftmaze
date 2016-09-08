//
//  Grid.swift
//  swiftmaze
//
//  Created by Kevin Sweeney on 08/09/2016.
//  Copyright © 2016 Kevin Sweeney. All rights reserved.
//

import Foundation

class Grid {
    var verticalLines = [Line]()
    var horizontalLines = [Line]()
    var size: Size
    
    init(size: Size) {
        self.size = size
    }
    
    func buildFrame() {
        for x in 0..<size.width {
            
            let topLine = Line(start: Point(x, 0), end: Point(x + 1, 0))
            
            horizontalLines.append(topLine)
            
            let bottomLine = Line(start: Point(x, size.height), end: Point(x + 1, size.height))
            
            horizontalLines.append(bottomLine)
        }
        
        for y in 0..<size.height {
            
            let leftLine = Line(start: Point(0, y), end: Point(0, y + 1))
            
            verticalLines.append(leftLine)
            
            let rightLine = Line(start: Point(size.width, y), end: Point(size.width, y + 1))
            
            verticalLines.append(rightLine)
        }
    }
    
    func buildInternalGrid() {
        for x in 1..<size.width {
            for y in 0..<size.height {
                verticalLines.append(Line(start: Point(x, y), end: Point(x, y + 1)))
            }
        }
        
        for y in 1..<size.height {
            for x in 0..<size.width {
                horizontalLines.append(Line(start: Point(x, y), end: Point(x + 1, y)))
            }
        }
    }
    
    func drawGridLineWithDoor(line : Line) {
        
        let numSegments = line.vertical() ? line.end.x - line.start.x : line.end.y - line.start.y
        
        let indexOfSegmentNotToDraw = Int(arc4random_uniform(UInt32(numSegments)))
        
        if !line.vertical() {
            
            for index in line.start.y..<line.end.y where index != line.start.y + indexOfSegmentNotToDraw {
                let newLine = Line(start: Point(line.start.x, index), end: Point(line.start.x, index + 1))
                
                verticalLines.append(newLine)
            }
        }
        else {
            
            for index in line.start.x..<line.end.x where index != line.start.x + indexOfSegmentNotToDraw {
                let newLine = Line(start: Point(index, line.start.y), end: Point(index + 1, line.start.y))
                
                horizontalLines.append(newLine)
            }
        }
    }
}
