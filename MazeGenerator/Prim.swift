//
//  Prim.swift
//  swiftmaze
//
//  Created by Kevin Sweeney on 16/09/2016.
//  Copyright © 2016 Kevin Sweeney. All rights reserved.
//

import Foundation

class Prim: Algorithm {
    
    private struct State: AlgorithmState {
        let cells: [Cell]
    }
    
    func begin(in grid: Grid) -> [AlgorithmState] {
        grid.buildFrame()
        grid.buildInternalGrid()
        grid.buildCells()
        
        let initialX = Int(arc4random() % UInt32(grid.size.width))
        let initialY = Int(arc4random() % UInt32(grid.size.height))
        
        let initialCell = grid.cells[initialX][initialY]
        initialCell.visited = true
        
        return [State(cells: grid.neighbours(of: initialCell))]
    }
    
    func step(state: AlgorithmState, in grid: Grid) -> [AlgorithmState] {
        guard let state = state as? State else {
            return []
        }
        
        return performPrim(in: grid, state: state)
    }
    
    private func performPrim(in grid: Grid, state: State) -> [State] {
        
        var activeCells = state.cells.shuffle()
        
        guard let cell = activeCells.popLast() else {
            return []
        }
        
        let neighbours = grid.neighbours(of: cell).shuffle()
        if let mazeNeighbour = neighbours.filter({ $0.visited }).first {
            grid.removeLineBetween(cell, and: mazeNeighbour)
        }
        
        cell.visited = true
        
        let newActiveCells = neighbours.filter({ !$0.visited && !activeCells.contains($0) })
        
        activeCells.append(contentsOf: newActiveCells)
        
        grid.highlightCells = activeCells
        
        return [State(cells: activeCells)]
    }
}
