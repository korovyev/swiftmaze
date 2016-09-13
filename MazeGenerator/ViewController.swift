//
//  ViewController.swift
//  MazeGenerator
//
//  Created by Kevin Sweeney on 08/09/2016.
//  Copyright © 2016 Kevin Sweeney. All rights reserved.
//

import Cocoa

class ViewController: NSViewController, MazePickerViewControllerDelegate {
    
    @IBOutlet var mazeView: Maze!
    @IBOutlet var startButton: NSButton!
    var coordinator: MazeCoordinator?

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear() {
        super.viewDidAppear()
        
        let sheet = storyboard?.instantiateController(withIdentifier: "mazePicker") as! MazePickerViewController
        sheet.delegate = self
        
        presentViewControllerAsSheet(sheet)
    }
    
    func mazePicker(controller: MazePickerViewController, didPickMazeSetup setup: MazeSetup) {
        dismissViewController(controller)
        coordinator = MazeCoordinator(maze: mazeView, setup: setup)
        startButton.title = "Start"
    }

    @IBAction func start(sender: NSButton) {
        
        if let coordinator = coordinator {
            if coordinator.generator.state != .idle {
                
                self.coordinator?.dropMaze()
                self.coordinator = nil
                
                let sheet = storyboard?.instantiateController(withIdentifier: "mazePicker") as! MazePickerViewController
                sheet.delegate = self
                
                presentViewControllerAsSheet(sheet)
            }
            else {
                sender.title = "New"
                coordinator.start()
            }
        }
    }
}

