//
//  ViewController.swift
//  swiftmaze
//
//  Created by Kevin Sweeney on 10/10/2015.
//  Copyright © 2015 Kevin Sweeney. All rights reserved.
//

import UIKit

class ConfigViewController: UIViewController {
    
    @IBOutlet weak var recursiveBacktracker : UIButton?
    @IBOutlet weak var recursiveDivision : UIButton?

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let button = sender as? UIButton {
            
            if let mazeController = segue.destinationViewController as? MazeViewController {
                if button == recursiveBacktracker {
                    mazeController.mazeType = MazeType.RecursiveBacktracker
                }
                else if button == recursiveDivision {
                    mazeController.mazeType = MazeType.RecursiveDivision
                }
            }
        }
    }
}

