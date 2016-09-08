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
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let button = sender as? UIButton {
            
            if let mazeController = segue.destination as? MazeViewController {
                
                mazeController.desiredCellSize = self.sizePicker!.selectedRow(inComponent: 0) + 3
                
                if button == recursiveBacktracker {
                    mazeController.mazeType = MazeType.recursiveBacktracker
                }
                else if button == recursiveDivision {
                    mazeController.mazeType = MazeType.recursiveDivision
                }
                mazeController.solveType = SolveType.aStar
            }
        }
    }
    
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return 28
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return "\(row + 3)"
    }
}

