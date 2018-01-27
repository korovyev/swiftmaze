//
//  Eller.swift
//  swiftmaze
//
//  Created by Kevin Sweeney on 11/09/2016.
//  Copyright © 2016 Kevin Sweeney. All rights reserved.
//

import Foundation

class Eller: Algorithm {
    
    private struct State: AlgorithmState {
        enum Mode {
            case horizontal
            case vertical
        }
        let mode: Mode
        let index: Int
        let state: EllerState
    }
    
    private class EllerState {
        typealias SetOfCell = [Cell: String]
        typealias CellsInSet = [String: [Cell]]
        
        var setOfCell: SetOfCell
        var cellsInSet: CellsInSet
        let columnIndex: Int
        var horizontalDoorIndices: [Int]
        
        init(columnIndex: Int) {
            self.columnIndex = columnIndex
            setOfCell = SetOfCell()
            cellsInSet = CellsInSet()
            horizontalDoorIndices = []
        }
        
        func cellsInSameSet(_ cell1: Cell, _ cell2: Cell) -> Bool {
            return setOfCell[cell1] == setOfCell[cell2]
        }
        
        func add(cell: Cell, to set: String) {
            setOfCell[cell] = set
            
            if cellsInSet[set] != nil {
                cellsInSet[set]!.append(cell)
            }
            else {
                cellsInSet[set] = [cell]
            }
        }
        
        func merge(set1: String, set2: String) {
            
            guard let set2Cells = cellsInSet[set2] else {
                return
            }
            
            for cell in set2Cells {
                add(cell: cell, to: set1)
            }
            
            cellsInSet.removeValue(forKey: set2)
        }
        
        func addColumnCellsToSets(column: [Cell]) {
            for cell in column {
                if setOfCell[cell] == nil {
                    let key = "\(cell.xPos)\(cell.yPos)"
                    setOfCell[cell] = key
                    cellsInSet[key] = [cell]
                }
            }
        }
        
        func sets(in column: [Cell]) -> CellsInSet {
            
            var sets = CellsInSet()
            
            for cell in column {
                
                if let set = setOfCell[cell] {
                    if sets[set] == nil {
                        sets[set] = [cell]
                    }
                    else {
                        sets[set]!.append(cell)
                    }
                }
            }
            
            return sets
        }
    }
    
    func begin(in grid: Grid) -> [AlgorithmState] {
        grid.buildInternalGrid()
        grid.buildFrame()
        grid.buildCells()
        
        guard !grid.cells.isEmpty else {
            return []
        }
        let ellerState = EllerState(columnIndex: 0)
        ellerState.addColumnCellsToSets(column: grid.cells[0])
        let state = State(mode: .vertical, index: 0, state: ellerState)
        
        return [state]
    }
    
    func step(state: AlgorithmState, in grid: Grid) -> [AlgorithmState] {
        guard let state = state as? State else {
            return []
        }
        let newState: [State]
        switch state.mode {
        case .vertical:     newState = verticalStep(state: state, grid: grid)
        case .horizontal:   newState = horizontalStep(state: state, grid: grid)
        }
        
        return newState
    }
    
    private func verticalStep(state: State, grid: Grid) -> [State] {
        
        let column = grid.cells[state.state.columnIndex]
        
        if state.state.columnIndex + 1 < grid.size.width {
            openVerticalDoor(in: column, at: state.index, in: grid, state: state.state)
            
            let mode: State.Mode
            let verticalIndex: Int
            let nextState: EllerState
            if state.index + 2 < grid.size.height {
                mode = .vertical
                verticalIndex = state.index + 1
                nextState = state.state
            }
            else {
                mode = .horizontal
                // switching to opening horiztonal doors, create new state
                nextState = computeIndicesForHorizontalDoors(from: grid.cells[state.state.columnIndex], in: grid, state: state.state)
                verticalIndex = nextState.horizontalDoorIndices.count - 1
            }
            return [State(mode: mode, index: verticalIndex, state: nextState)]
        }
        else if state.state.columnIndex + 1 == grid.size.width {
            openVerticalDoor(in: column, at: state.index, in: grid, state: state.state, finished: true)
            
            if state.index + 2 < grid.size.height {
                return [State(mode:. vertical, index: state.index + 1, state: state.state)]
            }
        }
        
        return []
    }
    
    private func horizontalStep(state: State, grid: Grid) -> [State] {
        
        if state.index >= 0 {
            openHorizontalDoor(from: grid.cells[state.state.columnIndex], into: grid.cells[state.state.columnIndex], at: state.state.horizontalDoorIndices[state.index], in: grid)
            
            return [State(mode: .horizontal, index: state.index - 1, state: state.state)]
        }
        else {
            return [State(mode: .vertical, index: 0, state: state.state)]
        }
    }
    
    private func openVerticalDoor(in column: [Cell], at index: Int, in grid: Grid, state: EllerState, finished: Bool = false) {
        let cell1 = column[index]
        let cell2 = column[index + 1]
        let cellsInSameSet = state.cellsInSameSet(cell1, cell2)
        let joinSets = finished || arc4random() % 2 == 0
        
        if !cellsInSameSet && joinSets {
            if let set1 = state.setOfCell[cell1], let set2 = state.setOfCell[cell2] {
                state.merge(set1: set1, set2: set2)
            }
            
            grid.removeLineBetween(cell1, and: cell2)
        }
    }
    
    private func openHorizontalDoor(from column: [Cell], into nextColumn: [Cell], at index: Int, in grid: Grid) {
        let cell1 = column[index]
        let cell2 = nextColumn[index]
        grid.removeLineBetween(cell1, and: cell2)
    }
    
    private func computeIndicesForHorizontalDoors(from column: [Cell], in grid: Grid, state: EllerState) -> EllerState {
        let nextState = EllerState(columnIndex: state.columnIndex + 1)
        let columnSets = state.sets(in: column)
        
        var indices = [Int]()
        
        for cellArray in columnSets.values {
            
            var numDoors = 1
            let randomlySortedCells = cellArray.shuffle()
            
            if cellArray.count > 1 {
                numDoors = 1 + (Int(arc4random_uniform(UInt32(cellArray.count))))
            }
            
            for index in 0..<numDoors {
                let cell = randomlySortedCells[index]
                
                if let nextCell = grid.cellToTheRight(of: cell), let currentSet = state.setOfCell[cell], let doorIndex = column.index(of: cell) {
                    
                    nextState.add(cell: nextCell, to: currentSet)
                    
                    indices.append(doorIndex)
                }
            }
        }
        
        indices.sort()
        
        nextState.addColumnCellsToSets(column: grid.cells[nextState.columnIndex])
        nextState.horizontalDoorIndices = indices
        
        return nextState
    }
}
