//
//  Maze.swift
//  swiftmaze
//
//  Created by Kevin Sweeney on 08/09/2016.
//  Copyright © 2016 Kevin Sweeney. All rights reserved.
//

import Cocoa

class Maze: NSView {
    
    var grid: Grid?
    var lineWidth: CGFloat = 1
    var setup: MazeSetup? {
        didSet {
            layer?.backgroundColor = setup?.backgroundColour.cgColor
            lineWidth = CGFloat(setup?.lineWidth ?? 1)
        }
    }
    
    func update(_ grid: Grid?) {
        self.grid = grid
        
        setNeedsDisplay(frame)
    }
    
    override func draw(_ dirtyRect: NSRect) {
        
        guard
            let grid = grid,
            let context = NSGraphicsContext.current?.cgContext,
            let setup = setup
        else {
            return
        }
        
        context.clear(dirtyRect)
        context.setShouldAntialias(false)
        
        let dashes: [CGFloat] = [1, 0]
        
        let cellSize = CGSize(width: Double(frame.size.width / CGFloat(grid.size.width)), height: Double(frame.size.height / CGFloat(grid.size.height)))
        
        if let highlightCells = grid.highlightCells {
            
            for cell in highlightCells {
                context.setFillColor(setup.highlightColour.cgColor)
                
                context.fill(CGRect(x: CGFloat(cell.xPos) * cellSize.width, y: CGFloat(cell.yPos) * cellSize.height, width: cellSize.width, height: cellSize.height))
            }
        }
        
        if let target = grid.target {
            context.setFillColor(setup.targetColour.cgColor)
            
            context.fill(CGRect(x: CGFloat(target.xPos) * cellSize.width, y: CGFloat(target.yPos) * cellSize.height, width: cellSize.width, height: cellSize.height))
        }
        
        if let secondaryHighlightCells = grid.secondaryHighlightCells {
            for cell in secondaryHighlightCells {
                context.setFillColor(setup.secondaryHighlightColour.cgColor)
                
                context.fill(CGRect(x: CGFloat(cell.xPos) * cellSize.width, y: CGFloat(cell.yPos) * cellSize.height, width: cellSize.width, height: cellSize.height))
            }
        }
        
        for line in grid.verticalLines {
            
            context.setStrokeColor(setup.wallColour.cgColor)
            context.setLineDash(phase: 0, lengths: dashes)
            
            context.setLineWidth(lineWidth)
            
            context.move(to: CGPoint(x: CGFloat(line.start.x) * cellSize.width, y: CGFloat(line.start.y) * cellSize.height))
            context.addLine(to: CGPoint(x: CGFloat(line.end.x) * cellSize.width, y: CGFloat(line.end.y) * cellSize.height))
            
            context.strokePath()
        }

        for line in grid.horizontalLines {
            
            context.setStrokeColor(setup.wallColour.cgColor)
            context.setLineDash(phase: 1, lengths: dashes)
            
            context.setLineWidth(lineWidth)
            
            context.move(to: CGPoint(x: CGFloat(line.start.x) * cellSize.width, y: CGFloat(line.start.y) * cellSize.height))
            context.addLine(to: CGPoint(x: CGFloat(line.end.x) * cellSize.width, y: CGFloat(line.end.y) * cellSize.height))
            
            context.strokePath()
        }
    }
}
