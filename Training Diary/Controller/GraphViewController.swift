//
//  GraphViewController.swift
//  Training Diary
//
//  Created by Steven Lord on 18/11/2017.
//  Copyright © 2017 Steven Lord. All rights reserved.
//

import Cocoa

class GraphViewController: NSViewController {

    fileprivate struct Constants{
        static let numberOfXAxisLabels: Int = 12
    }
    
    @objc dynamic var trainingDiary: TrainingDiary?{
        didSet{
            trainingDiarySet()
            setUpSliders()
        }
    }
    @IBOutlet weak var graphView: GraphView!
    @IBOutlet weak var fromDatePicker: NSDatePicker!
    @IBOutlet weak var toDatePicker: NSDatePicker!
    @IBOutlet weak var fromDateSlider: NSSlider!
    @IBOutlet weak var toDateSlider: NSSlider!
    @IBOutlet weak var activityComboBox: NSComboBox!
    
    private var selectedActivity: Activity = Activity.All
    
    @IBAction func activityChanged(_ sender: NSComboBox) {
        print("Activity changed to \(sender.stringValue)")
        switch sender.stringValue{
        case Activity.All.rawValue:     selectedActivity = .All
        case Activity.Swim.rawValue:    selectedActivity = .Swim
        case Activity.Bike.rawValue:    selectedActivity = .Bike
        case Activity.Run.rawValue:     selectedActivity = .Run
        case Activity.Gym.rawValue:     selectedActivity = .Gym
        case Activity.Walk.rawValue:    selectedActivity = .Walk
        case Activity.Other.rawValue:   selectedActivity = .Other
        default:
            print("Not sure how you managed to select \(sender.stringValue) as this was not implemented as an activity for selection in the TSB tab view")
        }
        updateData()
        graphView.needsDisplay = true
    }
    
    @IBAction func fromSlider(_ sender: NSSlider) {
        if let dp = fromDatePicker{
            let cal = Calendar.current
            var dc = cal.dateComponents([.day,.month,.year], from: dp.dateValue)
            dc.year = sender.integerValue
            let newDate = cal.date(from: dc)
            dp.dateValue = newDate!
            updateData()
        }
    }

    @IBAction func toSlider(_ sender: NSSlider) {
        if let dp = toDatePicker{
            let cal = Calendar.current
            var dc = cal.dateComponents([.day,.month,.year], from: dp.dateValue)
            dc.year = sender.integerValue
            let newDate = cal.date(from: dc)
            dp.dateValue = newDate!
            updateData()
        }
    }
    
    
    @IBAction func fromDateChanged(_ sender: NSDatePicker) {
        if let ds = fromDateSlider{
            let year = sender.dateValue.year()
            ds.doubleValue = Double(year)
        }
        updateData()
    }
    
    @IBAction func toDateChanged(_ sender: NSDatePicker) {
        if let ds = toDateSlider{
            let year = sender.dateValue.year()
            ds.doubleValue = Double(year)
        }
        updateData()
    }
    
    
    override func viewWillAppear() {
        trainingDiarySet()
    }
    
