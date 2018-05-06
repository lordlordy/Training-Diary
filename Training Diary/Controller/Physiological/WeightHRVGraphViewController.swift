//
//  WeightHRVGraphViewController.swift
//  Training Diary
//
//  Created by Steven Lord on 25/04/2018.
//  Copyright © 2018 Steven Lord. All rights reserved.
//

import Cocoa

class WeightHRVGraphViewController: TrainingDiaryViewController{
    
    @IBOutlet var graphArrayController: NSArrayController!
    @IBOutlet weak var graphView: GraphView!
    @IBOutlet weak var graphsTableView: TableViewWithColumnSort!
    
    private var fromDate: Date?
    private var toDate: Date?

    @IBAction func reloadCache(_ sender: Any){
        createDataCache()
        setGraphDataFromCache()
        if let from = fromDate{
            if let to = toDate{
                setGraphDate(fromDate: from, toDate: to)
            }
        }
    }
    
    var rollingDays: Int = 7{
        didSet{
            updateRollingDataCache()
        }
    }
    
    override func viewDidLoad() {
        createGraphs()
        createDataCache()
        setGraphDataFromCache()
        if let td = trainingDiary{
            let to = td.lastDayOfDiary
            setGraphDate(fromDate: to.addDays(numberOfDays: -31), toDate: to)
        }
    }
    

    
    
    func setGraphDate(fromDate from: Date, toDate to: Date){
        fromDate = from
        toDate = to
        if let gv = graphView{
            for g in graphs{
                if let data = cache[g.name]?.filter({$0.x >= from.timeIntervalSinceReferenceDate && $0.x <= to.timeIntervalSinceReferenceDate}){
                    g.data = data
                }
            }
            //create x-axis labels
            let gap = to.timeIntervalSince(from) / 9.0 // doing 10 labels total
            var labels: [String] = []
            labels.append(from.dateOnlyShorterString())
            for i in 1...9{
                labels.append(from.addingTimeInterval(TimeInterval.init(gap*Double(i))).dateOnlyShorterString())
            }
            gv.xAxisLabelStrings = labels
            gv.needsDisplay = true
        }
    }
    
    func setGraphs(forKey key: String){
        switch key{
        case "All":
            for g in graphs{
                g.display = true
            }
        case "HRV":
            for g in graphs{
                switch g.name{
                case CacheKey.hr.rawValue, CacheKey.hr.rollingCacheKey(), CacheKey.sdnn.rawValue, CacheKey.sdnn.rollingCacheKey(), CacheKey.rmssd.rawValue, CacheKey.rmssd.rollingCacheKey(), CacheKey.sdnnHard.rawValue, CacheKey.sdnnEasy.rawValue, CacheKey.sdnnOff.rawValue, CacheKey.rmssdHard.rawValue, CacheKey.rmssdEasy.rawValue, CacheKey.rmssdOff.rawValue:
                    g.display = true
                default:
                    g.display = false
                }
            }
        case "Weight":
            for g in graphs{
                switch g.name{
                case CacheKey.kg.rawValue, CacheKey.kg.rollingCacheKey(), CacheKey.fatPercent.rawValue, CacheKey.fatPercent.rollingCacheKey(), CacheKey.bmi.rawValue, CacheKey.bmi.rollingCacheKey():
                    g.display = true
                default:
                    g.display = false
                }
            }
        case "Mood":
            for g in graphs{
                switch g.name{
                case CacheKey.sleep.rawValue, CacheKey.sleep.rollingCacheKey(), CacheKey.fatigue.rawValue, CacheKey.fatigue.rollingCacheKey(), CacheKey.motivation.rawValue, CacheKey.motivation.rollingCacheKey():
                    g.display = true
                default:
                    g.display = false
                }
            }
        case "HR":
            for g in graphs{
                switch g.name{
                case CacheKey.hr.rawValue, CacheKey.hr.rollingCacheKey():
                    g.display = true
                default:
                    g.display = false
                }
            }
        case "SDNN":
            for g in graphs{
                switch g.name{
                case CacheKey.sdnn.rawValue, CacheKey.sdnn.rollingCacheKey(), CacheKey.sdnnHard.rawValue, CacheKey.sdnnEasy.rawValue, CacheKey.sdnnOff.rawValue:
                    g.display = true
                default:
                    g.display = false
                }
            }
        case "rMSSD":
            for g in graphs{
                switch g.name{
                case CacheKey.rmssd.rawValue, CacheKey.rmssd.rollingCacheKey(), CacheKey.rmssdHard.rawValue, CacheKey.rmssdEasy.rawValue, CacheKey.rmssdOff.rawValue:
                    g.display = true
                default:
                    g.display = false
                }
            }
        case "KG":
            for g in graphs{
                switch g.name{
                case CacheKey.kg.rawValue, CacheKey.kg.rollingCacheKey():
                    g.display = true
                default:
                    g.display = false
                }
            }
        case "Fat%":
            for g in graphs{
                switch g.name{
                case CacheKey.fatPercent.rawValue, CacheKey.fatPercent.rollingCacheKey():
                    g.display = true
                default:
                    g.display = false
                }
            }
        case "BMI":
            for g in graphs{
                switch g.name{
                case CacheKey.bmi.rawValue, CacheKey.bmi.rollingCacheKey():
                    g.display = true
                default:
                    g.display = false
                }
            }
        case "Sleep":
                for g in graphs{
                    switch g.name{
                    case CacheKey.sleep.rawValue, CacheKey.sleep.rollingCacheKey():
                        g.display = true
                    default:
                        g.display = false
                    }
            }
        case "Motivation":
            for g in graphs{
                switch g.name{
                case CacheKey.motivation.rawValue, CacheKey.motivation.rollingCacheKey():
                    g.display = true
                default:
                    g.display = false
                }
            }
        case "Fatigue":
            for g in graphs{
                switch g.name{
                case CacheKey.fatigue.rawValue, CacheKey.fatigue.rollingCacheKey():
                    g.display = true
                default:
                    g.display = false
                }
            }
        default:
            print("WeightHRVGraphViewControler::: no graphs associated with key: \(key)")
        }
        graphView!.needsDisplay = true
        graphsTableView!.reloadData()
    }
    

