//
//  FloodFill.swift
//  swiftmaze
//
//  Created by Kevin Sweeney on 15/09/2016.
//  Copyright © 2016 Kevin Sweeney. All rights reserved.
//

import Foundation

class FloodFill: Algorithm {
    
    private struct State: AlgorithmState {
        let fillCells: [Cell]
    }
    
    func begin(in grid: Grid) -> [AlgorithmState] {
        
        if grid.cells.isEmpty {
            grid.buildCells()
        }
        
        guard let firstCell = grid.cells.first?.first else {
            return []
        }
        grid.highlightCells = [firstCell]
        return [State(fillCells: [firstCell])]
    }
    
    func step(state: AlgorithmState, in grid: Grid) -> [AlgorithmState] {
        guard let state = state as? State, !state.fillCells.isEmpty else {
            return []
        }
        
        let nextCells = fill(grid: grid, fillCells: state.fillCells)
        
        return [State(fillCells: nextCells)]
    }
    
    private func fill(grid: Grid, fillCells: [Cell]) -> [Cell] {
        
        var nextCells = [Cell]()
        
        fillCells.forEach({
            $0.solverVisited = true
            nextCells.append(contentsOf: grid.openCells(neighbouring: $0).filter({ !$0.solverVisited }))
        })
        
        grid.highlightCells?.append(contentsOf: nextCells)
        
        return nextCells
    }
}
