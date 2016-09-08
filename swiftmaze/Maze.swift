//
//  Maze.swift
//  swiftmaze
//
//  Created by Kevin Sweeney on 10/10/2015.
//  Copyright © 2015 Kevin Sweeney. All rights reserved.
//

import UIKit

enum MazeType {
    case recursiveBacktracker
    case spanningTree
    case recursiveDivision
}

enum SolveType {
    case aStar
    case tremaux
    case deadEndFilling
    case none
}

class Maze: UIView {
    var myGrid: Grid!
    let lineWidth:CGFloat = 1
    var desiredCellSize = CGFloat(6)
    
    var mazeCreated:Bool = false
    
    func createGrid() {
        
        self.myGrid = Grid(size: Size(width: Int(self.frame.size.width / desiredCellSize), height: Int(self.frame.size.height / desiredCellSize)))
        
        self.mazeCreated = true
        
        self.setNeedsDisplay()
    }
    
    func startMazeWithType(_ mazeType: MazeType, cellSize: Int, solveType : SolveType) {
        
        self.desiredCellSize = CGFloat(cellSize)
        
        if self.mazeCreated {
            return
        }
        
        self.createGrid()
        
        self.myGrid.startMaze(mazeType, solveType: solveType, drawHandler: { () -> Void in
            self.setNeedsDisplay()
        })
    }
    
    override func draw(_ rect: CGRect) {
        
        if !self.mazeCreated {
            return;
        }
        
        let context:CGContext = UIGraphicsGetCurrentContext()!
        
        context.clear(rect)
        context.setShouldAntialias(false)
        
        let dashes:Array <CGFloat> = [1,1]
        
        let cellSize = CGSize(width: Double(self.frame.size.width / CGFloat(self.myGrid.size.width)), height: Double(self.frame.size.height / CGFloat(self.myGrid.size.height)))
        
        for cell in self.myGrid.filledCells {
            context.setFillColor(gray: 0.3, alpha: 1)
//            CGContextSetRGBFillColor(context, 1, 1, 0, 1);
            
//            CGContextSetFillColorWithColor(context, UIColor.yellowColor().CGColor)
            context.fill(CGRect(x: CGFloat(cell.xPos) * cellSize.width, y: CGFloat(cell.yPos) * cellSize.height, width: cellSize.width, height: cellSize.height));
        }
        
        for cell in self.myGrid.aStarClosedList {
            context.setFillColor(UIColor.blue.cgColor)
            
            context.fill(CGRect(x: CGFloat(cell.xPos) * cellSize.width, y: CGFloat(cell.yPos) * cellSize.height, width: cellSize.width, height: cellSize.height));
        }
        
        for cell in self.myGrid.aStarOpenList {
            context.setFillColor(UIColor.yellow.cgColor)
            
            context.fill(CGRect(x: CGFloat(cell.xPos) * cellSize.width, y: CGFloat(cell.yPos) * cellSize.height, width: cellSize.width, height: cellSize.height));
        }
        
        for cell in self.myGrid.tremauxActiveCells {
            context.setFillColor(UIColor.yellow.cgColor)
            
            context.fill(CGRect(x: CGFloat(cell.xPos) * cellSize.width, y: CGFloat(cell.yPos) * cellSize.height, width: cellSize.width, height: cellSize.height));
        }
        
        for cell in self.myGrid.shortestPath {
            context.setFillColor(UIColor.green.cgColor)
            
            context.fill(CGRect(x: CGFloat(cell.xPos) * cellSize.width, y: CGFloat(cell.yPos) * cellSize.height, width: cellSize.width, height: cellSize.height));
        }
        
        for line in self.myGrid.verticalLines {
            var colour = UIColor.red
            if line.ghost {
                colour = UIColor.red.withAlphaComponent(0.8)
            }
            context.setStrokeColor(colour.cgColor)
            context.setLineDash(phase: 1, lengths: dashes)
            
            context.setLineWidth(lineWidth)
            
            context.move(to: CGPoint(x: CGFloat(line.start.x) * cellSize.width, y: CGFloat(line.start.y) * cellSize.height))
            context.addLine(to: CGPoint(x: CGFloat(line.end.x) * cellSize.width, y: CGFloat(line.end.y) * cellSize.height))
            
            context.strokePath()
        }
        
        for line in self.myGrid.horizontalLines {
            var colour = UIColor.red
            if line.ghost {
                colour = UIColor.red.withAlphaComponent(0.8)
            }
            context.setStrokeColor(colour.cgColor)
            context.setLineDash(phase: 1, lengths: dashes)
            
            context.setLineWidth(lineWidth)
            
            context.move(to: CGPoint(x: CGFloat(line.start.x) * cellSize.width, y: CGFloat(line.start.y) * cellSize.height))
            context.addLine(to: CGPoint(x: CGFloat(line.end.x) * cellSize.width, y: CGFloat(line.end.y) * cellSize.height))
            
            context.strokePath()
        }
    }
}
