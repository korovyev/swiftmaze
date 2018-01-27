//
//  AStar.swift
//  swiftmaze
//
//  Created by Kevin Sweeney on 14/09/2016.
//  Copyright © 2016 Kevin Sweeney. All rights reserved.
//

import Foundation

class AStar: Algorithm {
    
    private struct State: AlgorithmState {
        enum Mode {
            case searching
            case solving
        }
        let closedList: [Cell]
        let openList: [Cell]
        let endCell: Cell
        let activeSolveCell: Cell?
        let mode: Mode
    }
    
    func begin(in grid: Grid) -> [AlgorithmState] {
        if grid.cells.isEmpty {
            grid.buildCells()
        }
        guard let firstCell = grid.cells.first?.first, let endCell = grid.cells.last?.last else {
            return []
        }
        return [State(closedList: [firstCell], openList: [], endCell: endCell, activeSolveCell: nil, mode: .searching)]
    }
    
    func step(state: AlgorithmState, in grid: Grid) -> [AlgorithmState] {
        guard let state = state as? State else {
            return []
        }
        
        switch state.mode {
        case .searching: return search(grid: grid, state: state)
        case .solving:  return solve(grid: grid, state: state)
        }
    }
    
    private func search(grid: Grid, state: State) -> [State] {
        
        guard let cellToProceedFrom = state.closedList.last else {
            return []
        }
        
        var openList = state.openList
        var closedList = state.closedList
        let mode: State.Mode
        
        let nextCells = grid.openCells(neighbouring: cellToProceedFrom)
        
        if !nextCells.contains(state.endCell) {
            
            for cell in nextCells {
                
                if !closedList.contains(cell) {
                    cell.score(to: state.endCell)
                    cell.parent = cellToProceedFrom
                    openList.append(cell)
                }
            }
            
            openList.sort(by: { $0.fScore > $1.fScore })
            
            guard let highestScoreOpenCell = openList.popLast() else {
                return []
            }
            closedList.append(highestScoreOpenCell)
            
            grid.secondaryHighlightCells = openList
            grid.highlightCells = closedList
            
            mode = .searching
        }
        else {
            mode = .solving
            
            state.endCell.parent = cellToProceedFrom
            closedList.append(state.endCell)
            
            grid.secondaryHighlightCells = nil
            grid.highlightCells = []
        }
        
        return [State(closedList: closedList, openList: openList, endCell: state.endCell, activeSolveCell: state.endCell, mode: mode)]
    }
    
    private func solve(grid: Grid, state: State) -> [State] {
        
        guard let activeSolveCell = state.activeSolveCell else {
            return []
        }
        grid.highlightCells?.append(activeSolveCell)
        
        guard let parent = activeSolveCell.parent else {
            return []
        }
        
        if parent.xPos == 0 && parent.yPos == 0 {
            grid.highlightCells?.append(parent)
            return []
        }
        else {
            return [State(closedList: state.closedList, openList: state.openList, endCell: state.endCell, activeSolveCell: parent, mode: .solving)]
        }
        
    }
}
