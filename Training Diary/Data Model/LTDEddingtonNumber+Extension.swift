//
//  LTDEddingtonNumber+Extension.swift
//  Training Diary
//
//  Created by Steven Lord on 03/02/2018.
//  Copyright © 2018 Steven Lord. All rights reserved.
//

import Foundation

extension LTDEddingtonNumber{
    
    @objc dynamic var descendantCount: Int{ return calculatedDescendentCount()}
    @objc dynamic var isLeaf: Bool { return childArray().count == 0}
    @objc dynamic var isRoot: Bool { return parent == nil}
    
    @objc dynamic var code: String{
        var result: String = activity ?? ""
        result += ":" + (equipment ?? "")
        result += ":" + (activityType ?? "")
        result += ":" + (period ?? "")
        result += ":" + (unit ?? "")
        return result
    }
    
    func getLeaves() -> [LTDEddingtonNumber]{
        var result: [LTDEddingtonNumber] = []
        if isLeaf{
            result.append(self)
            return result
        }else{
            for c in childArray(){
                result.append(contentsOf: c.getLeaves())
            }
        }
        return result
    }
    
    //if no present it creates it
    func getChild(forName n: String) -> LTDEddingtonNumber{
        
        let filtered = childArray().filter({$0.name == n})
        
        if filtered.count == 1 {
            return filtered[0]
        }else if filtered.count > 1{
            // shouldn't be more than this many
            print("\(filtered.count) children of name \(n) in \(String(describing: name)) - should be unique by name")
            return filtered[0]
        }else{
            let newChild = CoreDataStackSingleton.shared.newLTDEddingtonNumber(n)
            mutableSetValue(forKey: LTDEddingtonNumberProperty.children.rawValue).add(newChild)
            return newChild
        }
    }

    private func childArray() -> [LTDEddingtonNumber]{
        if let array = children?.allObjects as? [LTDEddingtonNumber]{
            return array
        }
        return []
    }

    private func calculatedDescendentCount() -> Int{
        var result: Int = 0
        if childArray().count == 0{
            return 1
        }else{
            for c in childArray(){
                result += c.calculatedDescendentCount()
            }
        }
        return result
    }
    

    
}
