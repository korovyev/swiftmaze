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
    let delayTime = DispatchTime.now() + Double(Int64(0.001 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
    var cellsToCheck : [Cell] = []
    var directionsToTest = [Direction.left, Direction.up, Direction.right, Direction.down].shuffle()
    var rectangles : [Rectangle] = []
    var aStarOpenList : [Cell] = []
    var aStarClosedList : [Cell] = []
    var aStarGCost : Int = 1
    var shortestPath : [Cell] = []
    var solveType : SolveType = SolveType.none
    var tremauxActiveCells : [Cell] = []
    var tremauxActiveJunctions : [Cell] = []
    var deadEndFillingCellsToCheck : [[Cell]] = []
    
    init(size: Size) {
        self.size = size
    }
    
    func buildFrame() {
        
        for x in 0  ..< self.size.width {
            
            let topLine = Line(start: Point(x, 0), end: Point(x + 1, 0))
            
            self.horizontalLines.append(topLine)
            
            let bottomLine = Line(start: Point(x, self.size.height), end: Point(x + 1, self.size.height))
            
            self.horizontalLines.append(bottomLine)
        }
        
        for y in 0  ..< self.size.height {
            
            let leftLine = Line(start: Point(0, y), end: Point(0, y + 1))
            
            self.verticalLines.append(leftLine)
            
            let rightLine = Line(start: Point(self.size.width, y), end: Point(self.size.width, y + 1))
            
            self.verticalLines.append(rightLine)
        }
    }
    
    func buildGrid() {
        for x in 1  ..< self.size.width {
            for y in 0  ..< self.size.height {
                self.verticalLines.append(Line(start: Point(x, y), end: Point(x, y + 1)))
            }
        }
        
        for y in 1  ..< self.size.height {
            for x in 0  ..< self.size.width {
                if !(x == 0 && y == 1) {
                    self.horizontalLines.append(Line(start: Point(x, y), end: Point(x + 1, y)))
                }
            }
        }
    }
    
    func createCells() {
        for x in 0  ..< size.width {
            
            var verticalCellArray : [Cell] = [];
            
            for y in 0  ..< size.height {
                let cell = Cell(x: x, y: y)
                
                verticalCellArray.append(cell)
            }
            
            if verticalCellArray.count > 0 {
                self.verticalCellArrays.append(verticalCellArray)
            }
            
        }
    }
    
    func startMaze(_ mazeType: MazeType, solveType: SolveType, drawHandler:@escaping () -> Void) {
        
        self.drawHandler = drawHandler
        
        self.solveType = solveType
        
//        switch mazeType {
//        case .recursiveBacktracker:
//            self.startRecursiveBacktracker()
//        case .recursiveDivision:
//            self.startRecursiveDivision()
//        case .spanningTree:
//            self.startSpanningTree()
//        }
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
        
        let wholeRectangle = Rectangle(origin: Point(0, 0), size : self.size)
        
        self.makeRandomLineInRectangle(wholeRectangle)
    }
    
    func startSpanningTree() {
        
    }
    
    func makeRandomLineInRectangle(_ rectangle : Rectangle) {
        
        var begin: Point
        var end: Point
        
        if rectangle.size.width < rectangle.size.height {
            // split rectangle into two horizontally
            
            let yVal = Int(arc4random_uniform(UInt32(rectangle.size.height - 1))) + 1
            
            begin = Point(rectangle.origin.x, rectangle.origin.y + yVal)
            end = Point(rectangle.origin.x + rectangle.size.width, rectangle.origin.y + yVal)
            
            let topRect = Rectangle(origin: rectangle.origin, size: Size(width: rectangle.size.width, height: yVal))
            let bottomRect = Rectangle(origin: Point(rectangle.origin.x, rectangle.origin.y + yVal), size: Size(width: rectangle.size.width, height: rectangle.size.height - yVal))
            
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
            
            begin = Point(rectangle.origin.x + xVal, rectangle.origin.y)
            end = Point(rectangle.origin.x + xVal, rectangle.origin.y + rectangle.size.height)
            
            let leftRect = Rectangle(origin: rectangle.origin, size: Size(width: xVal, height: rectangle.size.height))
            let rightRect = Rectangle(origin: Point(rectangle.origin.x + xVal, rectangle.origin.y), size: Size(width: rectangle.size.width - xVal, height: rectangle.size.height))
            
            if leftRect.size.width > 1 {
                self.rectangles.append(leftRect)
            }
            
            if rightRect.size.width > 1 {
                self.rectangles.append(rightRect)
            }
        }
        
        self.drawRandomLineWithDoor(Line(start: begin, end: end))
        
        if self.rectangles.count > 0 {
            
            DispatchQueue.main.asyncAfter(deadline: delayTime, execute: {
                let nextRectangle = self.rectangles.popLast()!
                
                self.makeRandomLineInRectangle(nextRectangle)
            })
        }
        else {
            self.startSolve()
        }
    }
    
    func drawRandomLineWithDoor(_ line : Line) {
        
        let numSegments = line.vertical() ? line.end.x - line.start.x : line.end.y - line.start.y
        
        let indexOfSegmentNotToDraw = Int(arc4random_uniform(UInt32(numSegments)))
        
        if !line.vertical() {
            
            for index in line.start.y..<line.end.y {
                if index != line.start.y + indexOfSegmentNotToDraw {
                    let newLine = Line(start: Point(line.start.x, index), end: Point(line.start.x, index + 1))
                    
                    self.verticalLines.append(newLine)
                }
            }
        }
        else {
            
            for index in line.start.x..<line.end.x {
                if index != line.start.x + indexOfSegmentNotToDraw {
                    let newLine = Line(start: Point(index, line.start.y), end: Point(index + 1, line.start.y))
                    
                    self.horizontalLines.append(newLine)
                }
            }
        }
        
        self.drawHandler()
    }
    
    func getNextCell(_ cell : Cell) {
        
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
            
            
            DispatchQueue.main.asyncAfter(deadline: delayTime, execute: {
                self.getNextCell(nextCell!)
            })
        }
        else {
            visitedCells.removeLast()
            
            self.visitedCellsIndex -= 1
            if self.visitedCellsIndex >= 0 {
                self.getNextCell(self.visitedCells[self.visitedCellsIndex])
            }
            else {
                startSolve()
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
    
    func fillCellsNextTo(_ cells: [Cell]) {
        var nextCells:[Cell] = []
        
        for cell in cells {
            
            let unfilledNextCells = self.unfilledCellsNextTo(cell)
            
            for unfilledCell in unfilledNextCells {
                self.verticalCellArrays[unfilledCell.xPos][unfilledCell.yPos].filled = true
            }
            
            nextCells.append(contentsOf: unfilledNextCells)
        }
        
        self.filledCells.append(contentsOf: nextCells)
        
        self.drawHandler()
        
        
        if nextCells.count > 0 {
            
            DispatchQueue.main.asyncAfter(deadline: delayTime, execute: {
                self.fillCellsNextTo(nextCells)
            })
        }
        else {
            self.startSolve()
        }
    }
    
    func cellsNextTo(_ cell : Cell) -> [Cell] {
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
    
    func openCellsNextTo(_ cell : Cell) -> [Cell] {
        let nextCells = self.cellsNextTo(cell)
        
        var openCells: [Cell] = []
        
        for nextCell in nextCells {
            if !self.lineExistsBetweenCells(cell, secondCell: nextCell) {
                openCells.append(nextCell)
            }
        }
        
        return openCells
    }
    
    func unfilledCellsNextTo(_ cell : Cell) -> [Cell] {
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
    
    
    func lineExistsBetweenCells(_ firstCell: Cell, secondCell: Cell) -> Bool {
        let verticalLine:Bool = firstCell.yPos == secondCell.yPos
        
        if verticalLine {
            let yPos = firstCell.yPos;
            
            let xPos = firstCell.xPos > secondCell.xPos ? firstCell.xPos : secondCell.xPos
            
            let start = Point(xPos, yPos)
            let end = Point(xPos, yPos + 1)
            let lineToFind = Line(start :start, end: end)
            
            if (self.verticalLines.index(where: { $0 == lineToFind }) != nil) {
                
                return true
            }
        }
        else {
            let xPos = firstCell.xPos;
            
            let yPos = firstCell.yPos > secondCell.yPos ? firstCell.yPos : secondCell.yPos
            
            let start = Point(xPos, yPos)
            let end = Point(xPos + 1, yPos)
            let lineToFind = Line(start :start, end: end)
            
            if (self.horizontalLines.index(where: { $0 == lineToFind }) != nil) {
                
                return true
            }
        }
        
        return false
    }
    
    func removeLineBetweenCells(_ firstCell : Cell, secondCell : Cell) {
        let verticalLine:Bool = firstCell.yPos == secondCell.yPos
        
        if verticalLine {
            let yPos = firstCell.yPos;
            
            let xPos = firstCell.xPos > secondCell.xPos ? firstCell.xPos : secondCell.xPos
            
            let start = Point(xPos, yPos)
            let end = Point(xPos, yPos + 1)
            let lineToFind = Line(start :start, end: end)
            
            if let indexOfLineToFind:Int = self.verticalLines.index(where: { $0 == lineToFind }) {
            
                self.verticalLines.remove(at: indexOfLineToFind)
            }
        }
        else {
            let xPos = firstCell.xPos;
            
            let yPos = firstCell.yPos > secondCell.yPos ? firstCell.yPos : secondCell.yPos
            
            let start = Point(xPos, yPos)
            let end = Point(xPos + 1, yPos)
            let lineToFind = Line(start :start, end: end)
            
            if let indexOfLineToFind:Int = self.horizontalLines.index(where: { $0 == lineToFind }) {
            
                self.horizontalLines.remove(at: indexOfLineToFind)
            }
        }
    }
    
    func unvisitedCell(_ cell : Cell, inDirection : Direction) -> Cell? {
        
        
        switch inDirection {
        case .left:
            if let leftCell = self.leftCell(cell) {
                if !leftCell.visited {
                    return leftCell
                }
                else {
                    return nil
                }
            }
        case .right:
            if let rightCell = self.rightCell(cell) {
                if !rightCell.visited {
                    return rightCell
                }
                else {
                    return nil
                }
            }
        case .up:
            if let upCell = self.upCell(cell) {
                if !upCell.visited {
                    return upCell
                }
                else {
                    return nil
                }
            }
        case .down:
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
    
    func leftCell(_ cell : Cell) -> Cell? {
        if cell.xPos == 0 {
            return (nil);
        }
        
        let row = cell.yPos;
        let col = cell.xPos;
        let cellColumn:Array = self.verticalCellArrays[col - 1]
        
        return cellColumn[row]
    }
    
    func rightCell(_ cell : Cell) -> Cell? {
        let row = cell.yPos;
        let col = cell.xPos;
        
        
        if col == self.verticalCellArrays.count - 1 {
            return (nil);
        }
        
        let cellColumn:Array = self.verticalCellArrays[col + 1]
        
        return cellColumn[row]
    }
    
    func topCell(_ cell : Cell) -> Cell? {
        if cell.yPos == 0 {
            return (nil);
        }
        
        let cellColumn:Array = self.verticalCellArrays[cell.xPos]
        
        return cellColumn[cell.yPos - 1]
    }
    
    func bottomCell(_ cell : Cell) -> Cell? {
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
        case .aStar:
            self.aStarClosedList = [self.verticalCellArrays[0][0]]
            
            self.solveAStar()
        case .tremaux:
            self.tremauxActiveCells = [self.verticalCellArrays[0][0]]
            self.solveTremaux()
        case .deadEndFilling:
            self.deadEndFillingCellsToCheck = self.verticalCellArrays
            self.solveDeadEndFilling()
        case .none:
            break
        }
        
    }
    
    func solveTremaux() {
        
        let cellToProceedFrom = self.tremauxActiveCells[self.tremauxActiveCells.count - 1]
        
        self.verticalCellArrays[cellToProceedFrom.xPos][cellToProceedFrom.yPos].tremauxVisited = true
        
        var nextCells = self.unvisitedTremauxCellsNextTo(cellToProceedFrom)
        
        if !nextCells.contains(self.verticalCellArrays[self.verticalCellArrays.count - 1][self.verticalCellArrays[0].count - 1]) {
            
            if nextCells.count > 1 {
                self.tremauxActiveJunctions.append(cellToProceedFrom)
            }
            else if nextCells.count == 0 {
                var lastJunctionCell = self.tremauxActiveJunctions[self.tremauxActiveJunctions.count - 1]
                
                if lastJunctionCell == cellToProceedFrom {
                    lastJunctionCell = self.tremauxActiveJunctions[self.tremauxActiveJunctions.count - 2]
                    
                    tremauxActiveJunctions.removeLast()
                }
                
                if let cutOffIndex = self.tremauxActiveCells.index(where: { $0 == lastJunctionCell }) {
                    
                    self.tremauxActiveCells = Array(self.tremauxActiveCells[0..<cutOffIndex+1])
                }
            }
            
            if nextCells.count > 0 {
                
                for cell in nextCells {
                    self.scoreCell(cell)
                }
                
                nextCells.sort(by: { self.verticalCellArrays[$0.xPos][$0.yPos].fScore > self.verticalCellArrays[$1.xPos][$1.yPos].fScore })
                
                self.tremauxActiveCells.append(nextCells.popLast()!)
            }
            
            self.drawHandler()
            
            DispatchQueue.main.asyncAfter(deadline: delayTime, execute: {
                self.solveTremaux()
            })
        }
        else {
            self.tremauxActiveCells.append(self.verticalCellArrays[self.verticalCellArrays.count - 1][self.verticalCellArrays[0].count - 1])
            
            self.drawHandler()
        }
    }
    
    func unvisitedTremauxCellsNextTo(_ cell : Cell) -> [Cell] {
        let nextCells = self.openCellsNextTo(cell)
        
        var unvisited : [Cell] = []
        
        for nextCell in nextCells {
            if !nextCell.tremauxVisited {
                unvisited.append(nextCell)
            }
        }
        
        return unvisited
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
            
            DispatchQueue.main.asyncAfter(deadline: delayTime, execute: {
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
    
    func findShortestPathBackwardsFrom(_ cell : Cell) {
        
        
        
        self.shortestPath.append(cell)
        
        let tempCell = Cell(x: cell.parentX, y: cell.parentY)
        
        if let nextCellIndex = self.aStarClosedList.index(where: { $0 == tempCell }) {
            
            let nextCell = self.aStarClosedList[nextCellIndex]
            
            if nextCell == self.verticalCellArrays[0][0] {
                self.shortestPath.append(nextCell)
                
                self.aStarClosedList = []
                self.aStarOpenList = []
            }
            else {
                DispatchQueue.main.asyncAfter(deadline: delayTime, execute: {
                    self.findShortestPathBackwardsFrom(nextCell)
                })
            }
        }
        
        self.drawHandler()
    }
    
    func sortOpenList() {
        self.aStarOpenList.sort(by: { self.verticalCellArrays[$0.xPos][$0.yPos].fScore > self.verticalCellArrays[$1.xPos][$1.yPos].fScore})
    }
    
    func scoreCell(_ cell : Cell) {
        
        let maxX = self.verticalCellArrays.count - 1
        let maxY = self.verticalCellArrays[0].count - 1
        
        
        let xDistance = cell.xPos > maxX ? cell.xPos - maxX : maxX - cell.xPos
        let yDistance = cell.yPos > maxY ? cell.yPos - maxY : maxY - cell.yPos
        
        
        let gScore = self.aStarGCost
        let hScore = xDistance + yDistance
        
        self.verticalCellArrays[cell.xPos][cell.yPos].fScore = gScore + hScore
    }
    
    func solveDeadEndFilling() {
        
        let beginCell = self.verticalCellArrays[0][0]
        let endCell = self.verticalCellArrays[self.verticalCellArrays.count - 1][self.verticalCellArrays[0].count - 1]
        
        var count = 0
        
        var closedCells : [Cell] = []
        
        for array in self.deadEndFillingCellsToCheck {
            
            for cell in array where self.openCellsNextTo(cell).count == 1 {
                if cell != beginCell && cell != endCell {
                    if let nextCell = self.openCellsNextTo(cell).first {
                    
                        self.addLineBetweenCells(cell, secondCell: nextCell)
                        count += 1
                        
                        closedCells.append(cell)
                    }
                }
            }
        }
        
        for cell in closedCells {
            self.deadEndFillingCellsToCheck[cell.xPos].removeObject(cell)
        }
        
        var cellCount = 0
        for array in self.deadEndFillingCellsToCheck {
            cellCount += array.count
        }
        
        self.drawHandler()
        
        if count > 0 {
            DispatchQueue.main.asyncAfter(deadline: delayTime, execute: {
                self.solveDeadEndFilling()
            })
        }
    }
    
    func addLineBetweenCells(_ firstCell : Cell, secondCell : Cell) {
        let verticalLine:Bool = firstCell.yPos == secondCell.yPos
        
        if verticalLine {
            let yPos = firstCell.yPos;
            
            let xPos = firstCell.xPos > secondCell.xPos ? firstCell.xPos : secondCell.xPos
            
            let start = Point(xPos, yPos)
            let end = Point(xPos, yPos + 1)
            var ghostLine = Line(start :start, end: end)
            ghostLine.ghost = true
            self.verticalLines.append(ghostLine)
        }
        else {
            let xPos = firstCell.xPos;
            
            let yPos = firstCell.yPos > secondCell.yPos ? firstCell.yPos : secondCell.yPos
            
            let start = Point(xPos, yPos)
            let end = Point(xPos + 1, yPos)
            var ghostLine = Line(start :start, end: end)
            ghostLine.ghost = true
            self.horizontalLines.append(ghostLine)
        }
    }
}