    func setTrainingDiary(_ td: TrainingDiary){
        self.trainingDiary = td
        td.addObserver(self, forKeyPath: TrainingDiaryProperty.ctlDays.rawValue, options: NSKeyValueObservingOptions.new, context: nil)
        td.addObserver(self, forKeyPath: TrainingDiaryProperty.atlDays.rawValue, options: NSKeyValueObservingOptions.new, context: nil)
        td.addObserver(self, forKeyPath: TrainingDiaryProperty.swimCTLDays.rawValue, options: NSKeyValueObservingOptions.new, context: nil)
        td.addObserver(self, forKeyPath: TrainingDiaryProperty.swimATLDays.rawValue, options: NSKeyValueObservingOptions.new, context: nil)
        td.addObserver(self, forKeyPath: TrainingDiaryProperty.bikeCTLDays.rawValue, options: NSKeyValueObservingOptions.new, context: nil)
        td.addObserver(self, forKeyPath: TrainingDiaryProperty.bikeATLDays.rawValue, options: NSKeyValueObservingOptions.new, context: nil)
        td.addObserver(self, forKeyPath: TrainingDiaryProperty.runCTLDays.rawValue, options: NSKeyValueObservingOptions.new, context: nil)
        td.addObserver(self, forKeyPath: TrainingDiaryProperty.runATLDays.rawValue, options: NSKeyValueObservingOptions.new, context: nil)
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?){
        
        switch keyPath{
        case TrainingDiaryProperty.ctlDays.rawValue?, TrainingDiaryProperty.atlDays.rawValue?:
//            trainingDiary?.calcTSB(forActivity: Activity.All, fromDate: (trainingDiary?.firstDayOfDiary!)!)
            trainingDiary?.calcTSB(forActivity: Activity.Gym, fromDate: (trainingDiary?.firstDayOfDiary!)!)
            trainingDiary?.calcTSB(forActivity: Activity.Walk, fromDate: (trainingDiary?.firstDayOfDiary!)!)
            trainingDiary?.calcTSB(forActivity: Activity.Other, fromDate: (trainingDiary?.firstDayOfDiary!)!)
            updateData()
            graphView.needsDisplay = true
        case TrainingDiaryProperty.swimCTLDays.rawValue?, TrainingDiaryProperty.swimATLDays.rawValue?:
            trainingDiary?.calcTSB(forActivity: Activity.Swim, fromDate: (trainingDiary?.firstDayOfDiary!)!)
            updateData()
            graphView.needsDisplay = true
        case TrainingDiaryProperty.bikeCTLDays.rawValue?, TrainingDiaryProperty.bikeATLDays.rawValue?:
            trainingDiary?.calcTSB(forActivity: Activity.Bike, fromDate: (trainingDiary?.firstDayOfDiary!)!)
            updateData()
            graphView.needsDisplay = true
        case TrainingDiaryProperty.runCTLDays.rawValue?, TrainingDiaryProperty.runATLDays.rawValue?:
            trainingDiary?.calcTSB(forActivity: Activity.Run, fromDate: (trainingDiary?.firstDayOfDiary!)!)
            updateData()
            graphView.needsDisplay = true
        default:
            print("~~~~~~~ Am I meant to be observing key path \(String(describing: keyPath))")
        }
        
    }


    private func trainingDiarySet(){
        if let td = trainingDiary{
            fromDatePicker!.dateValue = td.firstDayOfDiary!
            toDatePicker!.dateValue = td.lastDayOfDiary!
        }
        updateData()
    }
    
    private func setUpSliders(){
        let firstYear = trainingDiary!.firstYear()
        let lastYear = trainingDiary!.lastYear()
        let range = lastYear - firstYear
        if let fds = fromDateSlider{
            fds.maxValue = Double(lastYear)
            fds.minValue = Double(firstYear)
            fds.numberOfTickMarks = range + 1
            fds.doubleValue = fds.minValue
        }
        if let tds = toDateSlider{
            tds.maxValue = Double(lastYear)
            tds.minValue = Double(firstYear)
            tds.numberOfTickMarks = range + 1
            tds.doubleValue = tds.maxValue
        }
    }
    
    private func updateData(){
        if let fdp = fromDatePicker{
            if let tdp = toDatePicker{
                if let td = trainingDiary{
                    if let graph = graphView{
                        let tsb  = td.getTSB(forActivity: selectedActivity, fromDate: fdp.dateValue, toDate: tdp.dateValue)
                        let tss = td.getValues(forActivity: selectedActivity, andUnit: .TSS, fromDate: fdp.dateValue, toDate: tdp.dateValue)
                        graph.data1 = tsb.map{$0.tsb}
                        graph.data2 = tsb.map{$0.atl}
                        graph.data3 = tsb.map{$0.ctl}
                        graph.data4 = tss
                        
                        graph.xAxisLabelStrings = getXAxisLabels(fromDate: fdp.dateValue      , toDate: tdp.dateValue)
                        
                    }
                }
            }
        }
    }
    
    private func getXAxisLabels(fromDate from: Date, toDate to: Date) -> [String]{
        let gap = to.timeIntervalSince(from) / Double(Constants.numberOfXAxisLabels)
        var result: [String] = []
        result.append(from.dateOnlyShorterString())
        for i in 1...Constants.numberOfXAxisLabels{
            result.append(from.addingTimeInterval(TimeInterval.init(gap*Double(i))).dateOnlyShorterString())
        }
        return result
    }
    
 
}
