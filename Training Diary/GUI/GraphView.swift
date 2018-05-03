//
//  GraphView.swift
//  Training Diary
//
//  Created by Steven Lord on 17/11/2017.
//  Copyright © 2017 Steven Lord. All rights reserved.
//

import Cocoa

//MARK: - Enums

enum Axis: String{
    case Primary, Secondary
    static var AllAxes = [Primary, Secondary]
}
enum ChartType: String{
    case Line, Bar, Point
    static var AllChartTypes = [Line, Bar, Point]
}

/* Refactor this - generalise this to add as many lines as you like.
 */
@IBDesignable
class GraphView: NSView {
    
    //MARK: - Inspectables - non user definable GUI formats
    
    @IBInspectable var primaryAxisColour: NSColor               = .black
    @IBInspectable var primaryAxisLabelColour: NSColor          = .black
    @IBInspectable var secondaryAxisColour: NSColor             = .white
    @IBInspectable var secondaryAxisLabelColour: NSColor        = .white
    @IBInspectable var xAxisColour: NSColor                     = .black
    @IBInspectable var xAxisLabelColour: NSColor                = .black
    
    //MARK: - User settable GUI formats
    
    @objc dynamic var backgroundGradientStartColour: NSColor    = .gray { didSet{ self.needsDisplay = true }}
    @objc dynamic var backgroundGradientEndColour: NSColor      = .lightGray { didSet{ self.needsDisplay = true }}
    @objc dynamic var backgroundGradientAngle: CGFloat          = 45.0 { didSet{ self.needsDisplay = true }}
    @objc var numberOfPrimaryAxisLines: Int                     = 6{ didSet{ self.needsDisplay = true }}
    @objc var numberOfSecondaryAxisLines: Int                   = 6{ didSet{ self.needsDisplay = true }}

    //MARK: - public vars
    
    public var primaryAxisMinimumOverride: Double?
    public var secondaryAxisMinimumOverride: Double?
    public var xAxisLabelStrings: [String] = ["1","2","3","4","5","6","7","8","9","10","11"]{
        didSet{ self.needsDisplay = true}
    }
    public var graphs = Set<GraphDefinition>()
    public var chartTitle: String? { didSet{ self.needsDisplay = true } }
    
 //   public var primaryAxisNumberFormatter: NumberFormatter = NumberFormatter()
   // public var secondaryAxisNumberFormatter: NumberFormatter = NumberFormatter()

    //MARK: - Graph management
    
    func add(graph: GraphDefinition){
        graphs.insert(graph)
        startObserving(graph)
        updatePlotBounds()
        needsDisplay = true
    }
    func remove(graph: GraphDefinition){
        endObserving(graph)
        graphs.remove(graph)
        updatePlotBounds()
        needsDisplay = true
    }
    
    func clearGraphs(){
        for g in graphs{
            endObserving(g)
            graphs.remove(g)
        }
        needsDisplay = true
    }
    
