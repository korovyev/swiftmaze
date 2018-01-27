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
    case prim = "Prim"
    
    var generator: Algorithm {
        switch self {
        case .recursiveDivision:    return RecursiveDivision()
        case .backtracker:          return Backtracker()
        case .kruskal:              return Kruskal()
        case .eller:                return Eller()
        case .wilson:               return Wilson()
        case .prim:                 return Prim()
        }
    }
}
