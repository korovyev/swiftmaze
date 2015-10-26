//
//  Grid.swift
//  swiftmaze
//
//  Created by Kevin Sweeney on 10/10/2015.
//  Copyright © 2015 Kevin Sweeney. All rights reserved.
//

import Foundation

class Grid {
    var visitedCells : [Cell] = []
    var visitedCellsIndex : Int = 0
    var verticalCellArrays : [[Cell]] = []
    var verticalLines : [Line] = []
    var filledCells: [Cell] = []
    var horizontalLines : [Line] = []
    var activeCells : [Cell] = [] // 'active' cells - i.e. cells surrounding current cell to check
    var size : Size
    var drawHandler:() -> Void = {}
    let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(0.001 * Double(NSEC_PER_SEC)))
    var cellsToCheck : [Cell] = []
    var directionsToTest = [Direction.Left, Direction.Up, Direction.Right, Direction.Down].shuffle()
    var rectangles : [Rectangle] = []
    
    init(size: Size) {
        self.size = size
    }
    
    func buildFrame() {
        
        for var x = 0 ; x < self.size.width ; ++x {
            
            let topLine = Line(start: Point(x : x, y : 0), end: Point(x : x + 1, y : 0))
            
            self.horizontalLines.append(topLine)
            
            let bottomLine = Line(start: Point(x: x, y: self.size.height), end: Point(x : x + 1, y : self.size.height))
            
            self.horizontalLines.append(bottomLine)
        }
        
        for var y = 0 ; y < self.size.height ; ++y {
            
            let leftLine = Line(start: Point(x: 0, y: y), end: Point(x: 0, y: y + 1))
            
            self.verticalLines.append(leftLine)
            
            let rightLine = Line(start: Point(x: self.size.width, y: y), end: Point(x: self.size.width, y: y + 1))
            
            self.verticalLines.append(rightLine)
        }
    }
    
    func buildGrid() {
        for var x = 1 ; x < self.size.width ; ++x {
            for var y = 0 ; y < self.size.height ; ++y {
                self.verticalLines.append(Line(start: Point(x: x, y: y), end: Point(x: x, y: y + 1)))
            }
        }
        
        for var y = 1 ; y < self.size.height ; ++y {
            for var x = 0 ; x < self.size.width ; ++x {
                self.horizontalLines.append(Line(start: Point(x: x, y: y), end: Point(x: x + 1, y: y)))
            }
        }
    }
    
    func createCells() {
        for var x = 0 ; x < size.width ; ++x {
            
            var verticalCellArray : [Cell] = [];
            
            for var y = 0 ; y < size.height ; ++y {
                let cell = Cell(x: x, y: y)
                
                verticalCellArray.append(cell)
            }
            
            if verticalCellArray.count > 0 {
                self.verticalCellArrays.append(verticalCellArray)
            }
            
        }
    }
    
    func startMaze(mazeType: MazeType, drawHandler:() -> Void) {
        
        self.drawHandler = drawHandler
        
        switch mazeType {
        case .RecursiveBacktracker:
            self.startRecursiveBacktracker()
        case .RecursiveDivision:
            self.startRecursiveDivision()
        case .SpanningTree:
            self.startSpanningTree()
        }
    }
    
    func startRecursiveBacktracker() {
        self.buildFrame()
        self.buildGrid()
        self.createCells()
        
        
        self.verticalCellArrays[0][0].visited = true
        
        var firstCell = self.verticalCellArrays[0][0];
        
        firstCell.visited = true;
        self.visitedCells.append(firstCell);
        
        self.drawHandler()
        
        self.getNextCell(firstCell)
    }
    
    func startRecursiveDivision() {
        self.buildFrame()
        self.createCells()
        
        self.drawHandler()
        
        let wholeRectangle = Rectangle(origin: Point(x:0, y:0), size : self.size)
        
        self.makeRandomLineInRectangle(wholeRectangle)
    }
    
    func startSpanningTree() {
        
    }
    
    func makeRandomLineInRectangle(rectangle : Rectangle) {
        
        var begin: Point
        var end: Point
        
        if rectangle.size.width < rectangle.size.height {
            // split rectangle into two horizontally
            
            let yVal = Int(arc4random_uniform(UInt32(rectangle.size.height - 1))) + 1
            
            begin = Point(x : rectangle.origin.x, y: rectangle.origin.y + yVal)
            end = Point(x: rectangle.origin.x + rectangle.size.width, y: rectangle.origin.y + yVal)
            
            let topRect = Rectangle(origin: rectangle.origin, size: Size(width: rectangle.size.width, height: yVal))
            let bottomRect = Rectangle(origin: Point(x: rectangle.origin.x, y: rectangle.origin.y + yVal), size: Size(width: rectangle.size.width, height: rectangle.size.height - yVal))
            
            if topRect.size.height > 1 {
                self.rectangles.append(topRect)
            }
            
            if bottomRect.size.height > 1 {
                self.rectangles.append(bottomRect)
            }
        }
        else {
            // split rectangle into two vertically
            
            let xVal = Int(arc4random_uniform(UInt32(rectangle.size.width - 1))) + 1
            
            begin = Point(x: rectangle.origin.x + xVal, y: rectangle.origin.y)
            end = Point(x: rectangle.origin.x + xVal, y: rectangle.origin.y + rectangle.size.height)
            
            let leftRect = Rectangle(origin: rectangle.origin, size: Size(width: xVal, height: rectangle.size.height))
            let rightRect = Rectangle(origin: Point(x: rectangle.origin.x + xVal, y: rectangle.origin.y), size: Size(width: rectangle.size.width - xVal, height: rectangle.size.height))
            
            if leftRect.size.width > 1 {
                self.rectangles.append(leftRect)
            }
            
            if rightRect.size.width > 1 {
                self.rectangles.append(rightRect)
            }
        }
        
        self.drawRandomLineWithDoor(Line(start: begin, end: end))
        
        if self.rectangles.count > 0 {
            dispatch_after(delayTime, dispatch_get_main_queue(), { () -> Void in
                let nextRectangle = self.rectangles.popLast()!
                
                self.makeRandomLineInRectangle(nextRectangle)
            })
        }
        else {
            self.startFill()
        }
    }
    
    func drawRandomLineWithDoor(line : Line) {
        
        let numSegments = line.vertical() ? line.end.x - line.start.x : line.end.y - line.start.y
        
        let indexOfSegmentNotToDraw = Int(arc4random_uniform(UInt32(numSegments)))
        
        if !line.vertical() {
            
            for index in line.start.y..<line.end.y {
                if index != line.start.y + indexOfSegmentNotToDraw {
                    let newLine = Line(start: Point(x: line.start.x, y: index), end: Point(x: line.start.x, y: index + 1))
                    
                    self.verticalLines.append(newLine)
                }
            }
        }
        else {
            
            for index in line.start.x..<line.end.x {
                if index != line.start.x + indexOfSegmentNotToDraw {
                    let newLine = Line(start: Point(x: index, y: line.start.y), end: Point(x: index + 1, y: line.start.y))
                    
                    self.horizontalLines.append(newLine)
                }
            }
        }
        
        self.drawHandler()
    }
    
    func getNextCell(cell : Cell) {
        
        self.cellsToCheck.append(cell)
        
        var nextCell = Cell(x: cell.xPos, y: cell.yPos)
        
        var foundCell:Bool = false
        
        self.directionsToTest.shuffleInPlace()
        
        for direction in directionsToTest {
            switch direction { //0 = left, 1 = up, 2 = rght, 3 = down
            case .Left:
                let validLeftCell = self.validLeftCell(cell, forFill:false)
                
                if validLeftCell.isGood {
                    nextCell = validLeftCell.cell
                    foundCell = true
                }
            case .Up:
                let validUpCell = self.validUpCell(cell, forFill:false)
                
                if validUpCell.isGood {
                    nextCell = validUpCell.cell
                    foundCell = true
                }
            case .Right:
                let validRightCell = self.validRightCell(cell, forFill:false)
                
                if validRightCell.isGood {
                    nextCell = validRightCell.cell
                    foundCell = true
                }
            case .Down:
                let validDownCell = self.validDownCell(cell, forFill:false)
                
                if validDownCell.isGood {
                    nextCell = validDownCell.cell
                    foundCell = true
                }
            }
            
            if foundCell {
                self.removeLineBetweenCells(cell, secondCell: nextCell)
                
                break;
            }
        }
        
        self.drawHandler()
        
        if !foundCell {
            
            self.visitedCells.popLast()
            
            self.visitedCellsIndex--
            if self.visitedCellsIndex >= 0 {
                self.getNextCell(self.visitedCells[self.visitedCellsIndex])
            }
            else {
                startFill()
            }
        }
        else {
            self.verticalCellArrays[nextCell.xPos][nextCell.yPos].visited = true
            
            nextCell.visited = true
            self.visitedCells.append(nextCell)
            self.visitedCellsIndex = self.visitedCells.count - 1
            
            
            
            dispatch_after(delayTime, dispatch_get_main_queue(), { () -> Void in
                self.getNextCell(nextCell)
            })
        }
    }
    
    func startFill() {
        self.verticalCellArrays[0][0].filled = true
        
        let firstCell = self.verticalCellArrays[0][0]
        
        self.filledCells.append(firstCell)
        
        self.drawHandler()
        
        self.fillCellsNextTo([firstCell])
    }
    
    func fillCellsNextTo(cells: [Cell]) {
        var nextCells:[Cell] = []
        
        for cell in cells {
            nextCells.appendContentsOf(self.openCellsNextTo(cell))
        }
        
        self.filledCells.appendContentsOf(nextCells)
        
        self.drawHandler()
        
        
        if nextCells.count > 0 {
            
            dispatch_after(delayTime, dispatch_get_main_queue(), { () -> Void in
                self.fillCellsNextTo(nextCells)
            })
        }
    }
    
    func openCellsNextTo(cell: Cell) -> [Cell] {
        var nextCells:[Cell] = []
        
        let validLeftCell = self.validLeftCell(cell, forFill: true)
        
        if validLeftCell.isGood {
            nextCells.append(validLeftCell.cell)
        }
        
        let validRightCell = self.validRightCell(cell, forFill: true)
        
        if validRightCell.isGood {
            nextCells.append(validRightCell.cell)
        }
        
        let validUpCell = self.validUpCell(cell, forFill: true)
        
        if validUpCell.isGood {
            nextCells.append(validUpCell.cell)
        }
        
        let validDownCell = self.validDownCell(cell, forFill: true)
        
        if validDownCell.isGood {
            nextCells.append(validDownCell.cell)
        }
        
        for cell in nextCells {
            self.verticalCellArrays[cell.xPos][cell.yPos].filled = true
        }
        
        return nextCells
    }
    
    func lineExistsBetweenCells(firstCell: Cell, secondCell: Cell) -> Bool {
        let verticalLine:Bool = firstCell.yPos == secondCell.yPos
        
        if verticalLine {
            let yPos = firstCell.yPos;
            
            let xPos = firstCell.xPos > secondCell.xPos ? firstCell.xPos : secondCell.xPos
            
            let start = Point(x : xPos, y: yPos)
            let end = Point(x: xPos, y: yPos + 1)
            let lineToFind = Line(start :start, end: end)
            
            if (self.verticalLines.indexOf({ $0 == lineToFind }) != nil) {
                
                return false
            }
        }
        else {
            let xPos = firstCell.xPos;
            
            let yPos = firstCell.yPos > secondCell.yPos ? firstCell.yPos : secondCell.yPos
            
            let start = Point(x : xPos, y: yPos)
            let end = Point(x: xPos + 1, y: yPos)
            let lineToFind = Line(start :start, end: end)
            
            if (self.horizontalLines.indexOf({ $0 == lineToFind }) != nil) {
                
                return false
            }
        }
        
        return true
    }
    
    func removeLineBetweenCells(firstCell : Cell, secondCell : Cell) {
        let verticalLine:Bool = firstCell.yPos == secondCell.yPos
        
        if verticalLine {
            let yPos = firstCell.yPos;
            
            let xPos = firstCell.xPos > secondCell.xPos ? firstCell.xPos : secondCell.xPos
            
            let start = Point(x : xPos, y: yPos)
            let end = Point(x: xPos, y: yPos + 1)
            let lineToFind = Line(start :start, end: end)
            
            if let indexOfLineToFind:Int = self.verticalLines.indexOf({ $0 == lineToFind }) {
            
                self.verticalLines.removeAtIndex(indexOfLineToFind)
            }
        }
        else {
            let xPos = firstCell.xPos;
            
            let yPos = firstCell.yPos > secondCell.yPos ? firstCell.yPos : secondCell.yPos
            
            let start = Point(x : xPos, y: yPos)
            let end = Point(x: xPos + 1, y: yPos)
            let lineToFind = Line(start :start, end: end)
            
            if let indexOfLineToFind:Int = self.horizontalLines.indexOf({ $0 == lineToFind }) {
            
                self.horizontalLines.removeAtIndex(indexOfLineToFind)
            }
        }
    }

    func validLeftCell(cell : Cell, forFill : Bool) -> (isGood: Bool, cell: Cell) {
        if cell.xPos == 0 {
            return (false, cell);
        }
        
        let row = cell.yPos;
        let col = cell.xPos;
        let cellColumn:Array = self.verticalCellArrays[col - 1]
        
        let leftCell:Cell = cellColumn[row]
        
        var isGood:Bool = true
        
        if !forFill {
            isGood = !leftCell.visited
        }
        else {
            isGood = !leftCell.filled
            
            if isGood {
                isGood = self.lineExistsBetweenCells(cell, secondCell: leftCell)
            }
        }
        
        return (isGood, leftCell)
    }
    
    func validRightCell(cell : Cell, forFill : Bool) -> (isGood: Bool, cell: Cell) {
        
        let row = cell.yPos;
        let col = cell.xPos;
        
        
        if col == self.verticalCellArrays.count - 1 {
            return (false, cell);
        }
        
        let cellColumn:Array = self.verticalCellArrays[col + 1]
        
        let rightCell:Cell = cellColumn[row]
        
        var isGood:Bool = true
        
        if !forFill {
            isGood = !rightCell.visited
        }
        else {
            isGood = !rightCell.filled
            
            if isGood {
                isGood = self.lineExistsBetweenCells(cell, secondCell: rightCell)
            }
        }
        
        return (isGood, rightCell)
    }
    
    func validUpCell(cell : Cell, forFill : Bool) -> (isGood: Bool, cell: Cell) {
        
        if cell.yPos == 0 {
            return (false, cell);
        }
        
        let cellColumn:Array = self.verticalCellArrays[cell.xPos]
        
        let upCell:Cell = cellColumn[cell.yPos - 1]
        
        var isGood:Bool = true
        
        if !forFill {
            isGood = !upCell.visited
        }
        else {
            isGood = !upCell.filled
            
            if isGood {
                isGood = self.lineExistsBetweenCells(cell, secondCell: upCell)
            }
        }
        
        return (isGood, upCell)
    }
    
    func validDownCell(cell : Cell, forFill : Bool) -> (isGood: Bool, cell: Cell) {
        
        let row = cell.yPos;
        let col = cell.xPos;
        
        if row == self.verticalCellArrays[0].count - 1 {
            return (false, cell);
        }
        
        let cellColumn:Array = self.verticalCellArrays[col]
        
        let downCell:Cell = cellColumn[row + 1]
        
        var isGood:Bool = true
        
        if !forFill {
            isGood = !downCell.visited
        }
        else {
            isGood = !downCell.filled
            
            if isGood {
                isGood = self.lineExistsBetweenCells(cell, secondCell: downCell)
            }
        }
        
        return (isGood, downCell)
    }
}