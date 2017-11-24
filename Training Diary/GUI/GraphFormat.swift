//
//  GraphFormat.swift
//  Training Diary
//
//  Created by Steven Lord on 24/11/2017.
//  Copyright © 2017 Steven Lord. All rights reserved.
//

import Cocoa

//this is intentionally set up as a class rather than struct so that it is passed by reference.

@objc class GraphFormat: NSObject{
    @objc var fill: Bool = false
    @objc var colour: NSColor
    @objc var fillGradientStart: NSColor
    @objc var fillGradientEnd: NSColor
    @objc var gradientAngle: CGFloat
    @objc var size: CGFloat = 1.0 // used for line width and size of points.
    
    static let observerStrings: [String] = ["fill","colour","fillGradientStart","fillGradientEnd", "gradientAngle","size"]


    init(fill: Bool, colour: NSColor, fillGradientStart: NSColor, fillGradientEnd: NSColor, gradientAngle: CGFloat, size: CGFloat){
        self.fill = fill
        self.colour = colour
        self.fillGradientStart = fillGradientStart
        self.fillGradientEnd = fillGradientEnd
        self.gradientAngle = gradientAngle
        self.size = size
    }
}
