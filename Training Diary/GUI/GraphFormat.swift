//
//  GraphFormat.swift
//  Training Diary
//
//  Created by Steven Lord on 24/11/2017.
//  Copyright © 2017 Steven Lord. All rights reserved.
//

import Cocoa

@objc class GraphFormat: NSObject{
    @objc var fill: Bool = false
    @objc var colour: NSColor
    @objc var fillGradientStart: NSColor
    @objc var fillGradientEnd: NSColor
    @objc var gradientAngle: CGFloat
    @objc var size: CGFloat = 1.0 // used for line width and size of points.
    @objc var opacity: CGFloat
    
    static let observerStrings: [String] = ["fill","colour","fillGradientStart","fillGradientEnd", "gradientAngle","size","opacity"]


    init(fill: Bool, colour: NSColor, fillGradientStart: NSColor, fillGradientEnd: NSColor, gradientAngle: CGFloat, size: CGFloat, opacity: CGFloat){
        self.fill = fill
        self.colour = colour
        self.fillGradientStart = fillGradientStart
        self.fillGradientEnd = fillGradientEnd
        self.gradientAngle = gradientAngle
        self.size = size
        self.opacity = opacity
    }
}
