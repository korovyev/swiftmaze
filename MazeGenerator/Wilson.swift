//
//  Wilson.swift
//  swiftmaze
//
//  Created by Kevin Sweeney on 12/09/2016.
//  Copyright © 2016 Kevin Sweeney. All rights reserved.
//

import Foundation

class Walk {
    var originalCell: Cell
    var currentCell: Cell
    var cells = [Cell]()
    var previousDirection = Direction.none
    
    init(cell: Cell) {
        originalCell = cell
        currentCell = cell
    }
}

class Wilson: Generator {
    var updateInterval: Float
    var state: GeneratorState
    var stop: Bool
    var remainingCellsSet = Set<Cell>()
    
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
        
        for array in grid.cells {
            remainingCellsSet.formUnion(array)
        }
        
        if let mazeStart = remainingCellsSet.shuffle().first {
            grid.target = mazeStart
            mazeStart.visited = true
            remainingCellsSet.remove(mazeStart)
            
            startNewWalk(in: grid, step: step)
        }
    }
    
    func randomStep(walk: Walk, in grid: Grid, step: @escaping () -> Void) {
        let directions = walk.currentCell.directionsToTest(inside: grid.size).filter({ $0 != walk.previousDirection.opposite() }).shuffle()
        
        guard let direction = directions.first else {
            return
        }
        
        if let neighbour = grid.neighbourCell(of: walk.currentCell, in: direction) {
            walk.currentCell.direction = direction
            walk.cells.append(walk.currentCell)
            
            grid.highlightCells = walk.cells
            grid.secondaryHighlightCells = [neighbour]
            
            if neighbour.visited {
                
                walk.cells.append(neighbour)
                
                delay(step: {
                    self.finish(walk: walk, in: grid, step: step)
                })
                
            }
            else {
                walk.currentCell = neighbour
                walk.previousDirection = direction
                
                delay(step: {
                    self.randomStep(walk: walk, in: grid, step: step)
                })
            }
        }
        
        step()
    }
    
    func finish(walk: Walk, in grid: Grid, step: @escaping () -> Void) {
        var finishedWalk = false
        let firstCell = walk.originalCell
        firstCell.visited = true
        
        
        var currentCell = firstCell
        
        while !finishedWalk {
            
            guard let nextCell = grid.neighbourCell(of: currentCell, in: currentCell.direction) else {
                break
            }
            
            grid.removeLineBetween(currentCell, and: nextCell)
            
            if nextCell.visited {
                finishedWalk = true
            }
            else {
                nextCell.visited = true
                remainingCellsSet.remove(nextCell)
                currentCell = nextCell
            }
        }
        
        grid.highlightCells = nil
        grid.secondaryHighlightCells = nil
        grid.target = nil
        
        if stop {
            return
        }
        
        if remainingCellsSet.count > 0 {
            startNewWalk(in: grid, step: step)
        }
        else {
            state = .finished
            step()
        }
    }
    
    func startNewWalk(in grid: Grid, step: @escaping () -> Void) {
        
        let shuffledRemainingCells = remainingCellsSet.shuffle()
        
        guard let originalCell = shuffledRemainingCells.first else {
            return
        }
        
        remainingCellsSet.remove(originalCell)
        
        let walk = Walk(cell: originalCell)
        
        randomStep(walk: walk, in: grid, step: step)
    }
}
