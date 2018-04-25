//
//  GraphManagementDelegate.swift
//  Training Diary
//
//  Created by Steven Lord on 06/12/2017.
//  Copyright © 2017 Steven Lord. All rights reserved.
//

import Foundation

protocol GraphManagementDelegate{
    func add(graph: ActivityGraphDefinition)
    func setDefaults(forGraph graph: ActivityGraphDefinition)
    func remove(graph: ActivityGraphDefinition)
}
