//
//  GraphView.swift
//  Training Diary
//
//  Created by Steven Lord on 17/11/2017.
//  Copyright © 2017 Steven Lord. All rights reserved.
//

import Cocoa


/* Refactor this - generalise this to add as many lines as you like.
 */
@IBDesignable
class GraphView: NSView {
    
    fileprivate struct Constants{
        static let phaseFactorForXAxisLines: CGFloat = 0.8
        static let labelWidth = 100.0
        static let labelHeight = 15.0
        static let xAxisLabelHeight = 1.0
    }
    
    @IBInspectable var xAxisColour: NSColor                     = NSColor.black
    @IBInspectable var yAxisColour: NSColor                     = NSColor.black
    @IBInspectable var data1Colour: NSColor                     = NSColor.red
    @IBInspectable var data2Colour: NSColor                     = NSColor.green
    @IBInspectable var data3Colour: NSColor                     = NSColor.blue
    @IBInspectable var gradientStartColour: NSColor             = NSColor.lightGray
    @IBInspectable var gradientEndColour: NSColor               = NSColor.white
    @IBInspectable var gradientAngle: CGFloat                   = 45.0
    @IBInspectable var lineWidth: CGFloat                       = 2.0
    @IBInspectable var data1FillGradientStartColour: NSColor    = NSColor.red
    @IBInspectable var data1GradientAngle: CGFloat              = 135.0
    @IBInspectable var data1Fill: Bool                          = false
    @IBInspectable var data2FillGradientStartColour: NSColor    = NSColor.red
    @IBInspectable var data2GradientAngle: CGFloat              = 135.0
    @IBInspectable var data2Fill: Bool                          = false
    @IBInspectable var data3FillGradientStartColour: NSColor    = NSColor.red
    @IBInspectable var data3GradientAngle: CGFloat              = 135.0
    @IBInspectable var data3Fill: Bool                          = true
    @IBInspectable var yAxisLabelColour: NSColor                = NSColor.black
    @IBInspectable var xAxisLabelColour: NSColor                = NSColor.black
    
    private var labelNumberFormat: NumberFormatter {
        let nf = NumberFormatter()
        nf.numberStyle = NumberFormatter.Style.none
        return nf
    }
    
    private var yLabels: [NSTextField] = []
    private var xLabels: [NSTextField] = []

    var gapBetweenXAxisLines: Double = 50.0{
        didSet{ self.needsDisplay = true }
    }
    
    var data1: [Double] = []{
        didSet{ self.needsDisplay = true }
    }
    var data2: [Double] = []{
        didSet{ self.needsDisplay = true }
    }
    var data3: [Double] = []{
        didSet{ self.needsDisplay = true }
    }
    var xAxisLabelStrings: [String] = ["1","2","3","4","5","6","7","8","9","10","11"]{
        didSet{ self.needsDisplay = true}
    }

    override func prepareForInterfaceBuilder() {
        data1 = [0,5,10,15,18,17,21,15,9,18,19,20,17,15]
        data2 = [0,7,13,18,25,28,30,20,5,7,15,19,22,21]
        data3 = [0,-2,-3,-3,-7,-11,-9,-5,-4,11,4,1,-5,-6]
    }
    

    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        
        for l in yLabels{
            l.removeFromSuperview()
        }
        for l in xLabels{
            l.removeFromSuperview()
        }
        yLabels = []
        xLabels = []

        if let gradient = NSGradient(starting: gradientStartColour, ending: gradientEndColour){
            gradient.draw(in: dirtyRect, angle: gradientAngle )
        }
   //     NSColor.white.setFill()
     //   dirtyRect.fill()
    
        let maxValues: [Double] = [data1.max() ?? 0.0, data2.max() ?? 0.0, data3.max() ?? 0.0]
        let minValues: [Double] = [data1.min() ?? 0.0,data2.min() ?? 0.0,data3.min() ?? 0.0]
        let overalMax: Double = maxValues.max() ?? 0.0
        let overalMin: Double = minValues.min() ?? 0.0

        if data3.count > 0{
            drawBezierLine(data3, maxValue: overalMax, minValue: overalMin,  dirtyRect, data3Colour,true)
        }
        if data1.count > 0{
            drawBezierLine(data1, maxValue: overalMax, minValue: overalMin, dirtyRect, data1Colour, false)
        }
        if data2.count > 0{
            drawBezierLine(data2, maxValue: overalMax, minValue: overalMin, dirtyRect, data2Colour,false)
        }
        drawXAxes(maxValue: overalMax, minValue: overalMin, dirtyRect)
        drawYAxes(zeroYPosition: CGFloat(calcXAxis(overalMax, overalMin, dirtyRect)-Constants.labelHeight), dirtyRect)
        
