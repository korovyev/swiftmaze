//
//  Kruskal.swift
//  swiftmaze
//
//  Created by Kevin Sweeney on 11/09/2016.
//  Copyright © 2016 Kevin Sweeney. All rights reserved.
//

import Foundation

class Kruskal: Algorithm {
    
    private struct State: AlgorithmState {
        let edges: [Line]
        let trees: [[Tree<Cell>]]
    }

    func begin(in grid: Grid) -> [AlgorithmState] {
        grid.buildInternalGrid()
        grid.buildCells()
        
        var edges = [Line]()
        
        edges.append(contentsOf: grid.verticalLines)
        edges.append(contentsOf: grid.horizontalLines)
        edges.shuffled()
        
        var trees = [[Tree<Cell>]]()
        
        grid.cells.forEach({
            
            var columnTrees = [Tree<Cell>]()
            
            $0.forEach({
                columnTrees.append(Tree(element: $0))
            })
            
            trees.append(columnTrees)
        })
        
        return [State(edges: edges, trees: trees)]
    }
    
    func step(state: AlgorithmState, in grid: Grid) -> [AlgorithmState] {
        guard let state = state as? State else {
            return []
        }
        var edges = state.edges
        guard let edge = edges.popLast() else {
            return []
        }
        
        let newTrees = remove(edge: edge, in: grid, trees: state.trees)
        return [State(edges: edges, trees: newTrees)]
    }
    
    func remove(edge: Line, in grid: Grid, trees: [[Tree<Cell>]]) -> [[Tree<Cell>]] {
        
        let cells = grid.cellsEitherSide(of: edge)
        
        if let cell1 = cells.0, let cell2 = cells.1 {
            let cell1Tree = trees[cell1.xPos][cell1.yPos]
            let cell2Tree = trees[cell2.xPos][cell2.yPos]
            
            let correctCell1 = cell1Tree.element == cell1
            let correctCell2 = cell2Tree.element == cell2
            
            if correctCell1 && correctCell2 && !cell1Tree.connected(to: cell2Tree) {
                cell1Tree.connect(to: cell2Tree)
                
                grid.removeLineBetween(cell1, and: cell2)
            }
        }
        
        return trees
    }
}
