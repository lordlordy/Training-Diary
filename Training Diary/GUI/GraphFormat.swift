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
    @objc var fill: Bool
    @objc var colour: NSColor
    @objc var fillGradientStart: NSColor
    @objc var fillGradientEnd: NSColor
    @objc var gradientAngle: CGFloat
    @objc var size: CGFloat // used for line width and size of points.

    init(fill f: Bool, colour c: NSColor, fillGradientStart fgs: NSColor, fillGradientEnd fge: NSColor, gradientAngle ga: CGFloat, size s: CGFloat){
        fill = f
        colour = c
        fillGradientStart = fgs
        fillGradientEnd = fgs
        gradientAngle = ga
        size = s
    }
}
