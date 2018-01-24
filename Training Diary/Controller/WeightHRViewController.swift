//
//  WeightHRViewController.swift
//  Training Diary
//
//  Created by Steven Lord on 09/11/2017.
//  Copyright © 2017 Steven Lord. All rights reserved.
//

import Cocoa

class WeightHRViewController: NSViewController, TrainingDiaryViewController {

    @objc dynamic var trainingDiary: TrainingDiary?
    
    @IBOutlet var weightArrayController: NSArrayController!
    @IBOutlet var hrArrayController: NSArrayController!
    @IBOutlet var graphsArrayController: NSArrayController!
    
    @IBOutlet weak var graphView: GraphView!
    @IBOutlet weak var fromDatePicker: NSDatePicker!
    @IBOutlet weak var toDatePicker: NSDatePicker!
    @IBOutlet weak var graphsTableView: TableViewWithColumnSort!
    
    @objc dynamic var rollingDays: Int = 7{
        didSet{
            updateRollingDataCache()
            updateGraphData()
            updateForDateChange()
            graphView!.needsDisplay = true
        }
    }
    
    private var cache: [String: [(date: Date, value: Double)]] = [:]
    private var currentGraphs: [GraphDefinition] = []
    private var advanceDateComponent: DateComponents?
    private var retreatDateComponent: DateComponents?
    
    
    private enum CacheKey: String{
        case kg, fatPercent, hr, sdnn, rmssd, sleep, motivation, fatigue
        static let AllKeys = [kg, fatPercent, hr, sdnn, rmssd, sleep, motivation, fatigue]
        
        func rollingCacheKey() -> String{
            return "rolling" + self.rawValue
        }
        
        func graphColour() -> NSColor{
            switch self{
            case .fatigue:      return NSColor.purple
            case .fatPercent:   return NSColor.magenta
            case .hr:           return NSColor.blue
            case .kg:           return NSColor.black
            case .motivation:   return NSColor.orange
            case .rmssd:        return NSColor.green
            case .sdnn:         return NSColor.red
            case .sleep:        return NSColor.white
            }
        }
        
        func axis() -> Axis{
            switch self{
            case .fatigue:      return Axis.Secondary
            case .fatPercent:   return Axis.Secondary
            case .hr:           return Axis.Primary
            case .kg:           return Axis.Primary
            case .motivation:   return Axis.Secondary
            case .rmssd:        return Axis.Primary
            case .sdnn:         return Axis.Primary
            case .sleep:        return Axis.Secondary
            }
        }
        
    }
    
    @IBAction func advanceAPeriod(_ sender: NSButton) {
        if let advance = advanceDateComponent{
            advanceDates(byDateComponent: advance)
        }
    }
    
    @IBAction func retreatAPeriod(_ sender: NSButton) {
        if let retreat = retreatDateComponent{
            advanceDates(byDateComponent: retreat)
        }
    }
    
    
    @IBAction func graphSetComboxBoxChanged(_ sender: NSComboBox) {
        switch sender.stringValue{
        case "All":
            for g in currentGraphs{
                g.display = true
            }
        case "HR":
            for g in currentGraphs{
                switch g.name{
                case CacheKey.hr.rawValue, CacheKey.hr.rollingCacheKey(), CacheKey.sdnn.rawValue, CacheKey.sdnn.rollingCacheKey(), CacheKey.rmssd.rawValue, CacheKey.rmssd.rollingCacheKey():
                    g.display = true
                default:
                    g.display = false
                }
            }
        case "Weight":
            for g in currentGraphs{
                switch g.name{
                case CacheKey.kg.rawValue, CacheKey.kg.rollingCacheKey(), CacheKey.fatPercent.rawValue, CacheKey.fatPercent.rollingCacheKey():
                    g.display = true
                default:
                    g.display = false
                }
            }
        case "Sleep":
            for g in currentGraphs{
                switch g.name{
                case CacheKey.sleep.rawValue, CacheKey.sleep.rollingCacheKey(), CacheKey.fatigue.rawValue, CacheKey.fatigue.rollingCacheKey(), CacheKey.motivation.rawValue, CacheKey.motivation.rollingCacheKey():
                    g.display = true
                default:
                    g.display = false
                }
            }
        default:
            sender.stringValue = ""
        }
        graphView!.needsDisplay = true
        graphsTableView.reloadData()
    }
    
    @IBAction func periodChanged(_ sender: PeriodTextField) {
        if let dc = sender.getNegativeDateComponentsEquivalent(){
            fromDatePicker!.dateValue = Calendar.current.date(byAdding: dc, to: toDatePicker!.dateValue)!
            updateForDateChange()
        }
        advanceDateComponent = sender.getDateComponentsEquivalent()
        retreatDateComponent = sender.getNegativeDateComponentsEquivalent()
    }
    

    
    @IBAction func fromDatePickerChanged(_ sender: NSDatePicker) {
        updateForDateChange()
    }
    

    @IBAction func toDatePickerChanged(_ sender: NSDatePicker) {
        updateForDateChange()
    }
    
    
    func set(trainingDiary td: TrainingDiary){
        self.trainingDiary = td
        if let gac = graphsArrayController{
            gac.remove(contentsOf: currentGraphs)
        }
        trainingDiarySet()
    }
    
    override func viewDidLoad() {
            trainingDiarySet()
        if let gv = graphView{
            gv.backgroundGradientStartColour = .lightGray
            gv.backgroundGradientEndColour = .darkGray
            gv.backgroundGradientAngle = CGFloat(70)
        }
    }
    
