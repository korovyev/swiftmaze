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
    var aStarOpenList : [Cell] = []
    var aStarClosedList : [Cell] = []
    var aStarGCost : Int = 1
    var shortestPath : [Cell] = []
    var solveType : SolveType = SolveType.None
    var tremauxActiveCells : [Cell] = []
    var tremauxActiveJunctions : [Cell] = []
    
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
    
    func startMaze(mazeType: MazeType, solveType: SolveType, drawHandler:() -> Void) {
        
        self.drawHandler = drawHandler
        
        self.solveType = solveType
        
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
            self.startSolve()
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
        
        var nextCell : Cell? = nil
        
        self.directionsToTest.shuffleInPlace()
        
        for direction in directionsToTest {
            
            if let testCell = self.unvisitedCell(cell, inDirection: direction) {
                
                self.removeLineBetweenCells(cell, secondCell: testCell)
                
                nextCell = testCell
                
                break;
            }
        }
        
        self.drawHandler()
        
        if nextCell != nil {
            self.verticalCellArrays[nextCell!.xPos][nextCell!.yPos].visited = true
            
            nextCell!.visited = true
            self.visitedCells.append(nextCell!)
            self.visitedCellsIndex = self.visitedCells.count - 1
            
            
            
            dispatch_after(delayTime, dispatch_get_main_queue(), { () -> Void in
                self.getNextCell(nextCell!)
            })
        }
        else {
            self.visitedCells.popLast()
            
            self.visitedCellsIndex--
            if self.visitedCellsIndex >= 0 {
                self.getNextCell(self.visitedCells[self.visitedCellsIndex])
            }
            else {
                startFill()
            }
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
            
            let unfilledNextCells = self.unfilledCellsNextTo(cell)
            
            for unfilledCell in unfilledNextCells {
                self.verticalCellArrays[unfilledCell.xPos][unfilledCell.yPos].filled = true
            }
            
            nextCells.appendContentsOf(unfilledNextCells)
        }
        
        self.filledCells.appendContentsOf(nextCells)
        
        self.drawHandler()
        
        
        if nextCells.count > 0 {
            
            dispatch_after(delayTime, dispatch_get_main_queue(), { () -> Void in
                self.fillCellsNextTo(nextCells)
            })
        }
        else {
            self.startSolve()
        }
    }
    
    func cellsNextTo(cell : Cell) -> [Cell] {
        var cells : [Cell] = []
        
        if let left = leftCell(cell) {
            cells.append(left)
        }
        
        if let right = rightCell(cell) {
            cells.append(right)
        }
        
        if let up = upCell(cell) {
            cells.append(up)
        }
        
        if let down = downCell(cell) {
            cells.append(down)
        }
        
        return cells
    }
    
    func openCellsNextTo(cell : Cell) -> [Cell] {
        let nextCells = self.cellsNextTo(cell)
        
        var openCells: [Cell] = []
        
        for nextCell in nextCells {
            if !self.lineExistsBetweenCells(cell, secondCell: nextCell) {
                openCells.append(nextCell)
            }
        }
        
        return openCells
    }
    
    func unfilledCellsNextTo(cell : Cell) -> [Cell] {
        var unfilledCells : [Cell] = []
        
        let nextCells = self.cellsNextTo(cell)
        
        for nextCell in nextCells {
            if !nextCell.filled {
                if !self.lineExistsBetweenCells(cell, secondCell: nextCell) {
                    unfilledCells.append(nextCell)
                }
            }
        }
        
        return unfilledCells
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
                
                return true
            }
        }
        else {
            let xPos = firstCell.xPos;
            
            let yPos = firstCell.yPos > secondCell.yPos ? firstCell.yPos : secondCell.yPos
            
            let start = Point(x : xPos, y: yPos)
            let end = Point(x: xPos + 1, y: yPos)
            let lineToFind = Line(start :start, end: end)
            
            if (self.horizontalLines.indexOf({ $0 == lineToFind }) != nil) {
                
                return true
            }
        }
        
        return false
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
    
    func unvisitedCell(cell : Cell, inDirection : Direction) -> Cell? {
        
        
        switch inDirection {
        case .Left:
            if let leftCell = self.leftCell(cell) {
                if !leftCell.visited {
                    return leftCell
                }
                else {
                    return nil
                }
            }
        case .Right:
            if let rightCell = self.rightCell(cell) {
                if !rightCell.visited {
                    return rightCell
                }
                else {
                    return nil
                }
            }
        case .Up:
            if let upCell = self.upCell(cell) {
                if !upCell.visited {
                    return upCell
                }
                else {
                    return nil
                }
            }
        case .Down:
            if let downCell = self.downCell(cell) {
                if !downCell.visited {
                    return downCell
                }
                else {
                    return nil
                }
            }
        }
        
        return nil
    }
    
    func leftCell(cell : Cell) -> Cell? {
        if cell.xPos == 0 {
            return (nil);
        }
        
        let row = cell.yPos;
        let col = cell.xPos;
        let cellColumn:Array = self.verticalCellArrays[col - 1]
        
        return cellColumn[row]
    }
    
    func rightCell(cell : Cell) -> Cell? {
        let row = cell.yPos;
        let col = cell.xPos;
        
        
        if col == self.verticalCellArrays.count - 1 {
            return (nil);
        }
        
        let cellColumn:Array = self.verticalCellArrays[col + 1]
        
        return cellColumn[row]
    }
    
    func upCell(cell : Cell) -> Cell? {
        if cell.yPos == 0 {
            return (nil);
        }
        
        let cellColumn:Array = self.verticalCellArrays[cell.xPos]
        
        return cellColumn[cell.yPos - 1]
    }
    
    func downCell(cell : Cell) -> Cell? {
        let row = cell.yPos;
        let col = cell.xPos;
        
        if row == self.verticalCellArrays[0].count - 1 {
            return (nil);
        }
        
        let cellColumn:Array = self.verticalCellArrays[col]
        
        return cellColumn[row + 1]
    }
    
    func startSolve() {
        
        switch self.solveType {
        case .AStar:
            self.aStarClosedList = [self.verticalCellArrays[0][0]]
            
            self.solveAStar()
        case .Tremaux:
            self.tremauxActiveCells = [self.verticalCellArrays[0][0]]
            self.solveTremaux()
        case .None:
            break
        }
        
    }
    
    func solveTremaux() {
        
        let cellToProceedFrom = self.tremauxActiveCells[self.aStarClosedList.count - 1]
        
        let nextCells = self.unvisitedTremauxCellsNextTo(cellToProceedFrom)
    }
    
    func unvisitedTremauxCellsNextTo(cell : Cell) -> [Cell] {
        let nextCells = self.cellsNextTo(cell)
        
        var unvisited : [Cell] = []
        
        for cell in nextCells {
            if
        }
    }
    
    func solveAStar() {
        
        let cellToProceedFrom = self.aStarClosedList[self.aStarClosedList.count - 1]
        
        let nextCells = self.openCellsNextTo(cellToProceedFrom)
        
        if !nextCells.contains(self.verticalCellArrays[self.verticalCellArrays.count - 1][self.verticalCellArrays[0].count - 1]) {
            
            
            for index in 0..<nextCells.count {
                
                var cell = nextCells[index]
                
                if !self.aStarClosedList.contains(cell) {
                    self.scoreCell(cell)
                    
                    cell.parentX = cellToProceedFrom.xPos
                    cell.parentY = cellToProceedFrom.yPos
                    
                    self.aStarOpenList.append(cell)
                }
            }
            
            self.sortOpenList()
            
            self.aStarClosedList.append(self.aStarOpenList.popLast()!)
            
            self.drawHandler()
            
            dispatch_after(delayTime, dispatch_get_main_queue(), { () -> Void in
                
                self.solveAStar()
            })
        }
        else {
            
            var finalCell = self.verticalCellArrays[self.verticalCellArrays.count - 1][self.verticalCellArrays[0].count - 1]
            
            finalCell.parentX = cellToProceedFrom.xPos
            finalCell.parentY = cellToProceedFrom.yPos
            
            self.aStarClosedList.append(finalCell)
            
            self.drawHandler()
            
            self.findShortestPathBackwardsFrom(finalCell)
        }
    }
    
    func findShortestPathBackwardsFrom(cell : Cell) {
        
        
        
        self.shortestPath.append(cell)
        
        let tempCell = Cell(x: cell.parentX, y: cell.parentY)
        
        if let nextCellIndex = self.aStarClosedList.indexOf({ $0 == tempCell }) {
            
            let nextCell = self.aStarClosedList[nextCellIndex]
            
            if nextCell == self.verticalCellArrays[0][0] {
                self.shortestPath.append(nextCell)
                
                self.aStarClosedList = []
                self.aStarOpenList = []
            }
            else {
                dispatch_after(delayTime, dispatch_get_main_queue(), { () -> Void in
                    
                    self.findShortestPathBackwardsFrom(nextCell)
                })
            }
        }
        
        self.drawHandler()
    }
    
    func sortOpenList() {
        self.aStarOpenList.sortInPlace({ self.verticalCellArrays[$0.xPos][$0.yPos].fScore > self.verticalCellArrays[$1.xPos][$1.yPos].fScore})
    }
    
    func scoreCell(cell : Cell) {
        
        let maxX = self.verticalCellArrays.count - 1
        let maxY = self.verticalCellArrays[0].count - 1
        
        
        let xDistance = cell.xPos > maxX ? cell.xPos - maxX : maxX - cell.xPos
        let yDistance = cell.yPos > maxY ? cell.yPos - maxY : maxY - cell.yPos
        
        
        let gScore = self.aStarGCost
        let hScore = xDistance + yDistance
        
        self.verticalCellArrays[cell.xPos][cell.yPos].fScore = gScore + hScore
    }
}