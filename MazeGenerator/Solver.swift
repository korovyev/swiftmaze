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
    
    var solver: Algorithm? {
        switch self {
        case .tremaux:      return Tremaux()
        case .aStar:        return AStar()
        case .deadEndFilling:   return DeadEndFiller()
        case .floodFill:        return FloodFill()
        case .none:             return nil
        }
    }
}

extension Cell {
    
    func score(to endCell: Cell) {
        
        let maxX = endCell.xPos
        let maxY = endCell.yPos
        
        let xDistance = xPos > maxX ? xPos - maxX : maxX - xPos
        let yDistance = yPos > maxY ? yPos - maxY : maxY - yPos
        
        let gScore = 1
        let hScore = xDistance + yDistance
        
        fScore = gScore + hScore
    }
}
