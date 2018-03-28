//
//  LTDEddingtonNumber+Extension.swift
//  Training Diary
//
//  Created by Steven Lord on 03/02/2018.
//  Copyright © 2018 Steven Lord. All rights reserved.
//

import Foundation

extension LTDEddingtonNumber{
    
    @objc dynamic var leafCount: Int{ return calculatedLeafCount()}
    @objc dynamic var isLeaf: Bool { return childArray().count == 0}
    @objc dynamic var isRoot: Bool { return parent == nil}
    @objc dynamic var isNotLeaf: Bool { return !isLeaf }
    @objc dynamic var isWeekDay: Bool { return DayOfWeek.all.map({$0.rawValue}).contains(dayType!)}
    
    @objc dynamic var edNum: Int16{
        if let childDay = getChildDayEddingtonNumber(){
            return childDay.value
        }else{
            return value
        }
    }

    @objc dynamic var edNumPlusOne: Int16{
        if let childDay = getChildDayEddingtonNumber(){
            return childDay.plusOne
        }else{
            return plusOne
        }
    }

    
    @objc dynamic var isZero: Bool { return edNum == 0 }
    
    @objc dynamic var code: String{
        let result = EddingtonNumber.code(dayType: dayType, activity: activity, activityType: activityType, equipment: equipment, period: period ?? "", unit: unit ?? "")
        return result
    }
    
    @objc dynamic var shortCode: String{
        let result = EddingtonNumber.shortCode(daytype: dayType, activity: activity, activityType: activityType, equipment: equipment, period: period ?? "", unit: unit ?? "")
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
    
    //if not present it creates it
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

    // MARK: - Private
    
    private func childArray() -> [LTDEddingtonNumber]{
        if let array = children?.allObjects as? [LTDEddingtonNumber]{
            return array
        }
        return []
    }

    private func calculatedLeafCount() -> Int{
        var result: Int = 0
        if childArray().count == 0{
            return 1
        }else{
            for c in childArray(){
                result += c.calculatedLeafCount()
            }
        }
        return result
    }
    
    // just looks as far as children (ie doesn't recurse down) as if go further there will be loads of "Day" ed nums
    private func getChildDayEddingtonNumber() -> (value: Int16, plusOne: Int16)?{

        for l in childArray(){
            if l.isLeaf{
                if let p = l.period{
                    if p == Period.Day.rawValue{
                        return (l.value, l.plusOne)
                    }
                }
            }
            
        }
        
        return nil
    }

    
    
}
