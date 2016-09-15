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
    @IBOutlet var lineWidth: NSTextField!
    @IBOutlet var backgroundColour: NSColorWell!
    @IBOutlet var wallColour: NSColorWell!
    @IBOutlet var targetColour: NSColorWell!
    @IBOutlet var highlightColour: NSColorWell!
    @IBOutlet var secondaryHighlightColour: NSColorWell!
    
    @IBOutlet var backgroundLabel: NSTextField!
    @IBOutlet var wallLabel: NSTextField!
    @IBOutlet var targetLabel: NSTextField!
    @IBOutlet var highlightLabel: NSTextField!
    @IBOutlet var secondaryHighlightLabel: NSTextField!
    
    var setup: MazeSetup?
    var hiddenViews = [NSView]()
    
    weak var delegate: MazePickerViewControllerDelegate?
    
    var generators: [GenerationAlgorithm] = [.recursiveDivision, .backtracker, .kruskal, .eller, .wilson]
    var solvers: [SolvingAlgorithm] = [.tremaux, .aStar, .deadEndFilling, .floodFill, .none]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        
        hiddenViews = [backgroundColour, backgroundLabel, wallColour, wallLabel, targetColour, targetLabel, highlightColour, highlightLabel, secondaryHighlightColour, secondaryHighlightLabel]
        
        generatorSelect.removeAllItems()
        generatorSelect.addItems(withTitles: generators.map { $0.rawValue })
        solverSelect.removeAllItems()
        solverSelect.addItems(withTitles: solvers.map { $0.rawValue })
        
        preferredContentSize = NSSize(width: 450, height: 225)
    }
    
    override func viewWillAppear() {
        super.viewWillAppear()
        
        guard let setup = setup else {
            return
        }
        
        guard let generatorIndex = generators.index(of: setup.generator), let solverIndex = solvers.index(of: setup.solver) else {
            return
        }
        
        generatorSelect.selectItem(at: generatorIndex)
        solverSelect.selectItem(at: solverIndex)
        wallColour.color = setup.wallColour
        targetColour.color = setup.targetColour
        highlightColour.color = setup.highlightColour
        secondaryHighlightColour.color = setup.secondaryHighlightColour
        backgroundColour.color = setup.backgroundColour
        
        gridWidth.stringValue = "\(setup.size.width)"
        gridHeight.stringValue = "\(setup.size.height)"
        lineWidth.stringValue = "\(setup.lineWidth)"
    }
    
    func create(with setup: MazeSetup) {
        
        self.setup = setup
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
        let gridLineWidth = min(max(1, lineWidth.integerValue), 5)
        
        let gridSize = Size(width: width, height: height)
        let generator = generators[generatorSelect.index(of: generatorItem)]
        let solver = solvers[solverSelect.index(of: solverItem)]
        
        var setup = MazeSetup()
        setup.generator = generator
        setup.solver = solver
        setup.size = gridSize
        setup.lineWidth = gridLineWidth
        setup.backgroundColour = backgroundColour.color
        setup.wallColour = wallColour.color
        setup.highlightColour = highlightColour.color
        setup.secondaryHighlightColour = secondaryHighlightColour.color
        setup.targetColour = targetColour.color
        
        delegate.mazePicker(controller: self, didPickMazeSetup: setup)
        
    }
    
    @IBAction func colourDiscloseTapped(sender: NSButton) {
        if sender.state == 1 {
            
            preferredContentSize = NSSize(width: 450, height: 360)
            hiddenViews.forEach({ $0.isHidden = false })
        }
        else {
            hiddenViews.forEach({ $0.isHidden = true })
            preferredContentSize = NSSize(width: 450, height: 225)
            
        }
    }
}
