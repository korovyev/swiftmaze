//
//  Tremaux.swift
//  swiftmaze
//
//  Created by Kevin Sweeney on 14/09/2016.
//  Copyright © 2016 Kevin Sweeney. All rights reserved.
//

import Foundation

class Tremaux: Solver {
    var state: SolverState
    var updateInterval: Float
    var stop: Bool
    var activeCells = [Cell]()
    var activeJunctions = [Cell]()
    var endCell: Cell?
    
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
        activeCells.append(grid.cells[0][0])
        endCell = grid.cells[grid.cells.count - 1][grid.cells[0].count - 1]
        
        solve(grid: grid, step: step)
    }
    
    func solve(grid: Grid, step: @escaping () -> Void) {
        
        guard let endCell = endCell, activeCells.count > 0  else {
            return
        }
        
        let cellToProceedFrom = activeCells[activeCells.count - 1]
        cellToProceedFrom.tremauxVisited = true
        var nextCells = unvisitedTremauxCells(neighbouring: cellToProceedFrom, in: grid)
        
        if !nextCells.contains(endCell) {
            
            if nextCells.count > 1 {
                activeJunctions.append(cellToProceedFrom)
            }
            else if nextCells.count == 0 {
                var lastJunctionCell = activeJunctions[activeJunctions.count - 1]
                
                if lastJunctionCell == cellToProceedFrom {
                    lastJunctionCell = activeJunctions[activeJunctions.count - 2]
                    
                    activeJunctions.removeLast()
                }
                
                if let cutOffIndex = activeCells.index(where: { $0 == lastJunctionCell }) {
                    
                    activeCells = Array(activeCells[0..<(cutOffIndex + 1)])
                }
            }
            
            if nextCells.count > 0 {
                
                for cell in nextCells {
                    score(cell, to: endCell)
                }
                
                nextCells.sort(by: { $0.fScore > $1.fScore })
                activeCells.append(nextCells.popLast()!)
            }
            
            grid.highlightCells = activeCells
            
            step()
            
            delay(step: {
                self.solve(grid: grid, step: step)
            })
        }
        else {
            activeCells.append(endCell)
            grid.highlightCells = activeCells
            state = .finished
            step()
        }
    }
    
    func unvisitedTremauxCells(neighbouring cell: Cell, in grid: Grid) -> [Cell] {
        let nextCells = grid.openCells(neighbouring: cell)
        
        return nextCells.filter({ return !$0.tremauxVisited })
    }
}