    //MARK: - Overrides
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        //currently don't switch ... all observed values are assume to require a redraw. Keep an eye on this
        needsDisplay = true
    }
    
    override func prepareForInterfaceBuilder() {
        let graph = GraphDefinition(name: "Test", data: [(date: Date(),23.5)], axis: .Primary, type: .Point, format: GraphFormat.init(fill: false, colour: .red, fillGradientStart: .red, fillGradientEnd: .red, gradientAngle: 0.0, size: 2.0, opacity: 1.0), drawZeroes: false, priority: 1  )
        graphs.insert(graph)
    }
    
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        
        if noData { return }
        
        updatePlotBounds()
        
        for l in xLabels{ l.removeFromSuperview() }
        for l in yLabels{ l.removeFromSuperview() }
        xLabels = []
        yLabels = []
        
        titleLabel?.removeFromSuperview()
        titleLabel = nil

        if let gradient = NSGradient(starting: backgroundGradientStartColour, ending: backgroundGradientEndColour){
            gradient.draw(in: dirtyRect, angle: backgroundGradientAngle )
        }


        for g in priorityOrderedGraphs{
            if g.display{
                draw(graph: g, inDirtyRect: dirtyRect)
            }
        }
        
        //TO DO - should be able to tidy up creation of axis / labels.
        //axis 1
        drawYAxes(forAxis: .Primary, maxValue: graphsYMaximum(forAxis: .Primary), minValue: graphsYMinimum(forAxis: .Primary) ?? 0.0, dirtyRect, colour: primaryAxisColour, lineGap: gapBetweenPrimaryAxisLines, labelOffset: LabelOffset(position: .Start, x: -(Constants.axisPadding - 2.0), y: 0.0), labelColour: primaryAxisLabelColour )
        //axis 2 -
        if getGraphs(forAxis: .Secondary).count > 0{
            drawYAxes(forAxis: .Secondary, maxValue: graphsYMaximum(forAxis: .Secondary), minValue: graphsYMinimum(forAxis: .Secondary) ?? 0.0, dirtyRect, colour: secondaryAxisColour, lineGap: gapBetweenSecondaryAxisLines, labelOffset: LabelOffset(position: .End, x: 0.0, y: 0.0), labelColour: secondaryAxisLabelColour )
        }

        drawXAxes(dirtyRect, labelOffset: LabelOffset(position: .Start, x: -30.0, y: -(Constants.axisPadding - 10.0)) )

        for l in xLabels{ addSubview(l) }
        for l in yLabels{ addSubview(l) }
        
        if let titleName = chartTitle{
        
            let titleXPosition = dirtyRect.maxX / 2.0
            let titleYPosition = dirtyRect.maxY - CGFloat(Constants.axisPadding*0.75)
        
            titleLabel = createLabel(value: titleName, point: CGPoint(x: titleXPosition, y: titleYPosition), size: CGSize(width: Constants.labelWidth * 3, height: Constants.labelHeight), colour: .black)
        
            addSubview(titleLabel!)
        }
    }
    
    
 
    
    //MARK: - PRIVATE
    
    //MARK: - Private vars that set out plot bounds / scale
    private var _minX = 0.0
    private var _maxX: Double = 0.0
    private var _minYPrimary: Double = 0.0
    private var _maxYPrimary: Double = 0.0
    private var _minYSecondary: Double = 0.0
    private var _maxYSecondary: Double = 0.0
    // note the order here. High priority graphs will show on top ... so are drawn last. So this order descending
    private var priorityOrderedGraphs: [GraphDefinition]{ return graphs.sorted(by: {$0.priority > $1.priority}) }
    
    private var noData: Bool{
        var count = 0
        for graph in graphs{
            count += graph.data.count
        }
        return (count == 0)
    }
    

    
    private var xLabels: [NSTextField] = []
    private var yLabels: [NSTextField] = []
    private var titleLabel: NSTextField?
    private var gapBetweenPrimaryAxisLines:     Double{ return calcAxisLineGap(forAxis: .Primary) }
    private var gapBetweenSecondaryAxisLines:   Double{ return calcAxisLineGap(forAxis: .Secondary) }

    
    private struct Constants{
        static let phaseFactorForFinalLine: Double = 0.2
        static let labelWidth = 100.0
        static let labelHeight = 15.0
        static let pointDiameter: CGFloat = 3.0
        //how far in from the view edge the axes are
        static let axisPadding = 30.0
        static let zero = 0.1
    }
    
    private struct LabelOffset{
        enum Position: String{
            case Start, End
        }
        var position: Position  = Position.Start
        var x: Double     = 10.0
        var y: Double     = 10.0
    }
    
    //MARK: - Private funcs
    
    private func coordinatesInView(xValue: Double, yValue: Double, forAxis axis: Axis, _ dirtyRect: NSRect) -> NSPoint{
        
        var _minY = 0.0
        var _maxY = 0.0
        
        switch axis{
        case .Primary:
            _minY = _minYPrimary
            _maxY = _maxYPrimary
        case .Secondary:
            _minY = _minYSecondary
            _maxY = _maxYSecondary
        }
        
        // x2 so we get padding all around the chart
        let maxXInRect = Double(dirtyRect.maxX) - Constants.axisPadding * 2.0
        let maxYInRect = Double(dirtyRect.maxY) - Constants.axisPadding * 2.0
        let xRange = _maxX - _minX
        let yRange = _maxY - _minY
        var x = 0.0
        var y = 0.0
        if xRange > 0.0{
            x = (xValue - _minX) * (maxXInRect / xRange)
        }
        if yRange > 0.0{
            y = (yValue - _minY) * (maxYInRect / yRange)
        }
        
        return NSPoint(x: x + Constants.axisPadding, y: y + Constants.axisPadding)
    }
    
    private func getGraphs(forAxis axis: Axis) -> [GraphDefinition]{
        var result: [GraphDefinition] = []
        for graph in graphs{
            if graph.axis == axis{ result.append(graph) }
        }
        return result
    }
    

    
    private func startObserving(_ graph: GraphDefinition){
        for keyPath in GraphFormat.observerStrings{
            graph.format.addObserver(self, forKeyPath: keyPath, options: .new, context: nil)
            
        }
        for keyPath in GraphDefinition.observerStrings{
            graph.addObserver(self, forKeyPath: keyPath, options: .new, context: nil)
            
        }
    }
    
    private func endObserving(_ graph: GraphDefinition){
        for keyPath in GraphFormat.observerStrings{
            graph.format.removeObserver(self, forKeyPath: keyPath)
        }
        for keyPath in GraphDefinition.observerStrings{
            graph.removeObserver(self, forKeyPath: keyPath)
        }
    }
    
    private func getMinimumOverride(forAxis axis: Axis) -> Double?{
        switch axis{
        case .Primary: return primaryAxisMinimumOverride
        case .Secondary: return secondaryAxisMinimumOverride
        }
    }
    
    private func graphsYMaximum(forAxis axis: Axis) -> Double{
        var maximums: [Double] = [0.0] // ensure maximum is always at least zero
        let graphs = getGraphs(forAxis: axis).filter({$0.display})
        if graphs.count > 0{
            for graph in graphs{
                if graph.data.count > 0{
                    maximums.append(graph.data.map{$0.value}.max()!)
                }
            }
        }
        return maximums.max()!
    }
    
    private func graphsYMinimum(forAxis axis: Axis) -> Double?{
        if let override = getMinimumOverride(forAxis: axis){ return override }
        var minimums: [Double] = []
        let graphs = getGraphs(forAxis: axis).filter({$0.display})
        if graphs.count > 0{
            for graph in graphs{
                if graph.data.count > 0{
                    minimums.append(graph.data.map{$0.value}.min()!)
                }
            }
        }
        return minimums.min()
    }
    
    private func graphsXMinimumDate() -> Date?{
        var minimums: [Date] = []
        for graph in graphs{
            if graph.data.count > 0{
                minimums.append(graph.data.map({$0.date}).min()!)
            }
        }
        if minimums.count > 0{
            return minimums.min()!
        }
        return nil
    }
    
    
    private func graphsXMaximumDate() -> Date?{
        var maximums: [Date] = []
        for graph in graphs{
            if graph.data.count > 0{
                maximums.append(graph.data.map({$0.date}).max()!)
            }
        }
        if maximums.count > 0{
            return maximums.max()!
        }
        return nil
    }
    
    private func calcAxisLineGap(forAxis a: Axis) -> Double{
        
        let yMax = graphsYMaximum(forAxis: a)
        let yMin = graphsYMinimum(forAxis: a)
        var numberOfAxisLines = 1.0
        
        var range: Double = yMax - (yMin  ?? 0.0)
        if range == 0.0{ range = 10.0}
        
        switch a{
        case .Primary: numberOfAxisLines =   Double(numberOfPrimaryAxisLines)
        case .Secondary: numberOfAxisLines =  Double(numberOfSecondaryAxisLines)
        }
        
        var result: Double = range / numberOfAxisLines

        
        //want to give axes reasonable 'round' labels. If they don't start from zero we will just leave as is. So first we check if the origin is included
        let originIncluded: Bool = (range >= yMax && range >= abs(yMin ?? 0.0) )
        
//        if originIncluded{
            //do some rounding
            switch range{
            case 0...1.5:
                result = max(0.1, round(range / numberOfAxisLines, toNearest: 0.1))
            case 1.5...7.0:
                result = max(1.0, round(range / numberOfAxisLines, toNearest: 1.0))
            case 7.0...14.0:
                result = max(2.0, round(range / numberOfAxisLines, toNearest: 2.0))
            case 14.0...35.0:
                result = max(5.0, round(range / numberOfAxisLines, toNearest: 5.0))
            case 35.0...70.0:
                result = max(10.0, round(range / numberOfAxisLines, toNearest: 10.0))
            case 70.0...140.0:
                result = max(20.0, round(range / numberOfAxisLines, toNearest: 20.0))
            case 140.0...200.0:
                result = max(25.0, round(range / numberOfAxisLines, toNearest: 25.0))
            case 200.0...350.0:
                result = max(50.0, round(range / numberOfAxisLines, toNearest: 50.0))
            case 350.0...700.0:
                result = max(100.0, round(range / numberOfAxisLines, toNearest: 100.0))
            case 700.0...1200.0:
                result = max(200.0, round(range / numberOfAxisLines, toNearest: 200.0))
            case 1200.0...2000.0:
                result = max(250.0, round(range / numberOfAxisLines, toNearest: 250.0))
            case 2000.0...3500.0:
                result = max(500.0, round(range / numberOfAxisLines, toNearest: 500.0))
            default:
                result = max(1000.0, round(range / numberOfAxisLines, toNearest: 1000.0))
            }
//        }
        return result

        
    }
    
    private func round(_ d: Double, toNearest: Double) -> Double{
            let n = 1/toNearest
            let numberToRound = d * n
            return numberToRound.rounded() / n
    }
    
    private func drawXAxes(_ dirtyRect: NSRect, labelOffset: LabelOffset){
        var count = 0.0
        if let maxDate = graphsXMaximumDate(){
            if let minDate = graphsXMinimumDate(){
                let factor = maxDate.timeIntervalSince(minDate) / Double(xAxisLabelStrings.count - 1)
                for label in xAxisLabelStrings{
                    let axisStartPoint = coordinatesInView(xValue: count, yValue: graphsYMinimum(forAxis: .Primary) ?? 0.0, forAxis: .Primary, dirtyRect)
                    let axisEndPoint = NSPoint(x: axisStartPoint.x, y: dirtyRect.maxY - CGFloat(Constants.axisPadding))
                    drawAxis(from: axisStartPoint, to: axisEndPoint, colour: xAxisColour, label, labelOffset: labelOffset, labelColour: xAxisLabelColour)
                    count += factor
                }

            }
        }
    }
    
    private func drawYAxes(forAxis axis: Axis, maxValue: Double, minValue: Double, _ dirtyRect: NSRect, colour: NSColor, lineGap: Double, labelOffset: LabelOffset, labelColour: NSColor ){
        
        var factor = lineGap
        if minValue > lineGap { factor = minValue }
        var strokeColour = colour
        
        let numberFormatter = NumberFormatter()
        if lineGap < 1{
            numberFormatter.format = "0.0"
        }
        if maxValue > 999{
            numberFormatter.format = "#,##0"
        }
        
        let phaseFactor: CGFloat = CGFloat(exp(log(Constants.phaseFactorForFinalLine)/(maxValue/lineGap)))
        
        var axisStart = coordinatesInView(xValue: 0.0, yValue: 0.0, forAxis: axis, dirtyRect)
        var axisEnd = NSPoint(x: dirtyRect.maxX - CGFloat(Constants.axisPadding), y: axisStart.y)
        drawAxis(from: axisStart, to: axisEnd, colour: strokeColour, "0", labelOffset: labelOffset, labelColour: labelColour)
        
        while factor <= maxValue{
            strokeColour = strokeColour.withAlphaComponent(strokeColour.alphaComponent * phaseFactor)
            strokeColour.setStroke()
            axisStart = coordinatesInView(xValue: 0.0, yValue: factor, forAxis: axis, dirtyRect)
            axisEnd = NSPoint(x: dirtyRect.maxX - CGFloat(Constants.axisPadding), y: axisStart.y)
            drawAxis(from: axisStart, to: axisEnd, colour: strokeColour, numberFormatter.string(from: NSNumber(value: factor))!, labelOffset: labelOffset, labelColour: labelColour)
            factor += lineGap
        }
        
        if minValue < 0.0{
            factor = -lineGap
            strokeColour = colour
            
            while factor >= minValue{
                strokeColour = strokeColour.withAlphaComponent(strokeColour.alphaComponent * phaseFactor)
                strokeColour.setStroke()
                axisStart = coordinatesInView(xValue: 0.0, yValue: factor, forAxis: .Primary, dirtyRect)
                axisEnd = NSPoint(x: dirtyRect.maxX - CGFloat(Constants.axisPadding), y: axisStart.y)
                drawAxis(from: axisStart, to: axisEnd, colour: strokeColour, numberFormatter.string(from: NSNumber(value: factor))!, labelOffset: labelOffset, labelColour: labelColour)
                factor -= lineGap
            }

        }
        
    }
    
    private func drawAxis(from: NSPoint, to: NSPoint, colour: NSColor, _ labelString: String, labelOffset: LabelOffset, labelColour: NSColor){
        let path = NSBezierPath()
        colour.setStroke()
        path.move(to: from)
        path.line(to: to)
        let dash: [CGFloat] = [2.0,2.0]
        path.setLineDash(dash, count: 2, phase: 0.0)
        path.stroke()
        var labelPosition: NSPoint?
        switch labelOffset.position{
        case .Start:
            labelPosition = NSPoint(x: from.x + CGFloat(labelOffset.x), y: from.y + CGFloat(labelOffset.y))
        case .End:
            labelPosition  = NSPoint(x: to.x + CGFloat(labelOffset.x), y: to.y + CGFloat(labelOffset.y))
        }
        if let p = labelPosition{
            let label = createLabel(value: labelString, point: p, size: CGSize(width: Constants.labelWidth, height: Constants.labelHeight), colour: labelColour)
            yLabels.append(label)
        }
    }
    
    private func draw(graph: GraphDefinition, inDirtyRect dirtyRect: NSRect ){
        switch graph.type{
        case .Bar:      drawBar(graph: graph, inDirtyRect: dirtyRect)
        case .Line:     drawLine(graph: graph, inDirtyRect: dirtyRect)
        case .Point:    drawPoints(graph: graph, inDirtyRect: dirtyRect)
        }

        
    }

    private func drawBar(graph: GraphDefinition, inDirtyRect dirtyRect: NSRect ){
        if graph.data.count == 0 { return } // no data
        
        let path = NSBezierPath()
        if let dash = graph.dash{
            path.setLineDash(dash, count: dash.count, phase: 0.0)
        }
        
        
        if let startDate = graphsXMinimumDate(){
            if let endDate = graphsXMaximumDate(){
                
                //start from origin
                let origin = coordinatesInView(xValue: 0.0, yValue: 0.0, forAxis: graph.axis, dirtyRect)
                path.move(to: origin)
                
                var previousPoint = origin
                
                //this has bar end at x-value. Should amend this to centre at x-value
                for point in graph.data {
                    let p = coordinatesInView(xValue:  point.date.timeIntervalSince(startDate), yValue: point.value,forAxis: graph.axis, dirtyRect)
                
                    path.line(to: NSPoint(x: previousPoint.x, y: p.y))
                    path.line(to:p)
                    path.line(to: NSPoint(x:p.x,y:origin.y))
               
                    previousPoint = p
                }
                
                if graph.format.fill{
                    let endOfXAxis = coordinatesInView(xValue: endDate.timeIntervalSince(startDate), yValue: 0.0,forAxis: graph.axis, dirtyRect)
                    path.line(to: endOfXAxis)
                    let startColour = graph.format.fillGradientStart.withAlphaComponent(graph.format.opacity)
                    let endColout = graph.format.fillGradientEnd.withAlphaComponent(graph.format.opacity)
                    if let gradient = NSGradient(starting: startColour , ending: endColout){
                        gradient.draw(in: path, angle: graph.format.gradientAngle)
                    }else{
                        path.fill()
                    }
                }
                path.lineWidth = graph.format.size
                graph.format.colour.withAlphaComponent(graph.format.opacity).setStroke()
                
                path.stroke()
            }
        }    }
        
    
    private func drawLine(graph: GraphDefinition, inDirtyRect dirtyRect: NSRect ){
        
        if graph.data.count == 0 { return } // no data
        
        let path = NSBezierPath()
        if let dash = graph.dash{
            path.setLineDash(dash, count: dash.count, phase: 0.0)
        }
        
        
        if let startDate = graphsXMinimumDate(){
            if let endDate = graphsXMaximumDate(){
                
                var firstPoint: Bool = true
                
                if graph.startFromOrigin{
                    let origin = coordinatesInView(xValue: 0.0, yValue: 0.0, forAxis: graph.axis, dirtyRect)
                    path.move(to: origin)
                    firstPoint = false
                }
                
                for point in graph.data {
                    let p = coordinatesInView(xValue:  point.date.timeIntervalSince(startDate), yValue: point.value,forAxis: graph.axis, dirtyRect)
                    if graph.drawZero || abs(point.value) >= Constants.zero{
                        if firstPoint{
                            path.move(to: p)
                            firstPoint = false
                        }else{
                            path.line(to:p)

                        }
                    }

                }
                
                if graph.format.fill{
                    let endOfXAxis = coordinatesInView(xValue: endDate.timeIntervalSince(startDate), yValue: 0.0,forAxis: graph.axis, dirtyRect)
                    path.line(to: endOfXAxis)
                    if let gradient = NSGradient(starting: graph.format.fillGradientStart  , ending: graph.format.fillGradientEnd){
                        gradient.draw(in: path, angle: graph.format.gradientAngle)
                    }else{
                        path.fill()
                    }
                }
                path.lineWidth = graph.format.size
                graph.format.colour.setStroke()
                path.stroke()
            }
        }

    }
    
    private func drawPoints(graph: GraphDefinition, inDirtyRect dirtyRect: NSRect ){
        
        if graph.data.count == 0 {return} // no data
        
        if let startDate = graphsXMinimumDate(){
            for point in graph.data{
                let p = coordinatesInView(xValue:  point.date.timeIntervalSince(startDate), yValue: point.value, forAxis: graph.axis, dirtyRect)
                if graph.drawZero || abs(point.value) >= Constants.zero {
                        drawPoint(at: p, graphDefinition: graph)
                }
            }
        }
    }


    private func drawPoint(at: NSPoint, graphDefinition gd: GraphDefinition){
        let path = NSBezierPath(ovalIn: NSRect(x: at.x-gd.format.size/2, y: at.y-gd.format.size/2, width: gd.format.size, height: gd.format.size))
        
        if gd.format.fill{
            if let gradient = NSGradient(starting: gd.format.fillGradientStart, ending: gd.format.fillGradientEnd){
                gradient.draw(in: path, angle: gd.format.gradientAngle)
            }
        }
        
        gd.format.colour.setStroke()
        path.stroke()
    }
    
    private func createLabel(value: String, point: CGPoint, size: CGSize, colour: NSColor) -> NSTextField {
        let label = NSTextField(frame: NSRect(origin: point, size: size))
        label.stringValue = value
        label.textColor = colour
        label.backgroundColor = NSColor.clear
        label.alignment = .left
        label.isBordered = false
        
        return label
    }
    
    
    private func updatePlotBounds(){

        if let minXDate = graphsXMinimumDate(){
            if let maxXDate = graphsXMaximumDate(){
                _minX = 0.0 //taking minimum date as zero
                _maxX = maxXDate.timeIntervalSince(minXDate)
                _minYPrimary = graphsYMinimum(forAxis: .Primary)  ?? 0.0
                _maxYPrimary = graphsYMaximum(forAxis: .Primary)
                _minYSecondary = graphsYMinimum(forAxis: .Secondary) ?? 0.0
                _maxYSecondary = graphsYMaximum(forAxis: .Secondary)
            }
        }
    }
    

}
