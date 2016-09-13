//
//  Generator.swift
//  swiftmaze
//
//  Created by Kevin Sweeney on 08/09/2016.
//  Copyright © 2016 Kevin Sweeney. All rights reserved.
//

import Foundation

enum GenerationAlgorithm: String {
    case recursiveDivision = "Recursive Division"
    case backtracker = "Backtracker"
    case kruskal = "Kruskal"
    case eller = "Eller"
    case wilson = "Wilson"
}

enum GeneratorState {
    case idle
    case generating
    case finished
}

protocol Generator {
    var state: GeneratorState { get }
    var updateInterval: Float { get }
    var stop: Bool { get }
    
    func generateMaze(in grid: Grid, step: @escaping () -> Void)
    func quit()
}

extension Generator {
    func delay(step:  @escaping () -> Void) {
        DispatchQueue.main.asyncAfter(deadline: .now() + Double(updateInterval), execute: step)
    }
}
