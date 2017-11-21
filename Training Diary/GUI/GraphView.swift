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
    
    enum Axis{
        case Primary, Secondary
    }
    enum ChartType{
        case Line, Bar, Point
    }
    
    struct GraphDefinition{
        let data: [Double]
        let axis: Axis
        let type: ChartType
        let fill: Bool
        let colour: NSColor
        let fillGradientStart: NSColor
        let fillGradientEnd: NSColor
        let gradientAngle: CGFloat
    }
    
    fileprivate struct Constants{
        static let phaseFactorForFinalLine: Double = 0.2
        static let labelWidth = 100.0
        static let labelHeight = 15.0
        //how far in from the view edge the axes are
        static let axisPadding = 30.0
    }
    
    fileprivate struct LabelOffset{
        enum Position: String{
            case Start, End
        }
        var position: Position  = Position.Start
        var x: Double     = 10.0
        var y: Double     = 10.0
    }
    
    @IBInspectable var xAxis1Colour: NSColor                     = .black
    @IBInspectable var xAxis1LabelColour: NSColor                = .black
    @IBInspectable var xAxis2Colour: NSColor                     = .orange
    @IBInspectable var xAxis2LabelColour: NSColor                = .black
    @IBInspectable var yAxisColour: NSColor                     = .black
    @IBInspectable var yAxisLabelColour: NSColor                = .black
    @IBInspectable var backgoundGradientStartColour: NSColor    = .lightGray
    @IBInspectable var backgroundGradientEndColour: NSColor     = .white
    @IBInspectable var backgroundGradientAngle: CGFloat         = 45.0
    @IBInspectable var lineWidth: CGFloat                       = 2.0
    @IBInspectable var data1Colour: NSColor                     = .blue
    @IBInspectable var data1FillGradientStartColour: NSColor    = .red
    @IBInspectable var data1GradientAngle: CGFloat              = 135.0
    @IBInspectable var data1Fill: Bool                          = true
    @IBInspectable var data2Colour: NSColor                     = .green
    @IBInspectable var data2FillGradientStartColour: NSColor    = .green
    @IBInspectable var data2GradientAngle: CGFloat              = 135.0
    @IBInspectable var data2Fill: Bool                          = false
    @IBInspectable var data3Colour: NSColor                     = .red
    @IBInspectable var data3FillGradientStartColour: NSColor    = .red
    @IBInspectable var data3Fill: Bool                          = false
    @IBInspectable var data3GradientAngle: CGFloat              = 135.0
    @IBInspectable var data4Colour: NSColor                     = .yellow
    @IBInspectable var data4FillGradientStartColour: NSColor    = .red
    @IBInspectable var data4GradientAngle: CGFloat              = 135.0
    @IBInspectable var data4Fill: Bool                          = false
    @IBInspectable var data4IsPoint: Bool                       = true

    private var labelNumberFormat: NumberFormatter {
        let nf = NumberFormatter()
        nf.numberStyle = NumberFormatter.Style.none
        return nf
    }
    
    private var yLabels: [NSTextField] = []
    private var xLabels: [NSTextField] = []

    var gapBetweenXAxis1Lines: Double = 50.0{
        didSet{ self.needsDisplay = true }
    }
    
    var gapBetweenXAxis2Lines: Double = 50.0{
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
    var data4: [Double] = []{
        didSet{ self.needsDisplay = true }
    }
    var xAxisLabelStrings: [String] = ["1","2","3","4","5","6","7","8","9","10","11"]{
        didSet{ self.needsDisplay = true}
    }

    override func prepareForInterfaceBuilder() {
        data1 = [0,5,10,15,18,17,21,15,9,18,19,20,17,15]
        data2 = [0,7,13,18,25,28,30,20,5,7,15,19,22,21]
        data3 = [0,-2,-3,-3,-7,-11,-9,-5,-4,11,4,1,-5,-6]
        data4 = [15,15,0,22,7,5,12,0,0,2,17,21,10,9]
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

        if let gradient = NSGradient(starting: backgoundGradientStartColour, ending: backgroundGradientEndColour){
            gradient.draw(in: dirtyRect, angle: backgroundGradientAngle )
        }

        let maxValues: [Double] = [data1.max() ?? 0.0, data2.max() ?? 0.0, data3.max() ?? 0.0]
        let minValues: [Double] = [data1.min() ?? 0.0, data2.min() ?? 0.0, data3.min() ?? 0.0]
        let overalMax: Double = maxValues.max() ?? 0.0
        let overalMin: Double = minValues.min() ?? 0.0


        if data1.count > 0{ drawBezierLine(data1, maxValue: overalMax, minValue: overalMin, dirtyRect, data1Colour, data1Fill) }
        if data2.count > 0{ drawBezierLine(data2, maxValue: overalMax, minValue: overalMin, dirtyRect, data2Colour,data2Fill) }
        if data3.count > 0{ drawBezierLine(data3, maxValue: overalMax, minValue: overalMin,  dirtyRect, data3Colour,data3Fill) }
        if data4.count > 0{
            if data4IsPoint{
                drawPoints(data4, maxValue: data4.max()!, minValue: data4.min()!, dirtyRect, data4Colour)
            }else{
                drawBezierLine(data4, maxValue: overalMax, minValue: overalMin, dirtyRect, data4Colour,data4Fill)
            }
        }
        //axis 1
        drawXAxes(maxValue: overalMax, minValue: overalMin, dirtyRect, colour: xAxis1Colour, lineGap: gapBetweenXAxis1Lines, labelOffset: LabelOffset(position: .Start, x: -(Constants.axisPadding - 2.0), y: 0.0) )
        //axis 2 - no lines yet - passed colour as Clear
        drawXAxes(maxValue: data4.max() ?? 0.0, minValue: data4.min() ?? 0.0, dirtyRect, colour: xAxis2Colour, lineGap: gapBetweenXAxis2Lines, labelOffset: LabelOffset(position: .End, x: 0.0, y: 0.0) )

        drawYAxes(dirtyRect, labelOffset: LabelOffset(position: .Start, x: -30.0, y: -(Constants.axisPadding - 10.0)) )

        for l in yLabels{ addSubview(l) }
        for l in xLabels{ addSubview(l) }
        
    }
    
    private func drawYAxes(_ dirtyRect: NSRect, labelOffset: LabelOffset){
        var count = 0.0
        for label in xAxisLabelStrings{
            let axisStartPoint = coordinatesInView(xValue: count, maxX: Double(xAxisLabelStrings.count-1), minX: 0.0, yValue: 0.0, maxY: 0.0, minY: 0.0, dirtyRect)
            let axisEndPoint = NSPoint(x: axisStartPoint.x, y: dirtyRect.maxY - CGFloat(Constants.axisPadding))
            drawAxis(from: axisStartPoint, to: axisEndPoint, colour: yAxisColour, label, labelOffset: labelOffset)
            count += 1.0
        }
    }
    
    private func drawXAxes( maxValue: Double, minValue: Double, _ dirtyRect: NSRect, colour: NSColor, lineGap: Double, labelOffset: LabelOffset){
        
        var factor = lineGap
        var strokeColour = colour
        
        let phaseFactor: CGFloat = CGFloat(exp(log(Constants.phaseFactorForFinalLine)/(maxValue/lineGap)))
        
        var axisStart = coordinatesInView(xValue: 0.0, maxX: 0.0, minX: 0.0, yValue: 0.0, maxY: maxValue, minY: minValue, dirtyRect)
        var axisEnd = NSPoint(x: dirtyRect.maxX - CGFloat(Constants.axisPadding), y: axisStart.y)
        drawAxis(from: axisStart, to: axisEnd, colour: strokeColour, "0", labelOffset: labelOffset)
        
        while factor <= maxValue{
            strokeColour = strokeColour.withAlphaComponent(strokeColour.alphaComponent * phaseFactor)
            strokeColour.setStroke()
            axisStart = coordinatesInView(xValue: 0.0, maxX: 0.0, minX: 0.0, yValue: factor, maxY: maxValue, minY: minValue, dirtyRect)
            axisEnd = NSPoint(x: dirtyRect.maxX - CGFloat(Constants.axisPadding), y: axisStart.y)
            drawAxis(from: axisStart, to: axisEnd, colour: strokeColour, labelNumberFormat.string(from: NSNumber(value: factor))!, labelOffset: labelOffset)
            factor += lineGap
        }
        
        factor = -gapBetweenXAxis1Lines
        strokeColour = xAxis1Colour

        while factor >= minValue{
            strokeColour = strokeColour.withAlphaComponent(strokeColour.alphaComponent * phaseFactor)
            strokeColour.setStroke()
            axisStart = coordinatesInView(xValue: 0.0, maxX: 0.0, minX: 0.0, yValue: factor, maxY: maxValue, minY: minValue, dirtyRect)
            axisEnd = NSPoint(x: dirtyRect.maxX - CGFloat(Constants.axisPadding), y: axisStart.y)
            drawAxis(from: axisStart, to: axisEnd, colour: strokeColour, labelNumberFormat.string(from: NSNumber(value: factor))!, labelOffset: labelOffset)
            factor -= lineGap
        }
    }
    
    private func drawAxis(from: NSPoint, to: NSPoint, colour: NSColor, _ labelString: String, labelOffset: LabelOffset){
        let path = NSBezierPath()
        colour.setStroke()
        path.move(to: from)
        path.line(to: to)
        path.setLineDash([2.0,1.0], count: 2, phase: 0.0)
        path.stroke()
        var labelPosition: NSPoint?
        switch labelOffset.position{
        case .Start:
            labelPosition = NSPoint(x: from.x + CGFloat(labelOffset.x), y: from.y + CGFloat(labelOffset.y))
        case .End:
            labelPosition  = NSPoint(x: to.x + CGFloat(labelOffset.x), y: to.y + CGFloat(labelOffset.y))
        }
        if let p = labelPosition{
            let label = createLabel(value: labelString, point: p, colour: yAxisLabelColour)
            xLabels.append(label)
        }
    }
    
    private func drawBezierLine(_ data: [Double], maxValue: Double, minValue: Double, _ dirtyRect: NSRect, _ colour: NSColor, _ fill: Bool ){
        
        let path = NSBezierPath()
        
        let origin = coordinatesInView(xValue: 0.0, maxX: Double(data.count), minX: 0.0, yValue: 0.0, maxY: maxValue, minY: minValue, dirtyRect)
        
        path.move(to: origin)
        var count = 0.0
        for point in data{
            let p = coordinatesInView(xValue:  count, maxX: Double(data.count), minX: 0.0, yValue: point, maxY: maxValue, minY: minValue, dirtyRect)
            path.line(to:p)
            count += 1.0
        }
        let endOfXAxis = coordinatesInView(xValue: Double(data.count), maxX: Double(data.count), minX: 0.0, yValue: 0.0, maxY: maxValue, minY: minValue, dirtyRect)

        path.line(to: endOfXAxis)
        
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
    
    private func coordinatesInView(xValue: Double, maxX: Double, minX: Double, yValue: Double, maxY: Double, minY: Double, _ dirtyRect: NSRect) -> NSPoint{
        
        // x2 so we get padding all around the chart
        let maxXInRect = Double(dirtyRect.maxX) - Constants.axisPadding * 2.0
        let maxYInRect = Double(dirtyRect.maxY) - Constants.axisPadding * 2.0
        let xRange = maxX - minX
        let yRange = maxY - minY
        var x = 0.0
        var y = 0.0
        if xRange > 0.0{
            x = (xValue - minX) * (maxXInRect / xRange)
        }
        if yRange > 0.0{
            y = (yValue - minY) * (maxYInRect / yRange)
        }
        
        return NSPoint(x: x + Constants.axisPadding, y: y + Constants.axisPadding)
    }
    
    private func drawPoints(_ data: [Double], maxValue: Double, minValue: Double, _ dirtyRect: NSRect, _ colour: NSColor ){
        var count = 0.0
        for point in data{
            if point > 0.1{
                let p = coordinatesInView(xValue: count, maxX: Double(data.count), minX: 0.0, yValue: point, maxY: maxValue, minY: minValue, dirtyRect)
                drawPoint(at: p, colour)
            }
            count += 1.0
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
    
    private func drawPoint(at: NSPoint, _ colour: NSColor){
        let path = NSBezierPath(ovalIn: NSRect(x: at.x-5.0, y: at.y-5.0, width: 5.0, height: 5.0))
        colour.setFill()
        path.fill()
    }
}
