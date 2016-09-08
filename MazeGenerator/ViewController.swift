//
//  ViewController.swift
//  MazeGenerator
//
//  Created by Kevin Sweeney on 08/09/2016.
//  Copyright © 2016 Kevin Sweeney. All rights reserved.
//

import Cocoa

class ViewController: NSViewController {
    
    @IBOutlet var mazeView: Maze!
    var coordinator: MazeCoordinator! = nil

    override func viewDidLoad() {
        super.viewDidLoad()

        coordinator = MazeCoordinator(maze: mazeView)
    }

    @IBAction func start(sender: NSButton) {
        coordinator.start()
    }
}

