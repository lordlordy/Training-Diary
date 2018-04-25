//
//  WeightHRViewController.swift
//  Training Diary
//
//  Created by Steven Lord on 09/11/2017.
//  Copyright © 2017 Steven Lord. All rights reserved.
//

import Cocoa

class WeightHRViewController: TrainingDiaryViewController {

    
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
        case kg, fatPercent, hr, sdnn, rmssd, sleep, motivation, fatigue, bmi
        case sdnnOff, sdnnEasy, sdnnHard, rmssdOff, rmssdEasy, rmssdHard
        static let AllKeys: [CacheKey] = [.kg, .fatPercent, .hr, .sdnn, .rmssd, .sleep, .motivation, .fatigue, .bmi, .sdnnOff, .sdnnEasy, .sdnnHard, .rmssdOff, .rmssdEasy, .rmssdHard]
        static let pointData: [CacheKey] = [.kg, .fatPercent, .hr, .sdnn, .rmssd, .sleep, .motivation, .fatigue, .bmi]
        
        func rollingCacheKey() -> String{
            return "rolling" + self.rawValue
        }
        
        func graphColour() -> NSColor{
            switch self{
            case .bmi:          return NSColor.darkGray
            case .fatigue:      return NSColor.purple
            case .fatPercent:   return NSColor.magenta
            case .hr:           return NSColor.blue
            case .kg:           return NSColor.black
            case .motivation:   return NSColor.orange
            case .sleep:        return NSColor.white
            case .rmssd, .rmssdOff, .rmssdEasy, .rmssdHard:
                return NSColor.green
            case .sdnn, .sdnnOff, .sdnnEasy, .sdnnHard:
                return NSColor.red
            }
        }
        
        func axis() -> Axis{
            switch self{
            case .bmi:          return Axis.Secondary
            case .fatigue:      return Axis.Secondary
            case .fatPercent:   return Axis.Secondary
            case .hr:           return Axis.Primary
            case .kg:           return Axis.Primary
            case .motivation:   return Axis.Secondary
            case .sleep:        return Axis.Secondary
            case .rmssd, .rmssdOff, .rmssdEasy, .rmssdHard:
                return Axis.Primary
            case .sdnn, .sdnnOff, .sdnnEasy, .sdnnHard:
                return Axis.Primary
            }
        }
        
        func graphType() -> ChartType{
            switch self{
            case .rmssdOff, .rmssdHard, .rmssdEasy, .sdnnHard, .sdnnEasy, .sdnnOff:
                return .Line
            default:
                return .Point
            }
        }
        
        func includeRolling() -> Bool{
            switch self{
            case .rmssdOff, .rmssdHard, .rmssdEasy, .sdnnHard, .sdnnEasy, .sdnnOff:
                return false
            default: return true
            }
        }
        
        func size() -> CGFloat{
            if CacheKey.pointData.contains(self){
                return 5.0
            }else{
                return 2.0
            }
        }
        
