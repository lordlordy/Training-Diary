//
//  EdLevel.swift
//  Training Diary
//
//  Created by Steven Lord on 31/01/2018.
//  Copyright © 2018 Steven Lord. All rights reserved.
//

import Foundation

@objc class EdLevel: NSObject, TreeNode{
    
    //MARK: - TreeNode implementation
    @objc dynamic var isLeaf: Bool { return children.count == 0}
    @objc dynamic var childCount: Int { return children.count}
    var children: [TreeNode] { return edChildren as [TreeNode]}
    
    @objc dynamic var mutableChildren:NSSet { return  NSSet.init(array: edChildren)}
    var edChildren: [EdLevel] = []

    
    @objc dynamic var name: String

    @objc dynamic var descendantCount: Int{ return calculatedDescendentCount() }
    
    init(name n: String){
        name = n
    }
 
    private func calculatedDescendentCount() -> Int{
        var result: Int = 0
        if edChildren.count == 0{
            return 1
        }else{
            for c in edChildren{
                result += c.calculatedDescendentCount()
            }
        }
        return result
    }
    
}
