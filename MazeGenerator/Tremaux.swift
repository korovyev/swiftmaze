//
//  Tremaux.swift
//  swiftmaze
//
//  Created by Kevin Sweeney on 14/09/2016.
//  Copyright © 2016 Kevin Sweeney. All rights reserved.
//

import Foundation

class Tremaux: Algorithm {
    
    private struct State: AlgorithmState {
        let activeCells: [Cell]
        let endCell: Cell
        let activeJunctions: [Cell]
    }
    
    func begin(in grid: Grid) -> [AlgorithmState] {
        if grid.cells.isEmpty {
            grid.buildCells()
        }
        guard let firstCell = grid.cells.first?.first, let endCell = grid.cells.last?.last else {
            return []
        }
        let beginState = State(activeCells: [firstCell], endCell: endCell, activeJunctions: [])
        return [beginState]
    }
    
    func step(state: AlgorithmState, in grid: Grid) -> [AlgorithmState] {
        guard let state = state as? State else {
            return []
        }
        return solve(grid: grid, state: state)
    }
    
    
    
    private func solve(grid: Grid, state: State) -> [State] {
        
        guard state.activeCells.count > 0, let cellToProceedFrom = state.activeCells.last else {
            return []
        }
        
        var activeJunctions = state.activeJunctions
        var activeCells = state.activeCells
        
        cellToProceedFrom.solverVisited = true
        var nextCells = unvisitedTremauxCells(neighbouring: cellToProceedFrom, in: grid)
        
        if !nextCells.contains(state.endCell) {
            
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
                    cell.score(to: state.endCell)
                }
                
                nextCells.sort(by: { $0.fScore > $1.fScore })
                activeCells.append(nextCells.popLast()!)
            }
            
            grid.highlightCells = activeCells
            
            return [State(activeCells: activeCells, endCell: state.endCell, activeJunctions: activeJunctions)]
        }
        else {
            activeCells.append(state.endCell)
            grid.highlightCells = activeCells
            
            return []
        }
    }
    
    func unvisitedTremauxCells(neighbouring cell: Cell, in grid: Grid) -> [Cell] {
        let nextCells = grid.openCells(neighbouring: cell)
        
        return nextCells.filter({ return !$0.solverVisited })
    }
}
