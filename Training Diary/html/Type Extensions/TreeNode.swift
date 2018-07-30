//
//  TreeNode.swift
//  Training Diary
//
//  Created by Steven Lord on 31/01/2018.
//  Copyright © 2018 Steven Lord. All rights reserved.
//

import Foundation

protocol TreeNode{
    var isLeaf: Bool { get }
    var childCount: Int { get }
    var children: [TreeNode] { get }
}
