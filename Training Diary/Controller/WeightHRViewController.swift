//
//  WeightHRViewController.swift
//  Training Diary
//
//  Created by Steven Lord on 09/11/2017.
//  Copyright © 2017 Steven Lord. All rights reserved.
//

import Cocoa

class WeightHRViewController: NSViewController {

    @objc dynamic var trainingDiary: TrainingDiary?{
        didSet{ trainingDiarySet() }
    }
    @IBOutlet var weightArrayController: NSArrayController!
    @IBOutlet var hrArrayController: NSArrayController!
    @IBOutlet weak var hrGraphView: GraphView!
    @IBOutlet weak var weightGraphView: GraphView!
    @IBOutlet weak var fromDatePicker: NSDatePicker!
    @IBOutlet weak var toDatePicker: NSDatePicker!
    @IBOutlet weak var fromDateSlider: NSSlider!
    @IBOutlet weak var toDateSlider: NSSlider!
    
    private var cache: [String: [(date: Date, value: Double)]] = [:]
    
    private enum CacheKey: String{
        case kg, fatPercent, hr, sdnn, rmssd, rollingKG, rollingFat, rollingHR, rollingSDNN, rollingRMSSD
    }
    
    @IBAction func fromDatePickerChanged(_ sender: NSDatePicker) {
        if let fds = fromDateSlider{
            if let td = trainingDiary{
                fds.doubleValue = sender.dateValue.timeIntervalSince(td.firstDayOfDiary!)
            }
        }
        updateForDateChange()
    }
    
    @IBAction func fromDateSliderChanged(_ sender: NSSlider) {
        if let fdp = fromDatePicker{
            if let td = trainingDiary{
                fdp.dateValue = (td.firstDayOfDiary?.addingTimeInterval(TimeInterval(sender.doubleValue)))!
            }
        }
        updateForDateChange()
    }
    
    @IBAction func toDatePickerChanged(_ sender: NSDatePicker) {
        if let tds = toDateSlider{
            if let td = trainingDiary{
                tds.doubleValue = sender.dateValue.timeIntervalSince(td.firstDayOfDiary!)
            }
        }
        updateForDateChange()
    }
    
