//
//  Kruskal.swift
//  swiftmaze
//
//  Created by Kevin Sweeney on 11/09/2016.
//  Copyright © 2016 Kevin Sweeney. All rights reserved.
//

import Foundation

class Kruskal: Generator {
    var updateInterval: Float
    var state: GeneratorState
    var stop: Bool
    var trees = [[Tree<Cell>]]()
    var edges = [Line]()
    
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
        grid.buildInternalGrid()
        
        edges.append(contentsOf: grid.verticalLines)
        edges.append(contentsOf: grid.horizontalLines)
        
        grid.buildFrame()
        grid.buildCells()
        
        step()
        
        for cellArray in grid.cells {
            
            var cellTrees = [Tree<Cell>]()
            
            for cell in cellArray {
                let tree = Tree(element: cell)
                cellTrees.append(tree)
            }
            trees.append(cellTrees)
        }
        
        edges.shuffled()
        
        removeEdge(in: grid, step: step)
    }
    
    func removeEdge(in grid: Grid, step: @escaping () -> Void) {
        guard let edge = edges.popLast() else {
            state = .finished
            step()
            return
        }
        
        let cells = grid.cellsEitherSide(of: edge)
        
        if let cell1 = cells.0, let cell2 = cells.1 {
            let cell1Tree = trees[cell1.xPos][cell1.yPos]
            let cell2Tree = trees[cell2.xPos][cell2.yPos]
            
            let correctCell1 = cell1Tree.element == cell1
            let correctCell2 = cell2Tree.element == cell2
            
            if correctCell1 && correctCell2 && !cell1Tree.connected(to: cell2Tree) {
                cell1Tree.connect(to: cell2Tree)
                
                grid.removeLineBetween(cell1, and: cell2)
                
                step()
            }
            
            if stop {
                return
            }
            
            delay(step: {
                self.removeEdge(in: grid, step: step)
            })
        }
    }
}
