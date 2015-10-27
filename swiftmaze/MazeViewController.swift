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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        switch self.mazeType {
        case .RecursiveDivision:
            self.title = "Recursive Division"
        case .RecursiveBacktracker:
            self.title = "Recursive Backtracker"
        case .SpanningTree:
            self.title = "Spanning Tree"
        }
        
        let backButton: UIBarButtonItem = UIBarButtonItem.init()
        backButton.title = "Back"
        self.navigationController?.navigationBar.topItem!.backBarButtonItem = backButton
    }
    
    override func viewDidAppear(animated: Bool) {
        
        self.maze?.startMazeWithType(self.mazeType)
        
        super.viewDidAppear(animated)
    }
    
}