//
//  WeightHRViewController.swift
//  Training Diary
//
//  Created by Steven Lord on 09/11/2017.
//  Copyright © 2017 Steven Lord. All rights reserved.
//

import Cocoa

class WeightHRViewController: NSViewController {

    @objc dynamic var trainingDiary: TrainingDiary?
    @IBOutlet var weightArrayController: NSArrayController!
    @IBOutlet var hrArrayController: NSArrayController!
    
    @IBAction func printWeights(_ sender: NSButton){
        if let weights = weightArrayController.selectedObjects{
            for w in weights{
                print(w)
            }
        }
    }
    
    @IBAction func printPhysiologicals(_ sender: NSButton){
        if let physiologicals = hrArrayController.selectedObjects{
            for p in physiologicals{
                print(p)
            }
        }
    }
    
    
}
