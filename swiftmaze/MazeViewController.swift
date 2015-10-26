//
//  MazeViewController.swift
//  swiftmaze
//
//  Created by Kevin Sweeney on 25/10/2015.
//  Copyright © 2015 Kevin Sweeney. All rights reserved.
//

import UIKit


class MazeViewController: UIViewController {
    
    @IBOutlet weak var maze : Maze?
    var mazeType : MazeType
    
    required init?(coder aDecoder: NSCoder) {
        self.mazeType = MazeType.RecursiveDivision
        
        super.init(coder: aDecoder)
    }
    
    override func viewDidAppear(animated: Bool) {
        
        self.maze?.startMazeWithType(self.mazeType)
        
        super.viewDidAppear(animated)
    }
    
}