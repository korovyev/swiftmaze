//
//  MazeCoordinator.swift
//  swiftmaze
//
//  Created by Kevin Sweeney on 08/09/2016.
//  Copyright © 2016 Kevin Sweeney. All rights reserved.
//

import Foundation

struct MazeSetup {
    var algorithm: GenerationAlgorithm
    var solver: SolvingAlgorithm
    var size: Size
}

class MazeCoordinator {
    weak var maze: Maze?
    var grid: Grid
    var generator: Generator
    var solver: Solver?
    var setup: MazeSetup
    
    init(maze: Maze, setup: MazeSetup) {
        self.maze = maze
        self.setup = setup
        
        grid = Grid(size: setup.size)
        
        switch setup.algorithm {
        case.recursiveDivision:
            generator = RecursiveDivision(updateInterval: 0.01)
        case .backtracker:
            generator = Backtracker(updateInterval: 0.01)
        case .kruskal:
            generator = Kruskal(updateInterval: 0.01)
        case .eller:
            generator = Eller(updateInterval: 0.01)
        case .wilson:
            generator = Wilson(updateInterval: 0.01)
        }
        
        switch setup.solver {
        case .tremaux:
            solver = Tremaux(updateInterval: 0.01)
        case .aStar:
            solver = AStar(updateInterval: 0.01)
        case .deadEndFilling:
            solver = DeadEndFiller(updateInterval: 0.01)
        case .floodFill:
            solver = FloodFill(updateInterval: 0.01)
        case .none:
            solver = nil
        }
    }
    
    func start() {
        generator.generateMaze(in: grid, step: { [weak self] in
            
            if let weakSelf = self {
                weakSelf.maze?.update(weakSelf.grid)
                
                if weakSelf.generator.state == .finished {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: {
                        weakSelf.solve()
                    })
                }
            }
        })
    }
    
    func solve() {
        
        guard let solver = solver else {
            return
        }
        
        if grid.cells.isEmpty {
            grid.buildCells()
        }
        solver.solveMaze(in: grid, step: { [weak self] in
            
            if let weakSelf = self {
                weakSelf.maze?.update(weakSelf.grid)
            }
        })
    }
    
    func dropMaze() {
        generator.quit()
        solver?.quit()
        maze?.update(nil)
    }
}
