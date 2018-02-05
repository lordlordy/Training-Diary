//
//  EdLevel.swift
//  Training Diary
//
//  Created by Steven Lord on 31/01/2018.
//  Copyright © 2018 Steven Lord. All rights reserved.
//

import Foundation
/* DEPRECATED
@objc class EdLevel: NSObject{
    
    @objc dynamic var isLeaf: Bool { return children.count == 0}
    @objc dynamic var childCount: Int { return children.count}
    @objc dynamic var children: [EdLevel]{
        get{
      //      print("Getting value from \(name)")
            return internalChildren
        }
        set{
            internalChildren = newValue
        }
    }
    
    @objc dynamic var name: String

    @objc var descendantCount: Int{ return calculatedDescendentCount() }
    
    //only set at leaf level
    @objc var edNumber: LTDEdNum?
    
    private var internalChildren: [EdLevel] = []
    
    @objc init(name n: String){
        name = n
    }
    
    
 
    func printOut(_ s: String){
        var pString = ":"
        pString += s
        pString += name + " - "
        pString += String(calculatedDescendentCount())
        print(pString)
        for c in children{
            c.printOut(s + "~")
        }

    }
    
    private func calculatedDescendentCount() -> Int{
        var result: Int = 0
        if children.count == 0{
            return 1
        }else{
            for c in children{
                result += c.calculatedDescendentCount()
            }
        }
        return result
    }
    
}
 */
