//
//  Generator.swift
//  swiftmaze
//
//  Created by Kevin Sweeney on 08/09/2016.
//  Copyright © 2016 Kevin Sweeney. All rights reserved.
//

import Foundation

enum GeneratorState {
    case generating
    case finished
}

protocol Generator {
    var state: GeneratorState { get set }
    var updateInterval: Float { get set }
    
    func generateMaze(in grid: Grid, step: @escaping () -> Void)
}

extension Generator {
    func delay(step:  @escaping () -> Void) {
        DispatchQueue.main.asyncAfter(deadline: .now() + Double(updateInterval), execute: step)
    }
}
