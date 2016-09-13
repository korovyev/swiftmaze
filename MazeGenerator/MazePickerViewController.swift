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
    @IBOutlet var gridWidth: NSTextField!
    @IBOutlet var gridHeight: NSTextField!
    weak var delegate: MazePickerViewControllerDelegate?
    
    var generators: [GenerationAlgorithm] = [.recursiveDivision, .backtracker, .kruskal, .eller, .wilson]
    

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        
        generatorSelect.removeAllItems()
        generatorSelect.addItems(withTitles: generators.map { $0.rawValue })
    }
    
    @IBAction func start(sender: NSButton) {
        
        if let delegate = delegate, let selectedItem = generatorSelect.selectedItem {
            
            let width = min(max(2, gridWidth.integerValue), 150)
            let height = min(max(2, gridHeight.integerValue), 150)
            
            let gridSize = Size(width: width, height: height)
            
            let setup = MazeSetup(algorithm: generators[generatorSelect.index(of: selectedItem)], size: gridSize)
            
            delegate.mazePicker(controller: self, didPickMazeSetup: setup)
        }
    }
}
