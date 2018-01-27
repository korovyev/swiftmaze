//
//  MazeCoordinator.swift
//  swiftmaze
//
//  Created by Kevin Sweeney on 08/09/2016.
//  Copyright © 2016 Kevin Sweeney. All rights reserved.
//

import Foundation

enum MazeGenerationStatus {
    case idle
    case generating
    case solving
    case finished
}

class MazeCoordinator {
    weak var maze: Maze?
    var grid: Grid
    let generator: Algorithm
    let solver: Algorithm?
    var activeAlgorithm: Algorithm?
    var setup: MazeSetup
    var timer: RepeatingTimer?
    var stack: [AlgorithmState]
    var status: MazeGenerationStatus
    
    init(maze: Maze, setup: MazeSetup) {
        maze.setup = setup
        self.maze = maze
        self.setup = setup
        stack = []
        status = .idle
        
        grid = Grid(size: setup.size)
        
        generator = setup.generator.generator
        solver = setup.solver.solver
        activeAlgorithm = generator
    }
    
    func start() {
        
        status = .generating
        stack.append(contentsOf: generator.begin(in: grid))
        maze?.update(grid)
        
        timer = RepeatingTimer(interval: .milliseconds(5))
        timer?.eventHandler = { [weak self] in
            self?.step()
        }
        timer?.resume()
    }
    
    func step() {
        guard let algorithm = activeAlgorithm else {
            return
        }
        if let state = stack.popLast() {
            stack.append(contentsOf: algorithm.step(state: state, in: grid))
        }
        else if let solver = solver, status == .generating {
            status = .solving
            activeAlgorithm = solver
            stack.append(contentsOf: solver.begin(in: grid))
            grid.target = nil
        }
        else {
            status = .finished
            timer?.suspend()
        }
        
        DispatchQueue.main.async {
            self.maze?.update(self.grid)
        }
    }
    
    func pause() {
        guard let timer = timer else {
            return
        }
        switch timer.state {
        case .suspended:
            if !stack.isEmpty {
                timer.resume()
            }
        case .resumed: timer.suspend()
        }
    }
    
    func dropMaze() {
        timer?.suspend()
        timer = nil
        stack = []
        maze?.update(nil)
        maze = nil
    }
}
