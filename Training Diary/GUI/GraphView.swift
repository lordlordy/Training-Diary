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
    
    enum Axis: String{
        case Primary, Secondary
        static var AllAxes = [Primary, Secondary]
    }
    enum ChartType: String{
        case Line, Bar, Point
        static var AllChartTypes = [Line, Bar, Point]
    }
    
    //this is intentionally a class rather than struct as I want to pass it around by reference
    @objc class GraphDefinition: NSObject{
        var data: [(date: Date, value: Double)] = [] 
        var name: String
        var axis: Axis = Axis.Primary
        var type: ChartType = ChartType.Line
        
        @objc dynamic var axisString: String{
            get{ return axis.rawValue }
            set{ if let a = Axis(rawValue: newValue){ axis = a } }
        }
        @objc dynamic var typeString: String{
            get{ return type.rawValue }
            set{ if let t = ChartType(rawValue: newValue){ type = t }}
        }
        
        @objc var display: Bool = true
        @objc var format: GraphFormat
        //need to figure this out. For some reason if I remove this and use colour in GraphFormat I get an uncaught exception.
        @objc var colour: NSColor{
            get{return format.colour}
            set{format.colour = newValue}
        }
        @objc var priority: Int = 1 //This gives relative priority of drawing. Remember that things draw on top of each other
        
        static var observerStrings: [String] = ["axisString","typeString","display","format","colour","priority"]
        
        init(name: String,axis: Axis, type: ChartType, format: GraphFormat,  priority: Int){
            self.axis = axis
            self.type = type
            self.format = format
            self.name = name
            self.priority = priority
        }
        
        convenience init(name: String, data: [(date: Date, value: Double)], axis: Axis, type: ChartType, format: GraphFormat, priority: Int){
        
            self.init(name: name, axis: axis, type: type, format: format, priority: priority)
            self.data = data
        }
    }
    
    private var graphs: [String:GraphDefinition]                 = [:]{
        didSet{
            print("didSet on graph dictionary in Graphview")
            print(graphs)
            
        }
        
    }
   // note the order here. High priority graphs will show on top ... so are drawn last. So this order descending
    private var priorityOrderedGraphs: [GraphDefinition]{ return graphs.values.sorted(by: {$0.priority > $1.priority}) }

    private func getPrimaryAxisGraphs() ->      [GraphDefinition]{
        var result: [GraphDefinition] = []
        for graph in graphs.values{
            if graph.axis == Axis.Primary{ result.append(graph) }
            
        }
        return result
    }

    private func getSecondaryAxisGraphs() ->   [GraphDefinition]{
        var result: [GraphDefinition] = []
        for graph in graphs.values{
            if graph.axis == Axis.Secondary{ result.append(graph) }
            
        }
        return result
    }
    
    func add(graph: GraphDefinition){
        graphs[graph.name] = graph
        startObserving(graph)
    }
    func remove(graph: GraphDefinition){
        endObserving(graph)
        graphs.removeValue(forKey: graph.name)
    }
    
    private func startObserving(_ graph: GraphDefinition){
        for keyPath in GraphFormat.observerStrings{ graph.format.addObserver(self, forKeyPath: keyPath, options: .new, context: nil)}
        for keyPath in GraphDefinition.observerStrings{ graph.addObserver(self, forKeyPath: keyPath, options: .new, context: nil)}
    }
    
    private func endObserving(_ graph: GraphDefinition){
        for keyPath in GraphFormat.observerStrings{
            graph.format.removeObserver(self, forKeyPath: keyPath)
        }
        for keyPath in GraphDefinition.observerStrings{
            graph.removeObserver(self, forKeyPath: keyPath)
        }
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        //currently don't switch ... all observed values are assume to require a redraw. Keep an eye on this
        needsDisplay = true
    }
    
    
    
    private func graphsMaximum(forAxis: Axis) -> Double{
        var maximums: [Double] = [0.0] // ensure maximum is always at least zero
        var graphs: [GraphDefinition] = []
        switch forAxis{
        case .Primary: graphs = getPrimaryAxisGraphs()
        case .Secondary: graphs = getSecondaryAxisGraphs()
        }
        if graphs.count > 0{
            for graph in graphs{
                if graph.data.count > 0{
                    maximums.append(graph.data.map{$0.value}.max()!)
                }
            }
        }
        return maximums.max()!
    }

    private func graphsMinimum(forAxis: Axis) -> Double{
        var minimums: [Double] = [0.0] //ensures minimum is always at least zero
        var graphs: [GraphDefinition] = []
        switch forAxis{
        case .Primary: graphs = getPrimaryAxisGraphs()
        case .Secondary: graphs = getSecondaryAxisGraphs()
        }
        if graphs.count > 0{
            for graph in graphs{
                if graph.data.count > 0{
                    minimums.append(graph.data.map{$0.value}.min()!)
                }
            }
        }
        return minimums.min()!
    }
    
    fileprivate struct Constants{
        static let phaseFactorForFinalLine: Double = 0.2
        static let labelWidth = 100.0
        static let labelHeight = 15.0
        static let pointDiameter: CGFloat = 3.0
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
    
    @IBInspectable var primaryAxisColour: NSColor               = .black
    @IBInspectable var primaryAxisLabelColour: NSColor          = .black
    @IBInspectable var secondaryAxisColour: NSColor             = .white
    @IBInspectable var secondaryAxisLabelColour: NSColor        = .white
    @IBInspectable var yAxisColour: NSColor                     = .black
    @IBInspectable var yAxisLabelColour: NSColor                = .black
    @IBInspectable var backgoundGradientStartColour: NSColor    = .gray
    @IBInspectable var backgroundGradientEndColour: NSColor     = .lightGray
    @IBInspectable var backgroundGradientAngle: CGFloat         = 45.0

    private var labelNumberFormat: NumberFormatter {
        let nf = NumberFormatter()
        nf.numberStyle = NumberFormatter.Style.none
        return nf
    }
    
    private var yLabels: [NSTextField] = []
    private var xLabels: [NSTextField] = []

    @objc var numberOfPrimaryAxisLines: Int = 6{ didSet{ self.needsDisplay = true }}
    @objc var numberOfSecondaryAxisLines: Int = 6{ didSet{ self.needsDisplay = true }}
    
    private var gapBetweenPrimaryAxisLines:     Double{ return calcAxisLineGap(forAxis: .Primary) }
    private var gapBetweenSecondaryAxisLines:   Double{ return calcAxisLineGap(forAxis: .Primary) }
    
    var xAxisLabelStrings: [String] = ["1","2","3","4","5","6","7","8","9","10","11"]{
        didSet{ self.needsDisplay = true}
    }
    
    private func calcAxisLineGap(forAxis a: Axis) -> Double{
        var result = 100.0
        
        var range = graphsMaximum(forAxis: a) - graphsMinimum(forAxis: a)
        if range == 0.0{ range = 10.0}
        switch a{
        case .Primary: result = range / Double(numberOfPrimaryAxisLines)
        case .Secondary: result = range / Double(numberOfSecondaryAxisLines)
        }
        
        return result
    }

    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        
        for l in yLabels{ l.removeFromSuperview() }
        for l in xLabels{ l.removeFromSuperview() }
        yLabels = []
        xLabels = []

        if let gradient = NSGradient(starting: backgoundGradientStartColour, ending: backgroundGradientEndColour){
            gradient.draw(in: dirtyRect, angle: backgroundGradientAngle )
        }


        for g in priorityOrderedGraphs{
            if g.display{
                draw(graph: g, inDirtyRect: dirtyRect)
            }
        }
        
        //TO DO - should be able to tidy up creation of axis / labels.
        //axis 1
        drawXAxes(maxValue: graphsMaximum(forAxis: .Primary), minValue: graphsMinimum(forAxis: .Primary), dirtyRect, colour: primaryAxisColour, lineGap: gapBetweenPrimaryAxisLines, labelOffset: LabelOffset(position: .Start, x: -(Constants.axisPadding - 2.0), y: 0.0), labelColour: primaryAxisLabelColour )
        //axis 2 - no lines yet - passed colour as Clear
        drawXAxes(maxValue: graphsMaximum(forAxis: .Secondary), minValue: graphsMinimum(forAxis: .Secondary), dirtyRect, colour: secondaryAxisColour, lineGap: gapBetweenSecondaryAxisLines, labelOffset: LabelOffset(position: .End, x: 0.0, y: 0.0), labelColour: secondaryAxisLabelColour )

        drawYAxes(dirtyRect, labelOffset: LabelOffset(position: .Start, x: -30.0, y: -(Constants.axisPadding - 10.0)) )

        for l in yLabels{ addSubview(l) }
        for l in xLabels{ addSubview(l) }
        
    }
    
    private func drawYAxes(_ dirtyRect: NSRect, labelOffset: LabelOffset){
        var count = 0.0
        for label in xAxisLabelStrings{
            let axisStartPoint = coordinatesInView(xValue: count, maxX: Double(xAxisLabelStrings.count-1), minX: 0.0, yValue: 0.0, maxY: 0.0, minY: 0.0, dirtyRect)
            let axisEndPoint = NSPoint(x: axisStartPoint.x, y: dirtyRect.maxY - CGFloat(Constants.axisPadding))
            drawAxis(from: axisStartPoint, to: axisEndPoint, colour: yAxisColour, label, labelOffset: labelOffset, labelColour: yAxisLabelColour)
            count += 1.0
        }
    }
    
    private func drawXAxes( maxValue: Double, minValue: Double, _ dirtyRect: NSRect, colour: NSColor, lineGap: Double, labelOffset: LabelOffset, labelColour: NSColor ){
        
        var factor = lineGap
        var strokeColour = colour
        
        let phaseFactor: CGFloat = CGFloat(exp(log(Constants.phaseFactorForFinalLine)/(maxValue/lineGap)))
        
        var axisStart = coordinatesInView(xValue: 0.0, maxX: 0.0, minX: 0.0, yValue: 0.0, maxY: maxValue, minY: minValue, dirtyRect)
        var axisEnd = NSPoint(x: dirtyRect.maxX - CGFloat(Constants.axisPadding), y: axisStart.y)
        drawAxis(from: axisStart, to: axisEnd, colour: strokeColour, "0", labelOffset: labelOffset, labelColour: labelColour)
        
        while factor <= maxValue{
            strokeColour = strokeColour.withAlphaComponent(strokeColour.alphaComponent * phaseFactor)
            strokeColour.setStroke()
            axisStart = coordinatesInView(xValue: 0.0, maxX: 0.0, minX: 0.0, yValue: factor, maxY: maxValue, minY: minValue, dirtyRect)
            axisEnd = NSPoint(x: dirtyRect.maxX - CGFloat(Constants.axisPadding), y: axisStart.y)
            drawAxis(from: axisStart, to: axisEnd, colour: strokeColour, labelNumberFormat.string(from: NSNumber(value: factor))!, labelOffset: labelOffset, labelColour: labelColour)
            factor += lineGap
        }
        
        factor = -gapBetweenPrimaryAxisLines
        strokeColour = primaryAxisColour

        while factor >= minValue{
            strokeColour = strokeColour.withAlphaComponent(strokeColour.alphaComponent * phaseFactor)
            strokeColour.setStroke()
            axisStart = coordinatesInView(xValue: 0.0, maxX: 0.0, minX: 0.0, yValue: factor, maxY: maxValue, minY: minValue, dirtyRect)
            axisEnd = NSPoint(x: dirtyRect.maxX - CGFloat(Constants.axisPadding), y: axisStart.y)
            drawAxis(from: axisStart, to: axisEnd, colour: strokeColour, labelNumberFormat.string(from: NSNumber(value: factor))!, labelOffset: labelOffset, labelColour: labelColour)
            factor -= lineGap
        }
    }
    
    private func drawAxis(from: NSPoint, to: NSPoint, colour: NSColor, _ labelString: String, labelOffset: LabelOffset, labelColour: NSColor){
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
            let label = createLabel(value: labelString, point: p, colour: labelColour)
            xLabels.append(label)
        }
    }
    
    private func draw(graph: GraphDefinition, inDirtyRect dirtyRect: NSRect ){
        switch graph.type{
        case .Bar: print("Bar chart to be implemented")
        case .Line: drawLine(graph: graph, inDirtyRect: dirtyRect)
        case .Point: drawPoints(graph: graph, inDirtyRect: dirtyRect)
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
    
    private func drawLine(graph: GraphDefinition, inDirtyRect dirtyRect: NSRect ){
        
        let path = NSBezierPath()
        let maxValue = graphsMaximum(forAxis: graph.axis)
        let minValue = graphsMinimum(forAxis: graph.axis)
        var count = 0.0
        
        let origin = coordinatesInView(xValue: 0.0, maxX: Double(graph.data.count), minX: 0.0, yValue: 0.0, maxY: maxValue, minY: minValue, dirtyRect)
        
        path.move(to: origin)
        for point in graph.data.map({$0.value}) {
            let p = coordinatesInView(xValue:  count, maxX: Double(graph.data.count), minX: 0.0, yValue: point, maxY: maxValue, minY: minValue, dirtyRect)
            path.line(to:p)
            count += 1.0
        }
        
        if graph.format.fill{
            let endOfXAxis = coordinatesInView(xValue: Double(graph.data.count), maxX: Double(graph.data.count), minX: 0.0, yValue: 0.0, maxY: maxValue, minY: minValue, dirtyRect)
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
    
    private func drawPoints(graph: GraphDefinition, inDirtyRect dirtyRect: NSRect ){
        
        let maxValue = graphsMaximum(forAxis: graph.axis)
        let minValue = graphsMinimum(forAxis: graph.axis)
        var count = 0.0
        
        for point in graph.data.map({$0.value}) {
            let p = coordinatesInView(xValue:  count, maxX: Double(graph.data.count), minX: 0.0, yValue: point, maxY: maxValue, minY: minValue, dirtyRect)
            if point != 0.0{ drawPoint(at: p, graphDefinition: graph) }
            count += 1.0
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
