//
//  Solver.swift
//  swiftmaze
//
//  Created by Kevin Sweeney on 14/09/2016.
//  Copyright © 2016 Kevin Sweeney. All rights reserved.
//

import Foundation

enum SolvingAlgorithm: String {
    case tremaux = "Tremaux"
    case aStar = "A *"
    case deadEndFilling = "Dead End Filling"
    case floodFill = "Flood Fill"
    case none = "None"
}

enum SolverState {
    case idle
    case solving
    case finished
}

protocol Solver {
    var state: SolverState { get }
    var updateInterval: Float { get }
    var stop: Bool { get }
    
    func solveMaze(in grid: Grid, step: @escaping () -> Void)
    func quit()
}

extension Solver {
    func delay(step:  @escaping () -> Void) {
        DispatchQueue.main.asyncAfter(deadline: .now() + Double(updateInterval), execute: step)
    }
    
    func score(_ cell : Cell, to endCell: Cell) {
        
        let maxX = endCell.xPos
        let maxY = endCell.yPos
        
        let xDistance = cell.xPos > maxX ? cell.xPos - maxX : maxX - cell.xPos
        let yDistance = cell.yPos > maxY ? cell.yPos - maxY : maxY - cell.yPos
        
        let gScore = 1
        let hScore = xDistance + yDistance
        
        cell.fScore = gScore + hScore
    }
}
