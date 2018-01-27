//
//  DeadEndFiller.swift
//  swiftmaze
//
//  Created by Kevin Sweeney on 14/09/2016.
//  Copyright © 2016 Kevin Sweeney. All rights reserved.
//

import Foundation

class DeadEndFiller: Algorithm {
    
    private struct State: AlgorithmState {
        enum Mode {
            case searching
            case fillingDeadEnds(Cell)
        }
        let startCell: Cell
        let endCell: Cell
        let columnIndex: Int
        let rowIndex: Int
        let direction: Direction
        let depth = 2
        let deadEndFound = false
        let mode: Mode
        
        func nextFillingDeadEndsState(cell: Cell) -> State {
            return State(startCell: startCell, endCell: endCell, columnIndex: columnIndex, rowIndex: rowIndex, direction: direction, mode: .fillingDeadEnds(cell))
        }
    }
    
    func begin(in grid: Grid) -> [AlgorithmState] {
        if grid.cells.isEmpty {
            grid.buildCells()
        }
        guard let first = grid.cells.first?.first, let last = grid.cells.last?.last else {
            return []
        }
        
        return [State(startCell: first, endCell: last, columnIndex: 0, rowIndex: 1, direction: .right, mode: .searching)]
    }
    
    func step(state: AlgorithmState, in grid: Grid) -> [AlgorithmState] {
        guard let state = state as? State else {
            return []
        }
        switch state.mode {
        case .searching:        return findDeadEnds(in: grid, state: state)
        case .fillingDeadEnds:  return fillDeadEnd(in: grid, state: state)
        }
    }
    
    private func findDeadEnds(in grid: Grid, state: State) -> [State] {
        guard state.columnIndex >= 0 && state.columnIndex < grid.size.width else {
            return []
        }
        
        for i in state.rowIndex..<grid.size.height {
            let cell = grid.cells[state.columnIndex][i]
            
            guard cell != state.endCell else {
                return []
            }
            
            let openCells = grid.openCells(neighbouring: cell)
            if openCells.count == 1 {
                grid.addLineBetweenCells(cell, and: openCells[0])
                return [State(startCell: state.startCell, endCell: state.endCell, columnIndex: state.columnIndex, rowIndex: i, direction: state.direction, mode: .fillingDeadEnds(openCells[0]))]
            }
        }
        
        return [State(startCell: state.startCell, endCell: state.endCell, columnIndex: state.direction == .right ? state.columnIndex + 1 : state.columnIndex - 1, rowIndex: 0, direction: state.direction, mode: .searching)]
    }
    
    private func fillDeadEnd(in grid: Grid, state: State) -> [State] {
        
        if case let .fillingDeadEnds(cell) = state.mode, cell != state.startCell, cell != state.endCell {
            let openCells = grid.openCells(neighbouring: cell)
            if openCells.count == 1 {
                grid.addLineBetweenCells(cell, and: openCells[0])
                return [state.nextFillingDeadEndsState(cell: openCells[0])]
            }
        }
        
        return [State(startCell: state.startCell, endCell: state.endCell, columnIndex: state.columnIndex, rowIndex: state.rowIndex, direction: state.direction, mode: .searching)]
    }
}

