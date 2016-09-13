//
//  Maze.swift
//  swiftmaze
//
//  Created by Kevin Sweeney on 08/09/2016.
//  Copyright © 2016 Kevin Sweeney. All rights reserved.
//

import Cocoa

class Maze: NSView {
    
    var desiredCellSize:CGFloat = 16
    var grid: Grid?
    var lineColour = NSColor.red
    var lineWidth: CGFloat = 1
    
    func update(_ grid: Grid?) {
        self.grid = grid
        
        setNeedsDisplay(frame)
    }
    
    override func draw(_ dirtyRect: NSRect) {
        
        guard
            let grid = grid,
            let context = NSGraphicsContext.current()?.cgContext
        else {
            return
        }
        
        context.clear(dirtyRect)
        context.setShouldAntialias(false)
        
        let dashes: [CGFloat] = [1, 0]
        
        let cellSize = CGSize(width: Double(frame.size.width / CGFloat(grid.size.width)), height: Double(frame.size.height / CGFloat(grid.size.height)))
        
        if let highlightCells = grid.highlightCells {
            
            for cell in highlightCells {
                context.setFillColor(NSColor.gray.cgColor)
                
                context.fill(CGRect(x: CGFloat(cell.xPos) * cellSize.width, y: CGFloat(cell.yPos) * cellSize.height, width: cellSize.width, height: cellSize.height));
            }
        }
        
        if let highlightCell = grid.highlightCell {
            context.setFillColor(NSColor.blue.cgColor)
            
            context.fill(CGRect(x: CGFloat(highlightCell.xPos) * cellSize.width, y: CGFloat(highlightCell.yPos) * cellSize.height, width: cellSize.width, height: cellSize.height));
        }
        
        if let target = grid.target {
            context.setFillColor(NSColor.orange.withAlphaComponent(0.2).cgColor)
            
            context.fill(CGRect(x: CGFloat(target.xPos) * cellSize.width, y: CGFloat(target.yPos) * cellSize.height, width: cellSize.width, height: cellSize.height));
        }
        
        for line in grid.verticalLines {
            
            context.setStrokeColor(lineColour.cgColor)
            context.setLineDash(phase: 0, lengths: dashes)
            
            context.setLineWidth(lineWidth)
            
            context.move(to: CGPoint(x: CGFloat(line.start.x) * cellSize.width, y: CGFloat(line.start.y) * cellSize.height))
            context.addLine(to: CGPoint(x: CGFloat(line.end.x) * cellSize.width, y: CGFloat(line.end.y) * cellSize.height))
            
            context.strokePath()
        }

        for line in grid.horizontalLines {
            
            context.setStrokeColor(lineColour.cgColor)
            context.setLineDash(phase: 1, lengths: dashes)
            
            context.setLineWidth(lineWidth)
            
            context.move(to: CGPoint(x: CGFloat(line.start.x) * cellSize.width, y: CGFloat(line.start.y) * cellSize.height))
            context.addLine(to: CGPoint(x: CGFloat(line.end.x) * cellSize.width, y: CGFloat(line.end.y) * cellSize.height))
            
            context.strokePath()
        }
    }
}
