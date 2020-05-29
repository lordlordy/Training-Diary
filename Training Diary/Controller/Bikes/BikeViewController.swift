//
//  BikeViewController.swift
//  Training Diary
//
//  Created by Steven Lord on 22/01/2018.
//  Copyright © 2018 Steven Lord. All rights reserved.
//

import Cocoa

class BikeViewController: TrainingDiaryViewController, NSTableViewDelegate, NSComboBoxDataSource {

    @objc dynamic var bikeActivity: Activity?
    @objc dynamic var rollingDataDays: Int = 30
    
    @IBOutlet var bikeArrayController: NSArrayController!
    @IBOutlet weak var bikeTableView: TableViewWithColumnSort!
    @IBOutlet var bikeGraphsArrayController: NSArrayController!
    @IBOutlet weak var graphsTableView: NSTableView!
    @IBOutlet weak var displayTypeComboBox: NSComboBox!
    @IBOutlet weak var fromDatePicker: NSDatePicker!
    @IBOutlet weak var toDatePicker: NSDatePicker!
    
    var graphView: GraphView?{
        if let p = parent as? BikeSplitViewController{
            if let gv = p.bikeGraphViewController?.graphView{
                return gv
            }
        }
        return nil
    }

    
    private var dataCache: [Equipment: [WorkoutProperty: GraphData]] = [:]
    private var graphCache: [Equipment:BikeGraphs] = [:]
    private var graphColours: [NSColor] = [.black, .blue, .brown, .cyan, .green, .magenta, .orange, .purple, .red, .white, .systemPink, .yellow, .darkGray, .systemBlue, .systemGreen]
    private var allocatedColours: [Equipment:NSColor] = [:]
    private var advanceDateComponent: DateComponents?
    private var retreatDateComponent: DateComponents?
    
    private struct GraphData{
        let values: [(x:Double, y:Double)]
        let ltd: [(x:Double, y:Double)]
        let rolling: [(x:Double, y:Double)]
    }
    
    private struct GraphConstants {
        static var lineWidth: CGFloat = 2.0
        static var pointSize: CGFloat = 2.0
        static var rollingLineWidth: CGFloat = 1.0
        static var numberOfXAxisLabels: Int = 6
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //perhaps this should be a user default / preference
        if let cb = displayTypeComboBox{
            cb.selectItem(at: 7)
        }
        if let td = trainingDiary{
            if let fdp = fromDatePicker{
                fdp.dateValue = td.firstDayOfDiary
            }
            if let tdp = toDatePicker{
                tdp.dateValue = td.lastDayOfDiary
            }
        }
    }
    
    //MARK: - @IBAction
    @IBAction func setToFullRange(_ sender: NSButton) {
        let range = dateRangeForSelectedBikes()
        fromDatePicker!.dateValue = range.from
        toDatePicker!.dateValue = range.to
        changeGraphData()
    }
    
    @IBAction func graphPeriodChange(_ sender: PeriodTextField) {
        advanceDateComponent = sender.getDateComponentsEquivalent()
        retreatDateComponent = sender.getNegativeDateComponentsEquivalent()
        if let rdc = retreatDateComponent{
            fromDatePicker!.dateValue = Calendar.current.date(byAdding: rdc, to: toDatePicker!.dateValue)!
        }
        changeGraphData()
    }
    
    @IBAction func retreatAPeriod(_ sender: NSButton) {
        if let dc = retreatDateComponent{
            fromDatePicker!.dateValue = Calendar.current.date(byAdding: dc, to: fromDatePicker!.dateValue)!
            toDatePicker!.dateValue = Calendar.current.date(byAdding: dc, to: toDatePicker!.dateValue)!
        }
        changeGraphData()
    }
    
    @IBAction func advanceAPeriod(_ sender: NSButton) {
        if let dc = advanceDateComponent{
            fromDatePicker!.dateValue = Calendar.current.date(byAdding: dc, to: fromDatePicker!.dateValue)!
            toDatePicker!.dateValue = Calendar.current.date(byAdding: dc, to: toDatePicker!.dateValue)!
        }
        changeGraphData()
    }
    @IBAction func fromDateChange(_ sender: NSDatePicker) {
        changeGraphData()
    }
    
