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
    @IBOutlet weak var fromDateSlider: NSSlider!
    @IBOutlet weak var toDateSlider: NSSlider!
    
    private var cache: [String: [(date: Date, value: Double)]] = [:]
    private var currentGraphs: [GraphDefinition] = []

    
    private enum CacheKey: String{
        case kg, fatPercent, hr, sdnn, rmssd, rollingKG, rollingFat, rollingHR, rollingSDNN, rollingRMSSD
        case sleep, motivation, fatigue, rollingSleep, rollingMotivation, rollingFatigue
    }
    
    @IBAction func fromDatePickerChanged(_ sender: NSDatePicker) {
        if let fds = fromDateSlider{
            if let td = trainingDiary{
                fds.doubleValue = sender.dateValue.timeIntervalSince(td.firstDayOfDiary)
            }
        }
        updateForDateChange()
    }
    
    @IBAction func fromDateSliderChanged(_ sender: NSSlider) {
        if let fdp = fromDatePicker{
            if let td = trainingDiary{
                fdp.dateValue = (td.firstDayOfDiary.addingTimeInterval(TimeInterval(sender.doubleValue)))
            }
        }
        updateForDateChange()
    }
    
    @IBAction func toDatePickerChanged(_ sender: NSDatePicker) {
        if let tds = toDateSlider{
            if let td = trainingDiary{
                tds.doubleValue = sender.dateValue.timeIntervalSince(td.firstDayOfDiary)
            }
        }
        updateForDateChange()
    }
    
    @IBAction func toDateSliderChanged(_ sender: NSSlider) {
        if let tdp = toDatePicker{
            if let td = trainingDiary{
                tdp.dateValue = (td.firstDayOfDiary.addingTimeInterval(TimeInterval(sender.doubleValue)))
            }
        }
        updateForDateChange()
    }
    
    @IBAction func printWeights(_ sender: NSButton){
        if let weights = weightArrayController.selectedObjects{
            for w in weights{
                print(w)
            }
        }
    }
    
    @IBAction func printPhysiologicals(_ sender: NSButton){
        if let physiologicals = hrArrayController.selectedObjects{
            for p in physiologicals{
                print(p)
            }
        }
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
            }
        }
        
        if let hrgv = graphView { hrgv.needsDisplay = true}

    }
    
    private func trainingDiarySet(){
        if let td = trainingDiary{
            createGraphs(forTrainingDiary: td)
            setUpSliders(forTrainingDiary: td)
            setUpPickers(forTrainingDiary: td)
            updateForDateChange()
        }
    }
    
    private func setUpPickers(forTrainingDiary td: TrainingDiary){
        if let tdp = toDatePicker{ tdp.dateValue = td.lastDayOfDiary }
        let fromDate = td.lastDayOfDiary.addDays(numberOfDays: -365)
        if let fdp = fromDatePicker{ fdp.dateValue = fromDate }
    }
    
    private func setUpSliders(forTrainingDiary td: TrainingDiary){
        let range = td.lastDayOfDiary.timeIntervalSince(td.firstDayOfDiary)
        let fromDate = td.lastDayOfDiary.addDays(numberOfDays: -365)
        if let fds = fromDateSlider{
            fds.minValue = 0.0
            fds.maxValue = range
            fds.doubleValue = fromDate.timeIntervalSince(td.firstDayOfDiary)
        }
        if let tds = toDateSlider{
            tds.minValue = 0.0
            tds.maxValue = range
            tds.doubleValue = range
        }
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

        var graphs: [GraphDefinition] = []
        
        cache[CacheKey.hr.rawValue] = td.hrDateOrder()
        graphs.append(GraphDefinition(name: CacheKey.hr.rawValue, data: cache[CacheKey.hr.rawValue]!, axis: .Primary, type: .Point, format: GraphFormat(fill: false, colour: .blue, fillGradientStart: .blue, fillGradientEnd: .blue, gradientAngle: 0.0, size: 2.0),drawZeroes: false, priority: 1  ))
        
        cache[CacheKey.rollingHR.rawValue] = createRollingData(fromData: cache[CacheKey.hr.rawValue]!, everyXDays: 7)
        graphs.append(GraphDefinition(name: CacheKey.rollingHR.rawValue, data: cache[CacheKey.rollingHR.rawValue]!, axis: .Primary, type: .Line, format: GraphFormat(fill: false, colour: .blue, fillGradientStart: .blue, fillGradientEnd: .blue, gradientAngle: 0.0, size: 2.0),drawZeroes: false, priority: 1  ))
        
        cache[CacheKey.sdnn.rawValue] = td.sdnnDateOrder()
        graphs.append(GraphDefinition(name: CacheKey.sdnn.rawValue, data: cache[CacheKey.sdnn.rawValue]!, axis: .Primary, type: .Point, format: GraphFormat(fill: false, colour: .red , fillGradientStart: .red, fillGradientEnd: .red, gradientAngle: 0.0, size: 2.0),drawZeroes: false, priority: 3  ))
        
        cache[CacheKey.rollingSDNN.rawValue] = createRollingData(fromData: cache[CacheKey.sdnn.rawValue]!, everyXDays: 7)
        graphs.append(GraphDefinition(name: CacheKey.rollingSDNN.rawValue, data: cache[CacheKey.rollingSDNN.rawValue]!, axis: .Primary, type: .Line, format: GraphFormat(fill: false, colour: .red , fillGradientStart: .red, fillGradientEnd: .red, gradientAngle: 0.0, size: 2.0),drawZeroes: false, priority: 3  ))
        
        cache[CacheKey.rmssd.rawValue] = td.rmssdDateOrder()
        graphs.append(GraphDefinition(name: CacheKey.rmssd.rawValue, data: cache[CacheKey.rmssd.rawValue]!, axis: .Primary, type: .Point, format: GraphFormat(fill: false, colour: .green , fillGradientStart: .green, fillGradientEnd: .green, gradientAngle: 0.0, size: 2.0),drawZeroes: false, priority: 2  ))
        
        cache[CacheKey.rollingRMSSD.rawValue] = createRollingData(fromData: cache[CacheKey.rmssd.rawValue]!, everyXDays: 7)
        graphs.append(GraphDefinition(name: CacheKey.rollingRMSSD.rawValue, data: cache[CacheKey.rollingRMSSD.rawValue]!, axis: .Primary, type: .Line, format: GraphFormat(fill: false, colour: .green , fillGradientStart: .green, fillGradientEnd: .green, gradientAngle: 0.0, size: 2.0),drawZeroes: false, priority: 2  ))
        
        cache[CacheKey.kg.rawValue] = td.kgAscendingDateOrder()
        graphs.append(GraphDefinition(name: CacheKey.kg.rawValue, data: cache[CacheKey.kg.rawValue]!, axis: .Primary, type: .Point, format: GraphFormat(fill: false, colour: .black, fillGradientStart: .black, fillGradientEnd: .black, gradientAngle: 45, size: 2.0), drawZeroes: false, priority: 1))
        
        cache[CacheKey.rollingKG.rawValue] = createRollingData(fromData: cache[CacheKey.kg.rawValue]!, everyXDays: 30)
        graphs.append(GraphDefinition(name: CacheKey.rollingKG.rawValue, data: cache[CacheKey.rollingKG.rawValue]!, axis: .Primary, type: .Line, format: GraphFormat(fill: false, colour: .black, fillGradientStart: .black, fillGradientEnd: .black, gradientAngle: 45, size: 2.0), drawZeroes: false, priority: 1))
        
        cache[CacheKey.fatPercent.rawValue] = td.fatPercentageDateOrder()
        graphs.append(GraphDefinition(name: CacheKey.fatPercent.rawValue, data: cache[CacheKey.fatPercent.rawValue]!, axis: .Secondary  , type: .Point, format: GraphFormat(fill: false, colour: .magenta, fillGradientStart: .magenta, fillGradientEnd: .magenta, gradientAngle: 45, size: 2.0),drawZeroes: false, priority: 2))
        
        cache[CacheKey.rollingFat.rawValue] = createRollingData(fromData: cache[CacheKey.fatPercent.rawValue]!, everyXDays: 30)
        graphs.append(GraphDefinition(name: CacheKey.rollingFat.rawValue, data: cache[CacheKey.rollingFat.rawValue]!, axis: .Secondary  , type: .Line, format: GraphFormat(fill: false, colour: .magenta, fillGradientStart: .magenta, fillGradientEnd: .magenta, gradientAngle: 45, size: 2.0),drawZeroes: false, priority: 2))
        
        cache[CacheKey.sleep.rawValue] = td.sleepDateOrder()
        graphs.append(GraphDefinition(name: CacheKey.sleep.rawValue, data: cache[CacheKey.sleep.rawValue]!, axis: .Secondary  , type: .Point, format: GraphFormat(fill: false, colour: .cyan, fillGradientStart: .cyan, fillGradientEnd: .cyan, gradientAngle: 45, size: 2.0),drawZeroes: false, priority: 2))
        
        cache[CacheKey.rollingSleep.rawValue] = createRollingData(fromData: cache[CacheKey.sleep.rawValue]!, everyXDays: 7)
        graphs.append(GraphDefinition(name: CacheKey.rollingSleep.rawValue, data: cache[CacheKey.rollingSleep.rawValue]!, axis: .Secondary  , type: .Line, format: GraphFormat(fill: false, colour: .cyan, fillGradientStart: .cyan, fillGradientEnd: .cyan, gradientAngle: 45, size: 2.0),drawZeroes: false, priority: 2))

        cache[CacheKey.motivation.rawValue] = td.motivationDateOrder()
        graphs.append(GraphDefinition(name: CacheKey.motivation.rawValue, data: cache[CacheKey.motivation.rawValue]!, axis: .Secondary  , type: .Point, format: GraphFormat(fill: false, colour: .orange, fillGradientStart: .orange, fillGradientEnd: .orange, gradientAngle: 45, size: 2.0),drawZeroes: false, priority: 2))
        
        cache[CacheKey.rollingMotivation.rawValue] = createRollingData(fromData: cache[CacheKey.motivation.rawValue]!, everyXDays: 7)
        graphs.append(GraphDefinition(name: CacheKey.rollingMotivation.rawValue, data: cache[CacheKey.rollingMotivation.rawValue]!, axis: .Secondary  , type: .Line, format: GraphFormat(fill: false, colour: .orange, fillGradientStart: .orange, fillGradientEnd: .orange, gradientAngle: 45, size: 2.0),drawZeroes: false, priority: 2))

        cache[CacheKey.fatigue.rawValue] = td.fatigueDateOrder()
        graphs.append(GraphDefinition(name: CacheKey.fatigue.rawValue, data: cache[CacheKey.fatigue.rawValue]!, axis: .Secondary  , type: .Point, format: GraphFormat(fill: false, colour: .purple, fillGradientStart: .purple, fillGradientEnd: .purple, gradientAngle: 45, size: 2.0),drawZeroes: false, priority: 2))
        
        cache[CacheKey.rollingFatigue.rawValue] = createRollingData(fromData: cache[CacheKey.fatigue.rawValue]!, everyXDays: 7)
        graphs.append(GraphDefinition(name: CacheKey.rollingFatigue.rawValue, data: cache[CacheKey.rollingFatigue.rawValue]!, axis: .Secondary  , type: .Line, format: GraphFormat(fill: false, colour: .purple, fillGradientStart: .purple, fillGradientEnd: .purple, gradientAngle: 45, size: 2.0),drawZeroes: false, priority: 2))


        return graphs
        
    }
    
    
    private func createRollingData(fromData data: [(date: Date, value: Double)], everyXDays x: Int) -> [(date:Date, value:Double)]{
        var result: [(date:Date, value:Double)] = []
        let rollingSum = RollingSumQueue(size: x)
        
        for d in data{
            result.append((d.date, rollingSum.addAndReturnAverage(value: d.value)))
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
    
    
}