        func dashed() -> Bool{
            switch self{
            case .rmssdOff, .rmssdHard, .rmssdEasy, .sdnnHard, .sdnnEasy, .sdnnOff:
                        return true
            default:    return false
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
        case "HRV":
            for g in currentGraphs{
                switch g.name{
                case CacheKey.hr.rawValue, CacheKey.hr.rollingCacheKey(), CacheKey.sdnn.rawValue, CacheKey.sdnn.rollingCacheKey(), CacheKey.rmssd.rawValue, CacheKey.rmssd.rollingCacheKey(), CacheKey.sdnnHard.rawValue, CacheKey.sdnnEasy.rawValue, CacheKey.sdnnOff.rawValue, CacheKey.rmssdHard.rawValue, CacheKey.rmssdEasy.rawValue, CacheKey.rmssdOff.rawValue:
                    g.display = true
                default:
                    g.display = false
                }
            }
        case "Weight":
            for g in currentGraphs{
                switch g.name{
                case CacheKey.kg.rawValue, CacheKey.kg.rollingCacheKey(), CacheKey.fatPercent.rawValue, CacheKey.fatPercent.rollingCacheKey(), CacheKey.bmi.rawValue, CacheKey.bmi.rollingCacheKey():
                    g.display = true
                default:
                    g.display = false
                }
            }
        case "Mood":
            for g in currentGraphs{
                switch g.name{
                case CacheKey.sleep.rawValue, CacheKey.sleep.rollingCacheKey(), CacheKey.fatigue.rawValue, CacheKey.fatigue.rollingCacheKey(), CacheKey.motivation.rawValue, CacheKey.motivation.rollingCacheKey():
                    g.display = true
                default:
                    g.display = false
                }
            }
        case "HR":
            for g in currentGraphs{
                switch g.name{
                case CacheKey.hr.rawValue, CacheKey.hr.rollingCacheKey():
                    g.display = true
                default:
                    g.display = false
                }
            }
        case "SDNN":
            for g in currentGraphs{
                switch g.name{
                case CacheKey.sdnn.rawValue, CacheKey.sdnn.rollingCacheKey(), CacheKey.sdnnHard.rawValue, CacheKey.sdnnEasy.rawValue, CacheKey.sdnnOff.rawValue:
                    g.display = true
                default:
                    g.display = false
                }
            }
        case "rMSSD":
            for g in currentGraphs{
                switch g.name{
                case CacheKey.rmssd.rawValue, CacheKey.rmssd.rollingCacheKey(), CacheKey.rmssdHard.rawValue, CacheKey.rmssdEasy.rawValue, CacheKey.rmssdOff.rawValue:
                    g.display = true
                default:
                    g.display = false
                }
            }
        case "KG":
            for g in currentGraphs{
                switch g.name{
                case CacheKey.kg.rawValue, CacheKey.kg.rollingCacheKey():
                    g.display = true
                default:
                    g.display = false
                }
            }
        case "Fat%":
            for g in currentGraphs{
                switch g.name{
                case CacheKey.fatPercent.rawValue, CacheKey.fatPercent.rollingCacheKey():
                    g.display = true
                default:
                    g.display = false
                }
            }
        case "BMI":
            for g in currentGraphs{
                switch g.name{
                case CacheKey.bmi.rawValue, CacheKey.bmi.rollingCacheKey():
                    g.display = true
                default:
                    g.display = false
                }
            }        case "Sleep":
            for g in currentGraphs{
                switch g.name{
                case CacheKey.sleep.rawValue, CacheKey.sleep.rollingCacheKey():
                    g.display = true
                default:
                    g.display = false
                }
            }
        case "Motivation":
            for g in currentGraphs{
                switch g.name{
                case CacheKey.motivation.rawValue, CacheKey.motivation.rollingCacheKey():
                    g.display = true
                default:
                    g.display = false
                }
            }
        case "Fatigue":
            for g in currentGraphs{
                switch g.name{
                case CacheKey.fatigue.rawValue, CacheKey.fatigue.rollingCacheKey():
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
    
    
    override func set(trainingDiary td: TrainingDiary){
        super.set(trainingDiary: td)
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
        cache[CacheKey.bmi.rawValue]        = td.bmiAscendingDateOrder()
        cache[CacheKey.sleep.rawValue]      = td.sleepDateOrder()
        cache[CacheKey.motivation.rawValue] = td.motivationDateOrder()
        cache[CacheKey.fatigue.rawValue]    = td.fatigueDateOrder()

        updateRollingDataCache()
        
        let hrvData = td.calculatedHRVData()
        cache[CacheKey.sdnnHard.rawValue] = hrvData.map({($0.date, $0.sdnnHard)})
        cache[CacheKey.sdnnEasy.rawValue] = hrvData.map({($0.date, $0.sdnnEasy)})
        cache[CacheKey.sdnnOff.rawValue] = hrvData.map({($0.date, $0.sdnnOff)})
        cache[CacheKey.rmssdHard.rawValue] = hrvData.map({($0.date, $0.rmssdHard)})
        cache[CacheKey.rmssdEasy.rawValue] = hrvData.map({($0.date, $0.rmssdEasy)})
        cache[CacheKey.rmssdOff.rawValue] = hrvData.map({($0.date, $0.rmssdOff)})

        
        for key in CacheKey.AllKeys{
            if let g = createGraph(forKey: key.rawValue, type: key.graphType(), colour: key.graphColour(), axis: key.axis(), size: key.size()){
                currentGraphs.append(g)
            }
            if key.includeRolling(){
                if let g = createGraph(forKey: key.rollingCacheKey(), type: .Line, colour: key.graphColour(), axis: key.axis(), size:3.0){
                    currentGraphs.append(g)
                }
            }
        }
    
        return currentGraphs
        
    }
    

    private func createGraph(forKey key: String, type: ChartType, colour: NSColor, axis: Axis, size: CGFloat ) -> GraphDefinition?{
        if let data = cache[key]{
            let graph = GraphDefinition(name: key, data: data, axis: axis  , type: type, format: GraphFormat(fill: false, colour: colour, fillGradientStart: colour, fillGradientEnd: colour, gradientAngle: 45, size: size, opacity: 1.0),drawZeroes: false, priority: 2)

            if let cacheKey = CacheKey.init(rawValue: key){
                if cacheKey.dashed(){
                    graph.dash = [5.0,5.0]
                }
            }
            
            return graph
        }else{
            print("No cache data for cache key \(key)")
            return nil
        }
        
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
