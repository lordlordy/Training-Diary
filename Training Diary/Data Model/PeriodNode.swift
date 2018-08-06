//
//  PeriodNode.swift
//  Training Diary
//
//  Created by Steven Lord on 05/02/2018.
//  Copyright © 2018 Steven Lord. All rights reserved.
//

import Foundation

@objc protocol PeriodNode{
    
    @objc var name:             String      { get }
    @objc var children:         [PeriodNode]{ get }
    @objc var childCount:       Int         { get }
    @objc var totalKM:          Double      { get }
    @objc var totalSeconds:     TimeInterval{ get }
    @objc var totalTSS:         Double      { get }
    @objc var totalCTL:         Double     { get }
    @objc var swimKM:           Double      { get }
    @objc var swimSeconds:      TimeInterval{ get }
    @objc var swimTSS:          Double      { get }
    @objc var swimCTL:          Double      { get }
    @objc var bikeKM:           Double      { get }
    @objc var bikeSeconds:      TimeInterval{ get }
    @objc var bikeTSS:          Double      { get }
    @objc var bikeCTL:          Double      { get }
    @objc var runKM:            Double      { get }
    @objc var runSeconds:       TimeInterval{ get }
    @objc var runSecondsPerKM:  TimeInterval{ get }
    @objc var runTSS:           Double      { get }
    @objc var runCTL:           Double      { get }
    @objc var fromDate:         Date        { get }
    @objc var toDate:           Date        { get }
    @objc var isLeaf:           Bool        { get }
    @objc var isWorkout:        Bool        { get }
    @objc var isRoot:           Bool        { get }
    @objc var leafCount:        Int         { get }
    
    func add(child: PeriodNode)
    func inPeriod(_ p: PeriodNode) -> Bool
    func child(forName n: String) -> PeriodNode?
    
}
