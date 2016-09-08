//
//  DeepLinker.swift
//  swiftmaze
//
//  Created by Kevin Sweeney on 26/10/2015.
//  Copyright © 2015 Kevin Sweeney. All rights reserved.
//

import UIKit

enum ApplicationShortcuts: String {
    case RecursiveDivisionShortcut = "com.sween.swiftmaze.RecursiveDivisionShortcut"
    case RecursiveBacktrackerShortcut = "com.sween.swiftmaze.RecursiveBacktrackerShortcut"
}

class DeepLinker {
    
    class func handleShortcutItem(_ shortcutItem: UIApplicationShortcutItem, appWindow: UIWindow) -> Bool {
        
        if let shortcutType = ApplicationShortcuts(rawValue: shortcutItem.type) {
            switch shortcutType {
            case .RecursiveBacktrackerShortcut:
                return self.beginMazeWithType(MazeType.recursiveBacktracker, appWindow: appWindow)
            case .RecursiveDivisionShortcut:
                return self.beginMazeWithType(MazeType.recursiveDivision, appWindow: appWindow)
            }
        }
        
        return false
    }
    
    class func beginMazeWithType(_ mazeType: MazeType, appWindow: UIWindow) -> Bool {
        if let navController = appWindow.rootViewController as? UINavigationController {
            
            var controllers = navController.viewControllers;
            
            controllers = [controllers.first!]
            
            if let mazeController: MazeViewController = navController.storyboard?.instantiateViewController(withIdentifier: "MazeViewController") as? MazeViewController {
                
                mazeController.mazeType = mazeType
                
                controllers.append(mazeController)
                
                navController.viewControllers = controllers
                
                return true
            }
        }
        
        return false
    }
    
}
