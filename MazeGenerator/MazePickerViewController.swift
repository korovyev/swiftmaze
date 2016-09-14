//
//  MazePickerController.swift
//  swiftmaze
//
//  Created by Kevin Sweeney on 13/09/2016.
//  Copyright © 2016 Kevin Sweeney. All rights reserved.
//

import Cocoa

protocol MazePickerViewControllerDelegate: class {
    func mazePicker(controller: MazePickerViewController, didPickMazeSetup setup: MazeSetup)
}

class MazePickerViewController: NSViewController, NSTextFieldDelegate {
    
    @IBOutlet var generatorSelect: NSPopUpButton!
    @IBOutlet var solverSelect: NSPopUpButton!
    @IBOutlet var gridWidth: NSTextField!
    @IBOutlet var gridHeight: NSTextField!
    weak var delegate: MazePickerViewControllerDelegate?
    
    var generators: [GenerationAlgorithm] = [.recursiveDivision, .backtracker, .kruskal, .eller, .wilson]
    var solvers: [SolvingAlgorithm] = [.tremaux, .aStar, .deadEndFilling, .none]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        
        generatorSelect.removeAllItems()
        generatorSelect.addItems(withTitles: generators.map { $0.rawValue })
        solverSelect.removeAllItems()
        solverSelect.addItems(withTitles: solvers.map { $0.rawValue })
    }
    
    @IBAction func start(sender: NSButton) {
        
        guard
            let delegate = delegate,
            let generatorItem = generatorSelect.selectedItem,
            let solverItem = solverSelect.selectedItem
        else {
            return
        }
        
        let width = min(max(2, gridWidth.integerValue), 150)
        let height = min(max(2, gridHeight.integerValue), 150)
        
        let gridSize = Size(width: width, height: height)
        let generator = generators[generatorSelect.index(of: generatorItem)]
        let solver = solvers[solverSelect.index(of: solverItem)]
        
        let setup = MazeSetup(algorithm: generator, solver: solver, size: gridSize)
        
        delegate.mazePicker(controller: self, didPickMazeSetup: setup)
        
    }
}
