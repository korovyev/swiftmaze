//
//  FloodFill.swift
//  swiftmaze
//
//  Created by Kevin Sweeney on 15/09/2016.
//  Copyright © 2016 Kevin Sweeney. All rights reserved.
//

import Foundation

class FloodFill: Solver {
    var state: SolverState
    var updateInterval: Float
    var stop: Bool
    var activeCells = [Cell]()
    var filledCells = [Cell]()
    
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
        
        fill(grid: grid, step: step)
    }
    
    func fill(grid: Grid, step: @escaping () -> Void) {
        
        if stop {
            return
        }
        
        if activeCells.count > 0 {
            
            var nextCells = [Cell]()
            
            for cell in activeCells {
                cell.solverVisited = true
                filledCells.append(cell)
                nextCells.append(contentsOf: grid.openCells(neighbouring: cell).filter({ !$0.solverVisited }))
            }
            
            activeCells = nextCells
            
            delay(step: {
                self.fill(grid: grid, step: step)
            })
        }
        else {
            state = .finished
        }
        
        grid.highlightCells = filledCells
        step()
    }
}
