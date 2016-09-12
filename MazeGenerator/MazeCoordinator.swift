//
//  MazeCoordinator.swift
//  swiftmaze
//
//  Created by Kevin Sweeney on 08/09/2016.
//  Copyright © 2016 Kevin Sweeney. All rights reserved.
//

import Foundation

class MazeCoordinator {
    weak var maze: Maze?
    var grid: Grid
    var cellSize: CGFloat = 4
    
    init(maze: Maze) {
        self.maze = maze
        
        grid = Grid(size: Size(width: Int(maze.frame.size.width / cellSize), height: Int(maze.frame.size.height / cellSize)))
    }
    
    func start() {
//        let generator = RecursiveDivision(updateInterval: 0.01)
//        let generator = Backtracker(updateInterval: 0.01)
//        let generator = Kruskal(updateInterval: 0.1)
        let generator = Eller(updateInterval: 0.1)
        
        generator.generateMaze(in: grid, step: { [weak self] in
            
            if let weakSelf = self {
                weakSelf.maze?.update(weakSelf.grid)
            }
        })
    }
    
    func fullGrid() {
        grid.buildFrame()
        grid.buildInternalGrid()
    }
}
