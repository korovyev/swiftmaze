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
    var solveType : SolveType = SolveType.none
    var desiredCellSize : Int
    
    required init?(coder aDecoder: NSCoder) {
        self.mazeType = MazeType.recursiveDivision
        self.desiredCellSize = 6
        
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        switch self.mazeType {
        case .recursiveDivision:
            self.title = "Recursive Division"
        case .recursiveBacktracker:
            self.title = "Recursive Backtracker"
        case .spanningTree:
            self.title = "Spanning Tree"
        }
        
        let backButton: UIBarButtonItem = UIBarButtonItem.init()
        backButton.title = "Back"
        self.navigationController?.navigationBar.topItem!.backBarButtonItem = backButton
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        self.maze?.startMazeWithType(self.mazeType, cellSize: self.desiredCellSize, solveType: self.solveType)
        
        super.viewDidAppear(animated)
    }
    
}
