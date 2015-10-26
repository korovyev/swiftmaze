//
//  Maze.swift
//  swiftmaze
//
//  Created by Kevin Sweeney on 10/10/2015.
//  Copyright © 2015 Kevin Sweeney. All rights reserved.
//

import UIKit

class Maze: UIView {
    var myGrid: Grid!
    let lineWidth:CGFloat = 1
    let desiredCellSize = CGFloat(16)
    
    var mazeCreated:Bool = false
    
    required init?(coder aDecoder: NSCoder) {
        
        super.init(coder: aDecoder)
        
        self.backgroundColor = UIColor.whiteColor()
    }
    
    func createGrid() {
        
        self.myGrid = Grid(size: Size(width: Int(self.frame.size.width / desiredCellSize), height: Int(self.frame.size.height / desiredCellSize)))
        
        self.myGrid.buildFrame()
        self.myGrid.buildGrid()
        
        self.mazeCreated = true
        
        self.setNeedsDisplay()
        
        self.maze()
    }
    
    func maze() {
        self.myGrid.startMaze { () -> Void in
            self.setNeedsDisplay()
        }
    }
    
    override func drawRect(rect: CGRect) {
        
        if !mazeCreated {
            return;
        }
        
        let context:CGContextRef = UIGraphicsGetCurrentContext()!
        
        CGContextClearRect(context, rect)
        CGContextSetShouldAntialias(context, false)
        
        let dashes:Array <CGFloat> = [1,1]
        
        let cellSize = CGSize(width: Double(self.frame.size.width / CGFloat(self.myGrid.size.width)), height: Double(self.frame.size.height / CGFloat(self.myGrid.size.height)))
        
        for cell in self.myGrid.filledCells {
//            CGContextSetGrayFillColor(context, 0.5, 1)
//            CGContextSetRGBFillColor(context, 1, 1, 0, 1);
            
            CGContextSetFillColorWithColor(context, UIColor.orangeColor().CGColor)
            CGContextFillRect(context, CGRectMake(CGFloat(cell.xPos) * cellSize.width, CGFloat(cell.yPos) * cellSize.height, cellSize.width, cellSize.height));
        }
        
        for line in self.myGrid.verticalLines {
            CGContextSetStrokeColorWithColor(context, UIColor.greenColor().CGColor);
            CGContextSetLineDash(context, 1, dashes, 0);
            
            CGContextSetLineWidth(context, lineWidth);
            
            CGContextMoveToPoint(context, CGFloat(line.start.x) * cellSize.width, CGFloat(line.start.y) * cellSize.height);
            CGContextAddLineToPoint(context, CGFloat(line.end.x) * cellSize.width, CGFloat(line.end.y) * cellSize.height);
            
            CGContextStrokePath(context);
        }
        
        for line in self.myGrid.horizontalLines {
            CGContextSetStrokeColorWithColor(context, UIColor.greenColor().CGColor);
            CGContextSetLineDash(context, 1, dashes, 0);
            
            CGContextSetLineWidth(context, lineWidth);
            
            CGContextMoveToPoint(context, CGFloat(line.start.x) * cellSize.width, CGFloat(line.start.y) * cellSize.height);
            CGContextAddLineToPoint(context, CGFloat(line.end.x) * cellSize.width, CGFloat(line.end.y) * cellSize.height);
            
            CGContextStrokePath(context);
        }
        
        
    }
}