        for l in yLabels{
            addSubview(l)
        }
        for l in xLabels{
            addSubview(l)
        }
        
    }
    
    private func drawYAxes(zeroYPosition y: CGFloat, _ dirtyRect: NSRect){
        let number  = xAxisLabelStrings.count
        let gap = dirtyRect.maxX / CGFloat(number - 1)
        var xPosition: CGFloat = 0.0
        
        for label in xAxisLabelStrings{
            drawYAxis(atXValue: Double(xPosition), toMaxY: Double(dirtyRect.maxY), colour: yAxisColour, label)
            xPosition += gap
        }
    }
    
    private func drawXAxes( maxValue: Double, minValue: Double, _ dirtyRect: NSRect){
        
        //this isn't quite right - take account if minimum is >0
        let zeroYAxis = calcXAxis(maxValue, minValue, dirtyRect)
        let increment = Double(dirtyRect.maxY)/(maxValue - minValue)
        let maxX = Double(dirtyRect.maxX)
        var factor = gapBetweenXAxisLines
        var strokeColour = xAxisColour
        
        drawXAxis(atYValue: zeroYAxis, toMaxX: maxX, colour: strokeColour, "0")
        
        while factor < maxValue{
            strokeColour = strokeColour.withAlphaComponent(strokeColour.alphaComponent * Constants.phaseFactorForXAxisLines)
            strokeColour.setStroke()
            drawXAxis(atYValue: zeroYAxis + factor * increment, toMaxX: maxX, colour: strokeColour, labelNumberFormat.string(from: NSNumber(value: factor))!)
            factor += gapBetweenXAxisLines
        }
        
        factor = -gapBetweenXAxisLines
        strokeColour = xAxisColour

        while factor > minValue{
            strokeColour = strokeColour.withAlphaComponent(strokeColour.alphaComponent * Constants.phaseFactorForXAxisLines)
            strokeColour.setStroke()
            drawXAxis(atYValue: zeroYAxis + factor * increment, toMaxX: maxX, colour: strokeColour, labelNumberFormat.string(from: NSNumber(value: factor))!)
            factor -= gapBetweenXAxisLines
        }
        
    }
    
    private func drawXAxis(atYValue y: Double, toMaxX x: Double, colour: NSColor, _ labelString: String){
        let path = NSBezierPath()
        colour.setStroke()
        path.move(to: NSPoint(x: 0.0, y: y))
        path.line(to: NSPoint(x: x, y: y))
        path.setLineDash([2.0,1.0], count: 2, phase: 0.0)
        path.stroke()
        let label = createLabel(value: labelString, point: CGPoint(x: x/2.0, y: y), colour: yAxisLabelColour)
        yLabels.append(label)
    }

    private func drawYAxis(atXValue x: Double, toMaxY y: Double, colour: NSColor, _ labelString: String){
        let path = NSBezierPath()
        colour.setStroke()
        path.move(to: NSPoint(x: x, y: 0))
        path.line(to: NSPoint(x: x, y: y))
        path.setLineDash([2.0,1.0], count: 2, phase: 0.0)
        path.stroke()
        let label = createLabel(value: labelString, point: CGPoint(x: x, y: Constants.xAxisLabelHeight), colour: yAxisLabelColour)
        xLabels.append(label)
    }

    private func calcXAxis(_ maxValue: Double, _ minValue: Double, _ dirtyRect: NSRect) -> Double{
        if maxValue - minValue == 0{
            return 0.0
        }else{
            return Double(dirtyRect.maxY) * (-minValue / (maxValue-minValue))
        }
    }
    
    private func drawBezierLine(_ data: [Double], maxValue: Double, minValue: Double, _ dirtyRect: NSRect, _ colour: NSColor, _ fill: Bool ){
        
        let maximumX = Double(dirtyRect.maxX)
        let maximumY = Double(dirtyRect.maxY)
        let range = maxValue - minValue
        
        let path = NSBezierPath()
        
        path.move(to: CGPoint.init(x: 0, y: maximumY * (-minValue / range) ))
        var count = 0.0
        for point in data{
            let x = maximumX*count/Double(data.count-1)
            let y = (Double(point)-minValue)*(maximumY/range)
            path.line(to: NSPoint(x: x, y: y))
            count += 1.0
        }
        path.line(to: NSPoint(x:maximumX,y:calcXAxis(maxValue, minValue, dirtyRect)))
        
        path.lineWidth = lineWidth
        colour.setStroke()
        colour.setFill()
        
        if fill{
            if let gradient = NSGradient(starting: data3FillGradientStartColour  , ending: colour){
                gradient.draw(in: path, angle: data3GradientAngle)
            }else{
                path.fill()
            }
        }else{
            path.stroke()
        }
    }
    
    private func createLabel(value: String, point: CGPoint, colour: NSColor) -> NSTextField {
        let label = NSTextField(frame: NSRect(origin: point, size: CGSize(width: Constants.labelWidth, height: Constants.labelHeight)))
        label.stringValue = value
        label.textColor = colour
        label.backgroundColor = NSColor.clear
        label.alignment = .left
        label.isBordered = false
       
        return label
    }
}