    //MARK: - Private
    
    private var cache: [String: [(x: Double, y: Double)]] = [:]
    private var graphs: [GraphDefinition] = []

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
    
    private func setGraphDataFromCache(){
        for g in graphs{
            g.data = cache[g.name]!
        }
        
    }
    
    private func createGraphs(){
        
        for key in CacheKey.AllKeys{
            if let g = createGraph(forKey: key.rawValue, type: key.graphType(), colour: key.graphColour(), axis: key.axis(), size: key.size()){
                graphs.append(g)
            }
            if key.includeRolling(){
                if let g = createGraph(forKey: key.rollingCacheKey(), type: .Line, colour: key.graphColour(), axis: key.axis(), size:3.0){
                    graphs.append(g)
                }
            }
        }
        
        //add graphs to array controller
        if let gac = graphArrayController{
            gac.add(contentsOf: graphs)
        }
        
        //add to graph view
        if let gv = graphView{
            for g in graphs{
                gv.add(graph: g)
            }
        }
      
    }
    
    private func createDataCache(){
        if let td = trainingDiary{
            cache[CacheKey.hr.rawValue]         = td.hrDateOrder().map({(x: $0.date.timeIntervalSinceReferenceDate, y: $0.value)})
            cache[CacheKey.sdnn.rawValue]       = td.sdnnDateOrder().map({(x: $0.date.timeIntervalSinceReferenceDate, y: $0.value)})
            cache[CacheKey.rmssd.rawValue]      = td.rmssdDateOrder().map({(x: $0.date.timeIntervalSinceReferenceDate, y: $0.value)})
            cache[CacheKey.kg.rawValue]         = td.kgAscendingDateOrder().map({(x: $0.date.timeIntervalSinceReferenceDate, y: $0.value)})
            cache[CacheKey.fatPercent.rawValue] = td.fatPercentageDateOrder().map({(x: $0.date.timeIntervalSinceReferenceDate, y: $0.value)})
            cache[CacheKey.bmi.rawValue]        = td.bmiAscendingDateOrder().map({(x: $0.date.timeIntervalSinceReferenceDate, y: $0.value)})
            cache[CacheKey.sleep.rawValue]      = td.sleepDateOrder().map({(x: $0.date.timeIntervalSinceReferenceDate, y: $0.value)})
            cache[CacheKey.motivation.rawValue] = td.motivationDateOrder().map({(x: $0.date.timeIntervalSinceReferenceDate, y: $0.value)})
            cache[CacheKey.fatigue.rawValue]    = td.fatigueDateOrder().map({(x: $0.date.timeIntervalSinceReferenceDate, y: $0.value)})
            
            updateRollingDataCache()
            
            let hrvData = td.calculatedHRVData()
            cache[CacheKey.sdnnHard.rawValue] = hrvData.map({($0.date.timeIntervalSinceReferenceDate, $0.sdnnHard)})
            cache[CacheKey.sdnnEasy.rawValue] = hrvData.map({($0.date.timeIntervalSinceReferenceDate, $0.sdnnEasy)})
            cache[CacheKey.sdnnOff.rawValue] = hrvData.map({($0.date.timeIntervalSinceReferenceDate, $0.sdnnOff)})
            cache[CacheKey.rmssdHard.rawValue] = hrvData.map({($0.date.timeIntervalSinceReferenceDate, $0.rmssdHard)})
            cache[CacheKey.rmssdEasy.rawValue] = hrvData.map({($0.date.timeIntervalSinceReferenceDate, $0.rmssdEasy)})
            cache[CacheKey.rmssdOff.rawValue] = hrvData.map({($0.date.timeIntervalSinceReferenceDate, $0.rmssdOff)})
            
        }
        
    }
    
    private func updateRollingDataCache(){
        for key in CacheKey.AllKeys{
            cache[key.rollingCacheKey()] = createRollingData(forKey: key)
        }
    }
   
    private func createRollingData(forKey key: CacheKey) -> [(x:Double, y:Double)]{
        var result: [(x:Double, y:Double)] = []
        let rollingSum = RollingSumQueue(size: rollingDays)
        if let data = cache[key.rawValue]{
            for d in data{
                result.append((d.x, rollingSum.addAndReturnAverage(value: d.y)))
            }
        }
        
        return result
    }
    
    private func createGraph(forKey key: String, type: ChartType, colour: NSColor, axis: Axis, size: CGFloat ) -> GraphDefinition?{

        let graph = GraphDefinition(name: key, axis: axis  , type: type, format: GraphFormat(fill: false, colour: colour, fillGradientStart: colour, fillGradientEnd: colour, gradientAngle: 45, size: size, opacity: 1.0),drawZeroes: false, priority: 2)
        
        if let cacheKey = CacheKey.init(rawValue: key){
            if cacheKey.dashed(){
                graph.dash = [5.0,5.0]
            }
        }
        
        return graph

    }
    
}
