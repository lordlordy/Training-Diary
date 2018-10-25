//
//  BikeSplitViewController.swift
//  Training Diary
//
//  Created by Steven Lord on 25/04/2018.
//  Copyright © 2018 Steven Lord. All rights reserved.
//

import Foundation

class BikeSplitViewController: TrainingDiarySplitViewController{
    
    var bikeGraphViewController: BikeGraphViewController?{
        for c in children{
            if let vc = c as? BikeGraphViewController{
                return vc
            }
        }
        return nil
    }
    
}
