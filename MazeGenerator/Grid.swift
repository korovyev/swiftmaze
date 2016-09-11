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
    var cells: [[Cell]]?
    var size: Size
    let directions: [Direction] = [.left, .up, .right, .down]
    
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
        
        let numSegments = line.vertical() ? line.end.y - line.start.y : line.end.x - line.start.x
        
        let indexOfSegmentNotToDraw = Int(arc4random_uniform(UInt32(numSegments)))
        
        if line.vertical() {
            
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
    
    func buildCells() {
        
        cells = [[Cell]]()
        
        for x in 0..<size.width {
            
            var verticalCellArray = [Cell]()
            
            for y in 0..<size.height {
                let cell = Cell(x: x, y: y)
                
                verticalCellArray.append(cell)
            }
            
            if verticalCellArray.count > 0 {
                cells!.append(verticalCellArray)
            }
        }
    }
    
    func removeLineBetween(_ cell: Cell, and otherCell: Cell) {
        let vertical = cell.yPos == otherCell.yPos
        
        if vertical {
            let yPos = cell.yPos
            
            let xPos = cell.xPos > otherCell.xPos ? cell.xPos : otherCell.xPos
            
            let start = Point(xPos, yPos)
            let end = Point(xPos, yPos + 1)
            let lineToFind = Line(start :start, end: end)
            
            if let indexOfLineToFind = verticalLines.index(where: { $0 == lineToFind }) {
                
                verticalLines.remove(at: indexOfLineToFind)
            }
        }
        else {
            let xPos = cell.xPos;
            
            let yPos = cell.yPos > otherCell.yPos ? cell.yPos : otherCell.yPos
            
            let start = Point(xPos, yPos)
            let end = Point(xPos + 1, yPos)
            let lineToFind = Line(start :start, end: end)
            
            if let indexOfLineToFind = horizontalLines.index(where: { $0 == lineToFind }) {
                
                horizontalLines.remove(at: indexOfLineToFind)
            }
        }

    }
    
    func neighbourCell(of cell: Cell, in direction: Direction) -> Cell? {
        guard let _ = cells else {
            return nil
        }
        
        switch direction {
        case .left:     return cellToTheLeft(of: cell)
        case .right:    return cellToTheRight(of: cell)
        case .up:       return cellAbove(cell)
        case .down:     return cellBelow(cell)
        }
    }
    
    func cellToTheLeft(of cell : Cell) -> Cell? {
        if cell.xPos == 0 || (cells?.count)! < cell.xPos - 1 {
            return nil
        }
        
        let row = cell.yPos
        let col = cell.xPos
        if let cellColumn = cells?[col - 1] {
            return cellColumn[row]
        }
        
        return nil
    }
    
    func cellToTheRight(of cell : Cell) -> Cell? {
        if cell.xPos == size.width || cell.xPos + 1 >= (cells?.count)! {
            return nil
        }
        let row = cell.yPos
        let col = cell.xPos
        
        if let cellColumn = cells?[col + 1] {
            return cellColumn[row]
        }
        
        return nil
    }
    
    func cellAbove(_ cell : Cell) -> Cell? {
        if cell.yPos == size.height {
            return nil
        }
        
        if let cellColumn = cells?[cell.xPos], cellColumn.count > cell.yPos + 1 {
            return cellColumn[cell.yPos + 1]
        }
        
        return nil
    }
    
    func cellBelow(_ cell : Cell) -> Cell? {
        if cell.yPos == 0 {
            return nil
        }
        
        if let cellColumn = cells?[cell.xPos], cell.yPos > 0 {
            return cellColumn[cell.yPos - 1]
        }
        
        return nil
    }
    
    func cellsEitherSide(of line: Line) -> (Cell?, Cell?) {
        
        guard let cells = cells else {
            return (nil, nil)
        }
        
        if line.vertical() {
            
            var leftCell: Cell?
            var rightCell: Cell?
            let yVal = line.end.y > line.start.y ? line.start.y : line.end.y
            
            if line.start.x > 0 {
                leftCell = cells[line.start.x - 1][yVal]
            }
            if line.start.x < cells.count {
                rightCell = cells[line.start.x][yVal]
            }
            
            return (leftCell, rightCell)
        }
        else {
            
            var topCell: Cell?
            var bottomCell: Cell?
            let xVal = line.end.x > line.start.x ? line.start.x : line.end.x
            
            if line.start.y > 0 {
                bottomCell = cells[xVal][line.start.y - 1]
            }
            if line.start.y < cells[xVal].count  {
                topCell = cells[xVal][line.start.y]
            }
            
            return (bottomCell, topCell)
        }
    }
}