    private func updateForDateChange(){
    
        if let from = fromDatePicker?.dateValue{
            if let to = toDatePicker?.dateValue{

                if let graphView = graphView{
                    for g in graphView.graphs{
                        g.data = (cache[g.name]?.filter({$0.date >= from && $0.date <= to }))!
                    }
                    graphView.xAxisLabelStrings = getXAxisLabels(fromDate: from, toDate: to )
                }
                
                let predicate = NSPredicate(format: "fromDate >= %@ AND fromDate <= %@", argumentArray: [from.startOfDay(),to.endOfDay()])
                weightArrayController!.filterPredicate = predicate
                hrArrayController!.filterPredicate = predicate

            }
        }
        
        if let hrgv = graphView { hrgv.needsDisplay = true}

    }
    
    private func trainingDiarySet(){
        if let td = trainingDiary{
            createGraphs(forTrainingDiary: td)
            setUpPickers(forTrainingDiary: td)
            updateForDateChange()
        }
    }
    
    private func setUpPickers(forTrainingDiary td: TrainingDiary){
        if let tdp = toDatePicker{ tdp.dateValue = td.lastDayOfDiary }
        let fromDate = td.lastDayOfDiary.addDays(numberOfDays: -31)
        if let fdp = fromDatePicker{ fdp.dateValue = fromDate }
    }
    
    private func createGraphs(forTrainingDiary td: TrainingDiary){

        if let hrgv = graphView{
                
            let graphs = createGraphDefinitions(forTrainingDiary: td)

            if let gac = graphsArrayController{
                gac.add(contentsOf: graphs )
            }
            
            for g in graphs{
                hrgv.add(graph: g)
            }
            
            hrgv.xAxisLabelStrings = getXAxisLabels(fromDate: td.firstDayOfDiary, toDate: td.lastDayOfDiary)
        }
    }
    
    private func createGraphDefinitions(forTrainingDiary td: TrainingDiary) -> [GraphDefinition]{

        
        cache[CacheKey.hr.rawValue]         = td.hrDateOrder()
        cache[CacheKey.sdnn.rawValue]       = td.sdnnDateOrder()
        cache[CacheKey.rmssd.rawValue]      = td.rmssdDateOrder()
        cache[CacheKey.kg.rawValue]         = td.kgAscendingDateOrder()
        cache[CacheKey.fatPercent.rawValue] = td.fatPercentageDateOrder()
        cache[CacheKey.sleep.rawValue]      = td.sleepDateOrder()
        cache[CacheKey.motivation.rawValue] = td.motivationDateOrder()
        cache[CacheKey.fatigue.rawValue]    = td.fatigueDateOrder()

        updateRollingDataCache()
        
        for key in CacheKey.AllKeys{
            currentGraphs.append(createGraph(forKey: key, type: .Point))
            currentGraphs.append(createGraph(forKey: key.rollingCacheKey(), type: .Line, colour: key.graphColour(), axis: key.axis(), size:3.0))
        }
    
        return currentGraphs
        
    }
    
    private func createGraph(forKey key: CacheKey, type: ChartType) -> GraphDefinition{
        return createGraph(forKey: key.rawValue, type: type, colour: key.graphColour(), axis: key.axis())
    }
    
    private func createGraph(forKey key: String, type: ChartType, colour: NSColor, axis: Axis ) -> GraphDefinition{
        return createGraph(forKey: key, type: type, colour: colour, axis: axis, size: 1.0)
        
    }

    private func createGraph(forKey key: String, type: ChartType, colour: NSColor, axis: Axis, size: CGFloat ) -> GraphDefinition{
        return GraphDefinition(name: key, data: cache[key]!, axis: axis  , type: type, format: GraphFormat(fill: false, colour: colour, fillGradientStart: colour, fillGradientEnd: colour, gradientAngle: 45, size: size),drawZeroes: false, priority: 2)
        
    }
    
    private func createRollingData(forKey key: CacheKey) -> [(date:Date, value:Double)]{
        var result: [(date:Date, value:Double)] = []
        let rollingSum = RollingSumQueue(size: rollingDays)
        if let data = cache[key.rawValue]{
            for d in data{
                result.append((d.date, rollingSum.addAndReturnAverage(value: d.value)))
            }
        }
        
        return result
    }
    
    private func getXAxisLabels(fromDate from: Date, toDate to: Date) -> [String]{
        let gap = to.timeIntervalSince(from) / 9.0 // doing 10 labels total
        var result: [String] = []
        result.append(from.dateOnlyShorterString())
        for i in 1...9{
            result.append(from.addingTimeInterval(TimeInterval.init(gap*Double(i))).dateOnlyShorterString())
        }
        return result
    }
    
    private func updateRollingDataCache(){
        for key in CacheKey.AllKeys{
            cache[key.rollingCacheKey()] = createRollingData(forKey: key)
        }
    }
    
    private func updateGraphData(){
        for g in currentGraphs{
            if let data = cache[g.name]{
                g.data = data
            }
        }
    }
    
    private func createPredicate() -> NSPredicate?{
        var predicate: NSPredicate?
        if let fdp = fromDatePicker{
            if let tdp = toDatePicker{
                let fromDate = fdp.dateValue.startOfDay()
                let toDate = tdp.dateValue.endOfDay()
                predicate = NSPredicate.init(format: "%@ >= fromDate AND %@ <= toDate", argumentArray: [fromDate,toDate])
            }
        }
        return predicate
    }
    
    private func advanceDates(byDateComponent dc: DateComponents){
        if let fdp = fromDatePicker{
            if let tdp = toDatePicker{
                fdp.dateValue = Calendar.current.date(byAdding: dc, to: fdp.dateValue)!
                tdp.dateValue = Calendar.current.date(byAdding: dc, to: tdp.dateValue)!
                updateForDateChange()
            }
        }
    }
    
}