    @IBAction func toDateSliderChanged(_ sender: NSSlider) {
        if let tdp = toDatePicker{
            if let td = trainingDiary{
                tdp.dateValue = (td.firstDayOfDiary?.addingTimeInterval(TimeInterval(sender.doubleValue)))!
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
    
    
    override func viewDidLoad() {
            trainingDiarySet()
    }
    
    private func updateForDateChange(){
    
        if let from = fromDatePicker?.dateValue{
            if let to = toDatePicker?.dateValue{
                if let graphView = weightGraphView{
                    for g in graphView.graphs{
                        g.data = (cache[g.name]?.filter({$0.date >= from && $0.date <= to }))!
                    }
                }
                if let graphView = hrGraphView{
                    for g in graphView.graphs{
                        g.data = (cache[g.name]?.filter({$0.date >= from && $0.date <= to }))!
                    }
                }
            }
        }
        
        if let hrgv = hrGraphView { hrgv.needsDisplay = true}
        if let wgv = weightGraphView { wgv.needsDisplay = true}

    }
    
    private func trainingDiarySet(){
        if let td = trainingDiary{
            createGraphs(forTrainingDiary: td)
            setUpPickers(forTrainingDiary: td)
            setUpSliders(forTrainingDiary: td)
        }
    }
    
    private func setUpPickers(forTrainingDiary td: TrainingDiary){
        if let from = td.firstDayOfDiary{
            if let fdp = fromDatePicker{
                fdp.dateValue = from
            }
        }
        if let to = td.lastDayOfDiary{
            if let tdp = toDatePicker{
                tdp.dateValue = to
            }
        }
    }
    
    private func setUpSliders(forTrainingDiary td: TrainingDiary){
        let range = td.lastDayOfDiary?.timeIntervalSince(td.firstDayOfDiary!)
        if let fds = fromDateSlider{
            fds.minValue = 0.0
            fds.maxValue = range!
            fds.doubleValue = 0.0
        }
        if let tds = toDateSlider{
            tds.minValue = 0.0
            tds.maxValue = range!
            tds.doubleValue = range!
        }
    }
    
    private func createGraphs(forTrainingDiary td: TrainingDiary){
            if let wgv = weightGraphView{
                let kg = td.kgAscendingDateOrder()
                let fatPercent = td.fatPercentageDateOrder()
                let rollingKG = createRollingData(fromData: kg, everyXDays: 30)
                let rollingFat = createRollingData(fromData: fatPercent, everyXDays: 30)
                let kgGraphDefinition = GraphView.GraphDefinition(name: CacheKey.kg.rawValue, data: kg, axis: .Primary, type: .Point, format: GraphFormat(fill: false, colour: .systemPink, fillGradientStart: .systemPink, fillGradientEnd: .systemPink, gradientAngle: 45, size: 1.0), drawZeroes: false, priority: 1)
                let rollingKGGraphDefinition = GraphView.GraphDefinition(name: CacheKey.rollingKG.rawValue, data: rollingKG, axis: .Primary, type: .Line, format: GraphFormat(fill: false, colour: .red, fillGradientStart: .red, fillGradientEnd: .red, gradientAngle: 45, size: 1.0), drawZeroes: false, priority: 1)
                
                let fatPercentGraphDefinition = GraphView.GraphDefinition(name: CacheKey.fatPercent.rawValue, data: fatPercent, axis: .Secondary  , type: .Point, format: GraphFormat(fill: false, colour: .green, fillGradientStart: .red, fillGradientEnd: .green, gradientAngle: 45, size: 1.0),drawZeroes: false, priority: 2)
                let rollingFatPercentGraphDefinition = GraphView.GraphDefinition(name: CacheKey.rollingFat.rawValue, data: rollingFat, axis: .Secondary  , type: .Line, format: GraphFormat(fill: false, colour: .green, fillGradientStart: .red, fillGradientEnd: .green, gradientAngle: 45, size: 1.0),drawZeroes: false, priority: 2)

                cache[CacheKey.kg.rawValue] = kg
                cache[CacheKey.rollingKG.rawValue] = rollingKG
                cache[CacheKey.fatPercent.rawValue] = fatPercent
                cache[CacheKey.rollingFat.rawValue] = rollingFat
                
                wgv.add(graph: kgGraphDefinition)
                wgv.add(graph: rollingKGGraphDefinition)
                wgv.add(graph: fatPercentGraphDefinition)
                wgv.add(graph: rollingFatPercentGraphDefinition)
                
                wgv.primaryAxisMinimumOverride = 68.0
                wgv.secondaryAxisMinimumOverride = 4.9
            }
        
            if let hrgv = hrGraphView{
                let hr = td.hrPercentageDateOrder()
                let rollingHR = createRollingData(fromData: hr, everyXDays: 7)
                let sdnn = td.sdnnPercentageDateOrder()
                let rollingSDNN = createRollingData(fromData: sdnn, everyXDays: 7)
                let rmssd = td.rmssdPercentageDateOrder()
                let rollingRMSSD = createRollingData(fromData: rmssd, everyXDays: 7)

                let hrGraphDefinition = GraphView.GraphDefinition(name: CacheKey.hr.rawValue, data: hr, axis: .Primary, type: .Point, format: GraphFormat(fill: false, colour: .blue, fillGradientStart: .blue, fillGradientEnd: .blue, gradientAngle: 0.0, size: 1.0),drawZeroes: false, priority: 1  )
                let rollingHRGraphDefinition = GraphView.GraphDefinition(name: CacheKey.rollingHR.rawValue, data: rollingHR, axis: .Primary, type: .Line, format: GraphFormat(fill: false, colour: .blue, fillGradientStart: .blue, fillGradientEnd: .blue, gradientAngle: 0.0, size: 1.0),drawZeroes: false, priority: 1  )

                let sdnnGraphDefinition = GraphView.GraphDefinition(name: CacheKey.sdnn.rawValue, data: sdnn, axis: .Secondary, type: .Point, format: GraphFormat(fill: false, colour: .red , fillGradientStart: .red, fillGradientEnd: .red, gradientAngle: 0.0, size: 1.0),drawZeroes: false, priority: 3  )
                let rollingSDNNGraphDefinition = GraphView.GraphDefinition(name: CacheKey.rollingSDNN.rawValue, data: rollingSDNN, axis: .Secondary, type: .Line, format: GraphFormat(fill: false, colour: .red , fillGradientStart: .red, fillGradientEnd: .red, gradientAngle: 0.0, size: 1.0),drawZeroes: false, priority: 3  )
                let rmssdGraphDefinition = GraphView.GraphDefinition(name: CacheKey.rmssd.rawValue, data: rmssd, axis: .Secondary, type: .Point, format: GraphFormat(fill: false, colour: .green , fillGradientStart: .green, fillGradientEnd: .green, gradientAngle: 0.0, size: 1.0),drawZeroes: false, priority: 2  )
                let rollingRMSSDGraphDefinition = GraphView.GraphDefinition(name: CacheKey.rollingRMSSD.rawValue, data: rollingRMSSD, axis: .Secondary, type: .Line, format: GraphFormat(fill: false, colour: .green , fillGradientStart: .green, fillGradientEnd: .green, gradientAngle: 0.0, size: 1.0),drawZeroes: false, priority: 2  )

                cache[CacheKey.hr.rawValue] = hr
                cache[CacheKey.rollingHR.rawValue] = rollingHR
                cache[CacheKey.sdnn.rawValue] = sdnn
                cache[CacheKey.rollingSDNN.rawValue] = rollingSDNN
                cache[CacheKey.rmssd.rawValue] = rmssd
                cache[CacheKey.rollingRMSSD.rawValue] = rollingRMSSD
                
                hrgv.add(graph: hrGraphDefinition)
                hrgv.add(graph: rollingHRGraphDefinition)
                hrgv.primaryAxisMinimumOverride = 25.0
                hrgv.add(graph: sdnnGraphDefinition)
                hrgv.add(graph: rollingSDNNGraphDefinition)
                hrgv.add(graph: rmssdGraphDefinition)
                hrgv.add(graph: rollingRMSSDGraphDefinition)
                
        }
    
    }
    
    private func createRollingData(fromData data: [(date: Date, value: Double)], everyXDays x: Int) -> [(date:Date, value:Double)]{
        var result: [(date:Date, value:Double)] = []
        let rollingSum = RollingSumQueue(size: x)
        
        for d in data{
            result.append((d.date, rollingSum.addAndReturnAverage(value: d.value)))
        }
        
        return result
    }
    
    
}
