//
//  Wilson.swift
//  swiftmaze
//
//  Created by Kevin Sweeney on 12/09/2016.
//  Copyright © 2016 Kevin Sweeney. All rights reserved.
//

import Foundation

class Wilson: Algorithm {
    
    private class Walk {
        var originalCell: Cell
        var currentCell: Cell
        var cells = [Cell]()
        var previousDirection = Direction.none
        
        init(cell: Cell) {
            originalCell = cell
            currentCell = cell
        }
    }
    
    private struct State: AlgorithmState {
        enum Mode {
            case walking(Walk)
            case finishingWalk(Walk, Cell)
            case finishedWalk
        }
        let remainingCells: Set<Cell>
        let mode: Mode
    }
    
    func begin(in grid: Grid) -> [AlgorithmState] {
        grid.buildFrame()
        grid.buildInternalGrid()
        grid.buildCells()
        
        var cellsSet = Set<Cell>()
        grid.cells.forEach {
            cellsSet.formUnion($0)
        }
        
        guard let initialTarget = cellsSet.shuffle().first else {
            return []
        }
        
        grid.target = initialTarget
        initialTarget.visited = true
        cellsSet.remove(initialTarget)
        
        return [State(remainingCells: cellsSet, mode: .finishedWalk)]
    }
    
    func step(state: AlgorithmState, in grid: Grid) -> [AlgorithmState] {
        guard let state = state as? State else {
            return []
        }
        
        switch state.mode {
        case .walking(let walk):                        return randomStep(in: grid, walk: walk, state: state)
        case .finishingWalk(let walk, let walkStep):    return finish(walk: walk, step: walkStep, in: grid, state: state)
        case .finishedWalk:                             return startNewWalk(in: grid, state: state)
        }
    }
    
    private func randomStep(in grid: Grid, walk: Walk, state: State) -> [State] {
        
        let directions = walk.currentCell.directionsToTest(inside: grid.size).filter({ $0 != walk.previousDirection.opposite() }).shuffle()
        
        guard let direction = directions.first else {
            return []
        }
        
        if let neighbour = grid.neighbourCell(of: walk.currentCell, in: direction) {
            walk.currentCell.direction = direction
            walk.cells.append(walk.currentCell)
            
            grid.highlightCells = walk.cells
            grid.secondaryHighlightCells = [neighbour]
            
            if neighbour.visited {
                
                walk.cells.append(neighbour)
                
                return [State(remainingCells: state.remainingCells, mode: .finishingWalk(walk, walk.originalCell))]
            }
            else {
                walk.currentCell = neighbour
                walk.previousDirection = direction
                
                return [State(remainingCells: state.remainingCells, mode: .walking(walk))]
            }
        }
        
        return []
    }
    
    private func finish(walk: Walk, step: Cell, in grid: Grid, state: State) -> [State] {
        
        step.visited = true
        
        guard let nextStep = grid.neighbourCell(of: step, in: step.direction) else {
            return []
        }
        
        grid.removeLineBetween(step, and: nextStep)
        
        if nextStep.visited {
            grid.highlightCells = nil
            grid.secondaryHighlightCells = nil
            grid.target = nil
            
            return [State(remainingCells: state.remainingCells, mode: .finishedWalk)]
        }
        else {
            nextStep.visited = true
            var remainingCells = state.remainingCells
            remainingCells.remove(nextStep)
            return [State(remainingCells: remainingCells, mode: .finishingWalk(walk, nextStep))]
        }
    }
    
    private func startNewWalk(in grid: Grid, state: State) -> [State] {
        
        var remainingCells = state.remainingCells
        
        guard let originalCell = remainingCells.shuffle().first else {
            return []
        }
        
        remainingCells.remove(originalCell)
        
        let walk = Walk(cell: originalCell)
        
        return [State(remainingCells: remainingCells, mode: .walking(walk))]
    }
}
