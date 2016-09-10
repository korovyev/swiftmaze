//
//  Backtracker.swift
//  swiftmaze
//
//  Created by Kevin Sweeney on 09/09/2016.
//  Copyright © 2016 Kevin Sweeney. All rights reserved.
//

import Foundation

class Backtracker: Generator {
    var updateInterval: Float
    var state: GeneratorState
    var cellIndex = 0
    var visitedCells = [Cell]()
    
    init(updateInterval: Float) {
        self.updateInterval = updateInterval
        state = .generating
    }
    
    func generateMaze(in grid: Grid, step: @escaping () -> Void) {
        grid.buildFrame()
        grid.buildInternalGrid()
        grid.buildCells()
        
        guard let first = grid.cells?[0][0] else {
            return
        }
        
        grid.cells?[0][0].visited = true
        visitedCells.append((grid.cells?[0][0])!)
        
        step()
        
        delay(step: {
            self.nextUnvisitedCell(to: first, inside: grid, step: step)
        })
    }
    
    func nextUnvisitedCell(to cell: Cell, inside grid: Grid, step: @escaping () -> Void) {
        
        var nextCell: Cell?
        
        let directionsToTest = cell.directionsToTest(inside: grid.size).shuffle()
        
        
        for direction in directionsToTest {
            
            if let neighbour = grid.neighbourCell(of: cell, in: direction), !neighbour.visited {
                grid.removeLineBetween(cell, and: neighbour)
                nextCell = neighbour
                break
            }
        }
        
        step()
        
        if let nextCell = nextCell {
            grid.cells?[nextCell.xPos][nextCell.yPos].visited = true
            
            
            visitedCells.append(nextCell)
            cellIndex = visitedCells.count - 1
            
            delay(step: {
                self.nextUnvisitedCell(to: nextCell, inside: grid, step: step)
            })
        }
        else {
            visitedCells.removeLast()
            
            cellIndex -= 1
            if cellIndex >= 0 {
                nextUnvisitedCell(to: visitedCells[cellIndex], inside: grid, step: step)
            }
            else {
                state = .finished
                step()
            }
        }
    }
}