    @IBAction func toDateChange(_ sender: NSDatePicker) {
        changeGraphData()
    }
    
    
    @IBAction func displayTypeComboBoxClicked(_ sender: NSComboBox) {
        changeGraphData()
        graphView!.needsDisplay = true
    }
    
    @IBAction func valuesButtonClicked(_ sender: NSButton) {
        let state: Bool = sender.state == NSControl.StateValue.on
        for g in graphs(){ g.valuesGraph.display = state }
        graphsTableView!.reloadData()
        graphView?.needsDisplay = true
    }
    
    @IBAction func ltdButtonClicked(_ sender: NSButton) {
        let state: Bool = sender.state == NSControl.StateValue.on
        for g in graphs(){ g.ltdGraph.display = state }
        graphsTableView!.reloadData()
        graphView?.needsDisplay = true
    }
    
    @IBAction func rollingButtonClicked(_ sender: NSButton) {
        let state: Bool = sender.state == NSControl.StateValue.on
        for g in graphs(){ g.rollingGraph.display = state }
        graphsTableView!.reloadData()
        graphView?.needsDisplay = true
    }
    
    @IBAction func updateHistory(_ sender: NSButton) {
        if let td = trainingDiary{
            for bike in selectedBikes(){
                td.connectWorkouts(forEquipment: bike)
                print("\(String(describing: bike.workouts?.count)) workouts for \(String(describing: bike.name))")
            }
        }
        if let btv = bikeTableView{
            btv.reloadData()
        }
    }
    
    //MARK: - NSComboBoxDataSource
    func comboBox(_ comboBox: NSComboBox, objectValueForItemAt index: Int) -> Any? {
        return WorkoutProperty.DoubleProperties[index].rawValue
    }
    
    func numberOfItems(in comboBox: NSComboBox) -> Int {
        return WorkoutProperty.DoubleProperties.count
    }

    
    //MARK: - NSTableViewDelegate
    func tableViewSelectionDidChange(_ notification: Notification) {
        clearGraphs()
        addGraphs()
        changeGraphData()
    }
    
    //MARK: - TrainingDiaryViewController protocol
    
    override func set(trainingDiary td: TrainingDiary){
        super.set(trainingDiary: td)
        if let fdp = fromDatePicker{
            fdp.dateValue = td.firstDayOfDiary
        }
        if let tdp = toDatePicker{
            tdp.dateValue = td.lastDayOfDiary
        }
        bikeActivity = td.activity(forString: FixedActivity.Bike.rawValue)
    }
    
    //MARK: - Private
    
    private func graphs() -> [BikeGraphs]{
        if let bgac = bikeGraphsArrayController{
            return bgac.arrangedObjects as! [BikeGraphs]
        }
        return []
    }
    
    private func addGraphs(forBike bike: Equipment){
        if let gv = graphView{
            if let cache = graphCache[bike]{
                cache.add(toGraph: gv)
                if let bgac = bikeGraphsArrayController{
                    bgac.add(contentsOf: [cache])
                }
            }else{
                createGraphs(forBike: bike)
                updateGraphData(forBike: bike, andProperty: selectedProperty())
            }
        }
    }
    
    private func selectedProperty() -> WorkoutProperty{
        if let cb = displayTypeComboBox{
            if cb.indexOfSelectedItem < WorkoutProperty.DoubleProperties.count{
                return WorkoutProperty.DoubleProperties[cb.indexOfSelectedItem]
            }
        }
        return WorkoutProperty.km
    }
    
