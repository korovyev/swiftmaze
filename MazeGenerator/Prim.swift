//
//  Prim.swift
//  swiftmaze
//
//  Created by Kevin Sweeney on 16/09/2016.
//  Copyright © 2016 Kevin Sweeney. All rights reserved.
//

import Foundation

class Prim: Generator {
    var updateInterval: Float
    var state: GeneratorState
    var stop: Bool
    var activeCells = [Cell]()
    
    init(updateInterval: Float) {
        self.updateInterval = updateInterval
        state = .idle
        stop = false
    }
    
    func quit() {
        state = .finished
        stop = true
    }
    
    func generateMaze(in grid: Grid, step: @escaping () -> Void) {
        state = .generating
        grid.buildFrame()
        grid.buildInternalGrid()
        grid.buildCells()
        
        let initialX = Int(arc4random() % UInt32(grid.size.width))
        let initialY = Int(arc4random() % UInt32(grid.size.height))
        
        let initialCell = grid.cells[initialX][initialY]
        initialCell.visited = true
        
        activeCells.append(contentsOf: grid.neighbours(of: initialCell))
        
        step()
        
        performPrim(in: grid, step: step)
    }
    
    func performPrim(in grid: Grid, step: @escaping () -> Void) {
        
        activeCells.shuffled()
        
        guard let cell = activeCells.popLast() else {
            state = .finished
            step()
            return
        }
        
        let neighbours = grid.neighbours(of: cell).shuffle()
        if let mazeNeighbour = neighbours.filter({ $0.visited }).first {
            grid.removeLineBetween(cell, and: mazeNeighbour)
        }
        
        cell.visited = true
        
        let newActiveCells = neighbours.filter({ !$0.visited && !activeCells.contains($0) })
        
        activeCells.append(contentsOf: newActiveCells)
        
        grid.highlightCells = activeCells
        
        step()
        
        if stop {
            return
        }
        
        delay(step: {
            self.performPrim(in: grid, step: step)
        })
    }
}
