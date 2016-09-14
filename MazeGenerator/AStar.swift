//
//  AStar.swift
//  swiftmaze
//
//  Created by Kevin Sweeney on 14/09/2016.
//  Copyright © 2016 Kevin Sweeney. All rights reserved.
//

import Foundation

class AStar: Solver {
    var state: SolverState
    var updateInterval: Float
    var stop: Bool
    var closedList = [Cell]()
    var openList = [Cell]()
    var endCell: Cell?
    var shortestPath = [Cell]()
    
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
        closedList.append(grid.cells[0][0])
        endCell = grid.cells[grid.cells.count - 1][grid.cells[0].count - 1]
        
        solve(grid: grid, step: step)
    }
    
    func solve(grid: Grid, step: @escaping () -> Void) {
        
        guard let cellToProceedFrom = closedList.last, let endCell = endCell else {
            return
        }
        
        let nextCells = grid.openCells(neighbouring: cellToProceedFrom)
        
        if !nextCells.contains(endCell) {
            
            for cell in nextCells {
                
                if !closedList.contains(cell) {
                    score(cell, to: endCell)
                    cell.parent = cellToProceedFrom
                    openList.append(cell)
                }
            }
            
            openList.sort(by: { $0.fScore > $1.fScore })
            
            guard let highestScoreOpenCell = openList.popLast() else {
                return
            }
            closedList.append(highestScoreOpenCell)
            
            grid.activeSolveCells = closedList
            grid.highlightCells = openList
            
            step()
            
            delay(step: {
                self.solve(grid: grid, step: step)
            })
        }
        else {
            
            endCell.parent = cellToProceedFrom
            closedList.append(endCell)
            
            grid.activeSolveCells = nil
            
            step()
            
            delay(step: {
                self.findShortestPathBackwards(from: endCell, grid: grid, step: step)
            })
        }
    }
    
    func findShortestPathBackwards(from cell : Cell, grid: Grid, step: @escaping () -> Void) {
        
        shortestPath.append(cell)
        
        if let index = closedList.index(where: { $0 == cell.parent }) {
            
            let nextCell = closedList[index]
            
            if nextCell.xPos == 0 && nextCell.yPos == 0 {
                shortestPath.append(nextCell)
                
                state = .finished
                step()
            }
            else {
                findShortestPathBackwards(from: nextCell, grid: grid, step: step)
            }
        }
        grid.highlightCells = shortestPath
        
    }
}
