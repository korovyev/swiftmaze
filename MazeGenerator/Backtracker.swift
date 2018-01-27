//
//  Backtracker.swift
//  swiftmaze
//
//  Created by Kevin Sweeney on 09/09/2016.
//  Copyright © 2016 Kevin Sweeney. All rights reserved.
//

import Foundation

class Backtracker: Algorithm {
    
    private struct State: AlgorithmState {
        var cell: Cell
    }
    
    func begin(in grid: Grid) -> [AlgorithmState] {
        grid.buildFrame()
        grid.buildInternalGrid()
        grid.buildCells()
        
        guard let first = grid.cellAt(0, 0) else {
            return []
        }
        first.visited = true
        
        return [State(cell: first)]
    }
    
    func step(state: AlgorithmState, in grid: Grid) -> [AlgorithmState] {
        guard let state = state as? Backtracker.State, let nextCell = nextUnvisitedCell(to: state.cell, in: grid) else {
            return []
        }
        
        return [state, State(cell: nextCell)]
    }
    
    private func nextUnvisitedCell(to cell: Cell, in grid: Grid) -> Cell? {
        
        grid.target = cell
        
        var nextCell: Cell?
        let directionsToTest = cell.directionsToTest(inside: grid.size).shuffle()
        
        for direction in directionsToTest {
            
            if let neighbour = grid.neighbourCell(of: cell, in: direction), !neighbour.visited {
                grid.removeLineBetween(cell, and: neighbour)
                nextCell = neighbour
                nextCell?.visited = true
                break
            }
        }
        
        return nextCell
    }
}
