//
//  Eller.swift
//  swiftmaze
//
//  Created by Kevin Sweeney on 11/09/2016.
//  Copyright © 2016 Kevin Sweeney. All rights reserved.
//

import Foundation

class EllerState {
    typealias SetOfCell = [Cell: String]
    typealias CellsInSet = [String: [Cell]]
    
    var setOfCell = SetOfCell()
    var cellsInSet = CellsInSet()
    
    func cellsInSameSet(cell1: Cell, cell2: Cell) -> Bool {
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

class Eller: Generator {
    
    var updateInterval: Float
    var state: GeneratorState
    
    init(updateInterval: Float) {
        self.updateInterval = updateInterval
        state = .generating
    }
    
    func generateMaze(in grid: Grid, step: @escaping () -> Void) {
        grid.buildInternalGrid()
        grid.buildFrame()
        grid.buildCells()
        
        step()
        
        guard let firstColumn = grid.cells?[0] else {
            return
        }
        
        let startState = EllerState()
        startState.addColumnCellsToSets(column: firstColumn)
        
        performEller(with: startState, columnIndex: 0, grid: grid, step: step)
    }
    
    func performEller(with state: EllerState, columnIndex: Int, grid: Grid, step: @escaping () -> Void) {
        guard let cells = grid.cells else {
            return
        }
        
        if columnIndex + 1 < cells.count {
            
            let column = cells[columnIndex]
            
            openVerticalDoors(in: column, grid: grid, state: state)
            let nextState = openHorizontalDoors(in: column, into: cells[columnIndex + 1], in: grid, state: state)
            
            step()
            
            delay(step: {
                self.performEller(with: nextState, columnIndex: columnIndex + 1, grid: grid, step: step)
            })
        }
        else if columnIndex + 1 == cells.count {
            
            let column = cells[columnIndex]
            
            state.addColumnCellsToSets(column: column)
            
            openVerticalDoors(in: cells[columnIndex], grid: grid, state: state, finish: true)
            
            self.state = .finished
            step()
        }
    }
    
    func openVerticalDoors(in column: [Cell], grid: Grid, state: EllerState, finish: Bool = false) {
        
        if column.count < 2 {
            return
        }
        
        for index in 0..<column.count - 1 {
            let cell1 = column[index]
            let cell2 = column[index + 1]
            
            let joinSets = finish || arc4random() % 2 == 0
            
            if !state.cellsInSameSet(cell1: cell1, cell2: cell2) && joinSets {
                
                if let set1 = state.setOfCell[cell1], let set2 = state.setOfCell[cell2] {
                    state.merge(set1: set1, set2: set2)
                }
                
                grid.removeLineBetween(cell1, and: cell2)
            }
        }
    }
    
    func openHorizontalDoors(in column: [Cell], into nextColumn: [Cell], in grid: Grid, state: EllerState) -> EllerState {
        
        let nextState = EllerState()
        let columnSets = state.sets(in: column)
        
        for cellArray in columnSets.values {
            
            var numDoors = 1
            let randomlySortedCells = cellArray.shuffle()
            
            if cellArray.count > 1 {
                numDoors = 1 + (Int(arc4random_uniform(UInt32(cellArray.count))))
            }
            
            for index in 0..<numDoors {
                let cell = randomlySortedCells[index]
                
                if let nextCell = grid.cellToTheRight(of: cell), let currentSet = state.setOfCell[cell] {
                    grid.removeLineBetween(cell, and: nextCell)
                    
                    nextState.add(cell: nextCell, to: currentSet)
                }
            }
        }
        
        nextState.addColumnCellsToSets(column: nextColumn)
        
        return nextState
    }
}
