//
//  ViewController.swift
//  swiftmaze
//
//  Created by Kevin Sweeney on 10/10/2015.
//  Copyright © 2015 Kevin Sweeney. All rights reserved.
//

import UIKit

class ConfigViewController: UIViewController , UIPickerViewDataSource, UIPickerViewDelegate {
    
    @IBOutlet weak var recursiveBacktracker : UIButton?
    @IBOutlet weak var recursiveDivision : UIButton?
    @IBOutlet weak var sizePicker : UIPickerView?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Configuration"
    }
    
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let button = sender as? UIButton {
            
            if let mazeController = segue.destinationViewController as? MazeViewController {
                
                mazeController.desiredCellSize = self.sizePicker!.selectedRowInComponent(0) + 3
                
                if button == recursiveBacktracker {
                    mazeController.mazeType = MazeType.RecursiveBacktracker
                }
                else if button == recursiveDivision {
                    mazeController.mazeType = MazeType.RecursiveDivision
                }
                mazeController.solveType = SolveType.Tremaux
            }
        }
    }
    
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return 28
    }
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return "\(row + 3)"
    }
}