    private func createGraphs(forBike bike: Equipment){
        let c = colour(forBike: bike)
        
        // point graph first
        let graphFormat = GraphFormat.init(fill: true, colour: c, fillGradientStart: c, fillGradientEnd: c, gradientAngle: 45.0, size: GraphConstants.pointSize, opacity: 1.0)
        let graphDefinition = GraphDefinition.init(name: bike.name! + ":km", axis: .Primary, type: .Point, format: graphFormat, drawZeroes: false, priority: 3)
    
        // ltd data next
        let ltdGraphFormat = GraphFormat.init(fill: false, colour: c, fillGradientStart: c, fillGradientEnd: c, gradientAngle: 45.0, size: GraphConstants.lineWidth, opacity: 1.0)
        let ltdGraphDefinition = GraphDefinition.init(name: bike.name! + ":ltd:KM", axis: .Secondary, type: .Line, format: ltdGraphFormat, drawZeroes: true, priority: 1)
        
        
        // rolling data
        let rollingGraphFormat = GraphFormat.init(fill: false, colour: c, fillGradientStart: c, fillGradientEnd: c, gradientAngle: 45.0, size: GraphConstants.rollingLineWidth, opacity: 1.0)
        let rollingGraphDefinition = GraphDefinition.init(name: bike.name! + ":rolling:KM", axis: .Primary, type: .Line, format: rollingGraphFormat, drawZeroes: true, priority: 1)
        
        let bikeGraphs = BikeGraphs(name: bike.name!, valuesGraph: graphDefinition, ltdGraph: ltdGraphDefinition, rollingGraph: rollingGraphDefinition)
        
        graphCache[bike] = bikeGraphs
        
        if let gv = graphView{
            bikeGraphs.add(toGraph: gv)
        }
        
        if let bgac = bikeGraphsArrayController{
            bgac.add(contentsOf: [bikeGraphs])
        }

    }
    

    
    private func createData(forBike bike: Equipment, andProperty p: WorkoutProperty) -> GraphData{
        // point graph first
        let data = bike.getWorkouts()
        var mappedData: [(date: Date, value: Double)]?
        
        // to handle rogue workouts without dates. Use default date and filter them out
        let defaultDate: Date = Date(timeIntervalSince1970: TimeInterval(0))
        mappedData = data.map({(date: $0.day?.date ?? defaultDate, Value: $0.value(forKey: p.rawValue) as! Double)}).filter({$0.value != 0.0}).filter({$0.date != defaultDate})
        
        // ltd data next
        var ltdData: [(Double,Double)] = []
        if p.isSummable(){
            var ltd: Double = 0.0
            if p == WorkoutProperty.km{ ltd = bike.preDiaryKMs }
            if p == WorkoutProperty.miles{ ltd = bike.preDiaryKMs * Constant.MilesPerKM.rawValue}
            for d in mappedData!.sorted(by: {$0.date < $1.date}){
                ltd += d.value
                ltdData.append((d.date.timeIntervalSinceReferenceDate, ltd))
            }
        }else{
            //average never resets so set the queue bigger than number of workouts
            let ltdWeightAverage = RollingPeriodWeightedAverage(size: Int.max)
            for w in bike.getWorkouts().sorted(by: {$0.day!.date! < $1.day!.date!}){
                let d = w.day!.date!
                let value = w.value(forKey: p.rawValue) as! Double
                if value != 0.0{
                    ltdData.append((d.timeIntervalSinceReferenceDate, ltdWeightAverage.addAndReturnValue(forDate: d, value: w.value(forKey: p.rawValue) as! Double, weighting: w.seconds)!))
                }
            }
        }
        
        
        // rolling data
        var rollingData: [(Double,Double)] = []
        let rollingDataQ = RollingPeriodWeightedAverage.init(size: rollingDataDays)
        
        for d in fillInMissingDates(mappedData!.sorted(by: {$0.date < $1.date})){
            rollingData.append((d.date.timeIntervalSinceReferenceDate, rollingDataQ.addAndReturnValue(forDate: d.date, value: d.value, weighting: 1.0)!))
        }
        
        let graphData = GraphData(values: mappedData!.map({(x: $0.date.timeIntervalSinceReferenceDate, y: $0.value)}), ltd: ltdData, rolling: rollingData)
        
        // add to cache
        if var bikeCache = dataCache[bike]{
            // we have a cache for the bike
            bikeCache[p] = graphData
        }else{
            //no bike cache
            var propertyCache: [WorkoutProperty: GraphData] = [:]
            propertyCache[p] = graphData
            dataCache[bike] = propertyCache
        }
        
        return graphData
    }
    
    
    private func fillInMissingDates(_ data:[(date:Date,value:Double)]) -> [(date:Date, value:Double)]{
        if data.count == 0 { return [] }
        var result: [(date: Date, value: Double)] = []
        var nextDay: Date = data[0].date
        for d in data{
            while (Calendar.current.compare(d.date, to: nextDay, toGranularity: .day) == ComparisonResult.orderedDescending){
                result.append((nextDay,0.0))
                nextDay = nextDay.tomorrow()
            }
            result.append(d)
            nextDay = d.date.tomorrow()
        }
    
        
        return result
    }
    
