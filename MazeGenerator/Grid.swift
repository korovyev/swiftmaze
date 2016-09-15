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
    var cells = [[Cell]]()
    var size: Size
    let directions: [Direction] = [.left, .up, .right, .down]
    var highlightCells: [Cell]?
    var highlightCell: Cell?
    var target: Cell?
    var activeSolveCells: [Cell]?
    
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
                cells.append(verticalCellArray)
            }
        }
    }
    
    func cellAt(_ x: Int, _ y: Int) -> Cell? {
        if (x >= 0 && x < cells.count) {
            if y >= 0 && y < cells[x].count {
                return cells[x][y]
            }
        }
        
        return nil
    }
    
    func indexOfLineBetween(_ cell: Cell, and otherCell: Cell) -> Int? {
        let vertical = cell.yPos == otherCell.yPos
        
        if vertical {
            let yPos = cell.yPos
            
            let xPos = cell.xPos > otherCell.xPos ? cell.xPos : otherCell.xPos
            
            let start = Point(xPos, yPos)
            let end = Point(xPos, yPos + 1)
            let lineToFind = Line(start :start, end: end)
            
            if let indexOfLineToFind = verticalLines.index(where: { $0 == lineToFind }) {
                
                return indexOfLineToFind
            }
        }
        else {
            let xPos = cell.xPos;
            
            let yPos = cell.yPos > otherCell.yPos ? cell.yPos : otherCell.yPos
            
            let start = Point(xPos, yPos)
            let end = Point(xPos + 1, yPos)
            let lineToFind = Line(start :start, end: end)
            
            if let indexOfLineToFind = horizontalLines.index(where: { $0 == lineToFind }) {
                
                return indexOfLineToFind
            }
        }
        
        return nil
    }
    
    func removeLineBetween(_ cell: Cell, and otherCell: Cell) {
        
        let vertical = cell.yPos == otherCell.yPos
        
        if let index = indexOfLineBetween(cell, and: otherCell) {
            if vertical {
                verticalLines.remove(at: index)
            }
            else {
                horizontalLines.remove(at: index)
            }
        }
    }
    
    func openCells(neighbouring cell: Cell) -> [Cell] {
        var neighbours = [Cell]()
        
        for direction in cell.directionsToTest(inside: size) {
            if let neighbour = neighbourCell(of: cell, in: direction) {
                
                if indexOfLineBetween(cell, and: neighbour) == nil {
                    neighbours.append(neighbour)
                }
            }
        }
        
        return neighbours
    }
    
    func neighbourCell(of cell: Cell, in direction: Direction) -> Cell? {
        
        switch direction {
        case .left:     return cellToTheLeft(of: cell)
        case .right:    return cellToTheRight(of: cell)
        case .up:       return cellAbove(cell)
        case .down:     return cellBelow(cell)
        case .none:     return nil
        }
    }
    
    func cellToTheLeft(of cell : Cell) -> Cell? {
        if cell.xPos < 1 || cells.count < cell.xPos - 1 {
            return nil
        }
        
        let row = cell.yPos
        let col = cell.xPos
        let cellColumn = cells[col - 1]
        
        if row < cellColumn.count {
            return cellColumn[row]
        }
        
        return nil
    }
    
    func cellToTheRight(of cell : Cell) -> Cell? {
        if cell.xPos == size.width || cell.xPos + 1 >= cells.count {
            return nil
        }
        let row = cell.yPos
        let col = cell.xPos
        
        let cellColumn = cells[col + 1]
        
        if row < cellColumn.count {
            return cellColumn[row]
        }
        
        return nil
    }
    
    func cellAbove(_ cell : Cell) -> Cell? {
        if cell.yPos == size.height || cell.xPos >= cells.count {
            return nil
        }
        
        let cellColumn = cells[cell.xPos]
        
        if cellColumn.count > cell.yPos + 1 {
            return cellColumn[cell.yPos + 1]
        }
        
        return nil
    }
    
    func cellBelow(_ cell : Cell) -> Cell? {
        if cell.yPos < 1 || cell.xPos >= cells.count {
            return nil
        }
        
        let cellColumn = cells[cell.xPos]
        
        if cell.yPos < cellColumn.count {
            return cellColumn[cell.yPos - 1]
        }
        
        return nil
    }
    
    func cellsEitherSide(of line: Line) -> (Cell?, Cell?) {
        
        if line.vertical() {
            
            var leftCell: Cell?
            var rightCell: Cell?
            let yVal = line.end.y > line.start.y ? line.start.y : line.end.y
            
            if line.start.x > 0 {
                leftCell = cellAt(line.start.x - 1, yVal)
            }
            if line.start.x < cells.count {
                rightCell = cellAt(line.start.x, yVal)
            }
            
            return (leftCell, rightCell)
        }
        else {
            
            var topCell: Cell?
            var bottomCell: Cell?
            let xVal = line.end.x > line.start.x ? line.start.x : line.end.x
            
            if line.start.y > 0 {
                bottomCell = cellAt(xVal, line.start.y - 1)
            }
            if line.start.y < cells[xVal].count  {
                topCell = cellAt(xVal, line.start.y)
            }
            
            return (bottomCell, topCell)
        }
    }
    
    func addLineBetweenCells(_ cell: Cell, and otherCell : Cell) {
        let vertical = cell.yPos == otherCell.yPos
        
        if vertical {
            let yPos = cell.yPos
            let xPos = cell.xPos > otherCell.xPos ? cell.xPos : otherCell.xPos
            let start = Point(xPos, yPos)
            let end = Point(xPos, yPos + 1)
            
            verticalLines.append(Line(start :start, end: end))
        }
        else {
            let xPos = cell.xPos
            let yPos = cell.yPos > otherCell.yPos ? cell.yPos : otherCell.yPos
            let start = Point(xPos, yPos)
            let end = Point(xPos + 1, yPos)
            
            horizontalLines.append(Line(start :start, end: end))
        }
    }
}
