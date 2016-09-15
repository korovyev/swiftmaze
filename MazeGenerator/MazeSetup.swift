//
//  MazeSetup.swift
//  swiftmaze
//
//  Created by Kevin Sweeney on 15/09/2016.
//  Copyright © 2016 Kevin Sweeney. All rights reserved.
//

import Cocoa

struct MazeSetup {
    var generator: GenerationAlgorithm
    var solver: SolvingAlgorithm
    var size: Size
    var lineWidth: Int
    var highlightColour: NSColor
    var secondaryHighlightColour: NSColor
    var wallColour: NSColor
    var backgroundColour: NSColor
    var targetColour: NSColor
    
    init() {
        generator = .recursiveDivision
        solver = .tremaux
        size = Size(width: 30, height: 30)
        lineWidth = 1
        highlightColour = .red
        secondaryHighlightColour = .green
        wallColour = .black
        backgroundColour = .white
        targetColour = .orange
    }
    
    func save() {
        let defaults = UserDefaults.standard
        
        defaults.set(generator.rawValue, forKey: "generator")
        defaults.set(solver.rawValue, forKey: "solver")
        defaults.set(size.width, forKey: "width")
        defaults.set(size.height, forKey: "height")
        defaults.set(lineWidth, forKey: "lineWidth")
        defaults.set(color: highlightColour, forKey: "highlight")
        defaults.set(color: secondaryHighlightColour, forKey: "secondary")
        defaults.set(color: wallColour, forKey: "wall")
        defaults.set(color: backgroundColour, forKey: "background")
        defaults.set(color: targetColour, forKey: "target")
    }
    
    static func load() -> MazeSetup {
        
        var setup = MazeSetup()
        let defaults = UserDefaults.standard
        
        guard let _ = defaults.object(forKey: "generator") else {
            return setup
        }
        
        setup.generator = GenerationAlgorithm(rawValue: defaults.object(forKey: "generator") as! String) ?? .recursiveDivision
        setup.solver = SolvingAlgorithm(rawValue: defaults.object(forKey: "solver") as! String) ?? .tremaux
        
        var gridSize = Size(width: 30, height: 30)
        gridSize.width = defaults.integer(forKey: "width")
        gridSize.height = defaults.integer(forKey: "height")
        setup.size = gridSize
        setup.lineWidth = min(max(defaults.integer(forKey: "lineWidth"), 1), 5)
        
        setup.highlightColour = defaults.color(forKey: "highlight") ?? .red
        setup.secondaryHighlightColour = defaults.color(forKey: "secondary") ?? .green
        setup.wallColour = defaults.color(forKey: "wall") ?? .black
        setup.backgroundColour = defaults.color(forKey: "background") ?? .white
        setup.targetColour = defaults.color(forKey: "target") ?? .orange
        
        return setup
    }
}