    private func selectedBikes() -> [Equipment]{
        
        if let bac = bikeArrayController{
            if let sb = bac.selectedObjects as? [Equipment]{
                return sb
            }
        }
        return []
    }
    
    private func colour(forBike bike: Equipment) -> NSColor{
        if let color = allocatedColours[bike]{
            return color
        }else{
            let color = graphColours[allocatedColours.count % graphColours.count]
            allocatedColours[bike] = color
            return color
        }
    }
    
    private func changeGraphData(){
        for bike in selectedBikes(){
            updateGraphData(forBike: bike, andProperty: selectedProperty())
        }
        graphView!.needsDisplay = true
    }
    
    private func updateGraphData(forBike bike: Equipment, andProperty p: WorkoutProperty){
        
        var data: GraphData? = nil
        
        //check cache first
        if let bikeCache = dataCache[bike]{
            if let propertyCache = bikeCache[p]{
                data = propertyCache
            }
        }
        
        if data == nil{
            data = createData(forBike: bike, andProperty: p)
        }
        
        let labels = createXAxisLabels()

        
        if let graphs = graphCache[bike]{
            if let d = data{
                if let from = fromDatePicker?.dateValue{
                    if let to = toDatePicker?.dateValue{
                        graphs.valuesGraph.data = d.values.filter({$0.x >= from.timeIntervalSinceReferenceDate && $0.x <= to.timeIntervalSinceReferenceDate})
                        graphs.ltdGraph.data = d.ltd.filter({$0.x >= from.timeIntervalSinceReferenceDate && $0.x <= to.timeIntervalSinceReferenceDate})
                        graphs.rollingGraph.data = d.rolling.filter({$0.x >= from.timeIntervalSinceReferenceDate && $0.x <= to.timeIntervalSinceReferenceDate})
                        
                        graphs.ltdGraph.xAxisLabels = labels
                        graphs.rollingGraph.xAxisLabels = labels
                        graphs.valuesGraph.xAxisLabels = labels
                        
                    }
                }
            }
        }

        
    }
    
    private func clearGraphs(){
        if let gv = graphView{
            if let bgac = bikeGraphsArrayController{
                for g in bgac.arrangedObjects as! [BikeGraphs]{
                    g.remove(fromGraph: gv)
                }
                bgac.content = nil
            }
        }
    }
    
    private func addGraphs(){
        if let bac = bikeArrayController{
            for b in bac.selectedObjects as! [Equipment]{
                // this check is in place to cope with adding a new bike. At the point of addition there will be no workouts
                if b.workoutCount > 0{
                    addGraphs(forBike: b)
                }
            }
        }
    }
    
    private func createXAxisLabels() -> [(x: Double, label: String)]{
        let range = dateRangeForCurrentSetUp()
        var d: Date = range.from
        let gap: DateComponents = DateComponents(day: 7)
        var result: [(x: Double, label: String)] = []
        
        while d <= range.to{
            result.append((x:d.timeIntervalSinceReferenceDate, label: d.dateOnlyShorterString()))
            d = Calendar.current.date(byAdding: gap, to: d)!
        }
        
        return result
        
    }
    
    private func dateRangeForSelectedBikes() -> (from:Date, to:Date){
        var minDates: [Date] = []
        var maxDates: [Date] = []
        
        for b in selectedBikes(){
            let range = b.workoutDateRange()
            minDates.append(range.from)
            maxDates.append(range.to)
        }
        
        return (from: minDates.min()!, to: maxDates.max()!)
    }
    
    private func dateRangeForCurrentSetUp() -> (from:Date, to:Date){

        let range = dateRangeForSelectedBikes()
        
        var fromDate = range.from
        var toDate = range.to
        
        if let d = fromDatePicker?.dateValue{
            if d > fromDate {
                fromDate = d
            }
        }
        if let d = toDatePicker?.dateValue{
            if d < toDate {
                toDate = d
            }
        }
        
        return (from: fromDate, to: toDate)
    }
    
}
