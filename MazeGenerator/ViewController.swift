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
    private var coordinator: MazeCoordinator?
    private var monitor: Any?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        monitor = NSEvent.addLocalMonitorForEvents(matching: NSEvent.EventTypeMask.keyDown, handler: handleKeyDown)
    }
    
    override func viewDidAppear() {
        super.viewDidAppear()
        
        let sheet = storyboard?.instantiateController(withIdentifier: NSStoryboard.SceneIdentifier(rawValue: "mazePicker")) as! MazePickerViewController
        sheet.delegate = self
        sheet.create(with: MazeSetup.load())
        
        presentViewControllerAsSheet(sheet)
    }
    
    func mazePicker(controller: MazePickerViewController, didPickMazeSetup setup: MazeSetup) {
        dismissViewController(controller)
        coordinator = MazeCoordinator(maze: mazeView, setup: setup)
        startButton.title = "Start"
        
        setup.save()
    }
    
    func handleKeyDown(with event: NSEvent) -> NSEvent {
        guard let coordinator = coordinator else {
            return event
        }
        
        if event.keyCode == 49 { // spacebar
            coordinator.pause()
        }
        else {
            coordinator.step()
        }
        
        return event
    }

    @IBAction func start(sender: NSButton) {
        
        guard let coordinator = coordinator else {
            return
        }
        
        if coordinator.status != .idle {
            
            self.coordinator?.dropMaze()
            
            let sheet = storyboard?.instantiateController(withIdentifier: NSStoryboard.SceneIdentifier(rawValue: "mazePicker")) as! MazePickerViewController
            sheet.delegate = self
            sheet.create(with: MazeSetup.load())
            
            presentViewControllerAsSheet(sheet)
        }
        else {
            sender.title = "New"
            coordinator.start()
        }
    }
}

