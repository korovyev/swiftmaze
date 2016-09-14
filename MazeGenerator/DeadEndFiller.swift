//
//  DeadEndFiller.swift
//  swiftmaze
//
//  Created by Kevin Sweeney on 14/09/2016.
//  Copyright © 2016 Kevin Sweeney. All rights reserved.
//

import Foundation

class DeadEndFiller: Solver {
    var state: SolverState
    var updateInterval: Float
    var stop: Bool
    var beginCell: Cell?
    var endCell: Cell?
    var cells = [[Cell]]()
    var depth = 2
    
    init(updateInterval: Float) {
        self.updateInterval = updateInterval
        state = .idle
        stop = false
    }
    
    func quit() {
        stop = true
        state = .finished
    }
    
    func solveMaze(in grid: Grid, step: @escaping () -> Void) {
        cells = grid.cells
        beginCell = cells[0][0]
        endCell = cells[grid.cells.count - 1][grid.cells[0].count - 1]
        
        closeDeadEnds(columnIndex: 0, deadEndFound: false, direction: .right, grid: grid, step: step)
    }
    
    func closeDeadEnds(columnIndex: Int, deadEndFound: Bool, direction: Direction, grid: Grid, step: @escaping () -> Void) {
        
        if columnIndex >= grid.cells.count && !deadEndFound {
            grid.highlightCells = nil
            state = .finished
        }
        else if columnIndex >= grid.cells.count || columnIndex < 0{
            let newDirection = direction.opposite()
            let nextColumnIndex = newDirection == .right ? columnIndex + 1 : columnIndex - 1
            
            if depth < 513 {
                depth = depth * depth * depth
            }
            
            
            closeDeadEnds(columnIndex: nextColumnIndex, deadEndFound: false, direction: newDirection, grid: grid, step: step)
        }
        else {
            let column = grid.cells[columnIndex]
            var deadEndCount = 0
            
            grid.highlightCells = column
            
            for cell in column where !cell.solverVisited {
                if closeDeadEnd(cell: cell, grid: grid, depth: depth) {
                    deadEndCount += 1
                }
            }
            
            let foundDeadEnd = deadEndCount > 0 || deadEndFound
            
            let nextColumnIndex = direction == .right ? columnIndex + 1 : columnIndex - 1
            
            delay(step: {
                self.closeDeadEnds(columnIndex: nextColumnIndex, deadEndFound: foundDeadEnd, direction: direction, grid: grid, step: step)
            })
        }
        
        step()
    }
    
    @discardableResult func closeDeadEnd(cell: Cell, grid: Grid, depth: Int) -> Bool {
        
        if cell == beginCell || cell == endCell || depth <= 0 {
            return false
        }
        
        let openCells = grid.openCells(neighbouring: cell)
        
        var foundDeadEnd = false
        
        if openCells.count == 1 {
            foundDeadEnd = true
            grid.addLineBetweenCells(cell, and: openCells[0])
            closeDeadEnd(cell: openCells[0], grid: grid, depth: depth - 1)
            cell.solverVisited = true
        }
        
        return foundDeadEnd
    }
}

