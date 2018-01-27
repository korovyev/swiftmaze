//
//  Algorithm.swift
//  MazeGenerator
//
//  Created by Kevin Sweeney on 27/01/2018.
//  Copyright © 2018 Kevin Sweeney. All rights reserved.
//

protocol Algorithm {
    func begin(in grid: Grid) -> [AlgorithmState]
    func step(state: AlgorithmState, in grid: Grid) -> [AlgorithmState]
}

protocol AlgorithmState {}
