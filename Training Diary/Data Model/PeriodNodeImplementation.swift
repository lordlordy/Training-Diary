//
//  PeriodNodeImplementation.swift
//  Training Diary
//
//  Created by Steven Lord on 05/02/2018.
//  Copyright © 2018 Steven Lord. All rights reserved.
//

import Foundation

class PeriodNodeImplementation: NSObject, PeriodNode{
        
    private var from: Date
    private var to: Date
    private var periodName: String
    private var childPeriods: [PeriodNode] = []
    private var rootNode: Bool
    
    init(name n: String, from: Date, to: Date, isRoot: Bool){
        periodName = n
        self.from = from
        self.to = to
        rootNode = isRoot
    }
    
    @objc var name: String { return periodName }
    @objc var children: [PeriodNode] { return childPeriods }
    @objc var childCount: Int { return children.count }
    
    func add(child: PeriodNode) { childPeriods.append(child) }
    
    @objc var totalKM: Double { return children.reduce(0.0, {$0 + $1.totalKM}) }
    @objc var totalSeconds: Double { return TimeInterval(children.reduce(0.0, {$0 + $1.totalSeconds})) }
    @objc var totalTSS: Double { return children.reduce(0.0, {$0 + $1.totalTSS}) }
    @objc var totalCTL: Double {
        let sorted = children.sorted(by: {$0.toDate > $1.toDate})
        if sorted.count > 0{
            return sorted[0].totalCTL
        }else{
            return 0.0
        }
    }
    @objc var swimKM: Double { return children.reduce(0.0, {$0 + $1.swimKM}) }
    @objc var swimSeconds: Double { return children.reduce(0.0, {$0 + $1.swimSeconds}) }
    @objc var swimTSS: Double { return children.reduce(0.0, {$0 + $1.swimTSS}) }
    @objc var swimCTL: Double {
        let sorted = children.sorted(by: {$0.toDate > $1.toDate})
        if sorted.count > 0{
            return sorted[0].swimCTL
        }else{
            return 0.0
        }
    }
    @objc var bikeKM: Double { return children.reduce(0.0, {$0 + $1.bikeKM}) }
    @objc var bikeSeconds: Double { return children.reduce(0.0, {$0 + $1.bikeSeconds}) }
    @objc var bikeTSS: Double { return children.reduce(0.0, {$0 + $1.bikeTSS}) }
    @objc var bikeCTL: Double {
        let sorted = children.sorted(by: {$0.toDate > $1.toDate})
        if sorted.count > 0{
            return sorted[0].bikeCTL
        }else{
            return 0.0
        }
    }
    @objc var runKM: Double { return children.reduce(0.0, {$0 + $1.runKM}) }
    @objc var runSeconds: Double { return children.reduce(0.0, {$0 + $1.runSeconds}) }
    @objc var runSecondsPerKM: TimeInterval {
        return runKM > 0 ? runSeconds / runKM : 0.0
    }
    @objc var runTSS: Double { return children.reduce(0.0, {$0 + $1.runTSS}) }
    @objc var runCTL: Double {
        let sorted = children.sorted(by: {$0.toDate > $1.toDate})
        if sorted.count > 0{
            return sorted[0].runCTL
        }else{
            return 0.0
        }
    }
    @objc var fromDate: Date {
        let childFromDate = children.map({$0.fromDate}).sorted(by: {$0 < $1})
        if childFromDate.count > 0{
            return childFromDate[0]
        }
        return Date()
    }
    @objc var toDate: Date {
        let childToDate = children.map({$0.toDate}).sorted(by: {$0 > $1})
        if childToDate.count > 0{
            return childToDate[0]
        }
        return Date()
    }
    @objc var isLeaf: Bool { return children.count == 0}
    @objc var isWorkout: Bool { return false}
    @objc var isRoot: Bool { return rootNode }
    
    @objc var leafCount: Int {
        if isLeaf{
            return 1
        }else{
            var count = 0
            for c in children{
                count += c.leafCount
            }
            return count
        }
    }
    
    func inPeriod(_ p: PeriodNode) -> Bool{
        return (p.fromDate <= from) && (p.toDate >= to)
    }
    
    func child(forName n: String) -> PeriodNode?{
        for node in children{
            if node.name == n{
                return node
            }
        }
        return nil
    }
}
