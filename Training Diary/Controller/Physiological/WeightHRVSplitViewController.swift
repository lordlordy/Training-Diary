//
//  WeightHRVSplitViewController.swift
//  Training Diary
//
//  Created by Steven Lord on 25/04/2018.
//  Copyright © 2018 Steven Lord. All rights reserved.
//

import Cocoa

class WeightHRVSplitViewController: TrainingDiarySplitViewController {
    
    var graphViewController: WeightHRVGraphViewController?{
        for c in childViewControllers{
            if let gac = c as? WeightHRVGraphViewController{
                return gac
            }
        }
        return nil
    }
    
}

