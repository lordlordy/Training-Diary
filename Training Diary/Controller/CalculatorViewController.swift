//
//  CalculatorViewController.swift
//  Training Diary
//
//  Created by Steven Lord on 17/04/2018.
//  Copyright © 2018 Steven Lord. All rights reserved.
//

import Cocoa

class CalculatorViewController: NSViewController, NSComboBoxDataSource {

    @objc dynamic var startCTL:             Double = 100.0  { didSet{ calculateTSSPerDay() }}
    @objc dynamic var daysInactive:         Double = 0.0    { didSet{ calculateTSSPerDay() }}
    @objc dynamic var targetCTL:            Double = 100.0  { didSet{ calculateTSSPerDay() }}
    @objc dynamic var daysOfActivity:       Double = 1.0    { didSet{ calculateTSSPerDay() }}
    @objc dynamic var tssPerDay:            Double = 0.0
    @objc dynamic var tssPerAlternateDay:   Double = 0.0

    @objc dynamic var trainingDiaryName: String = ""
    
    @IBOutlet weak var activityComboBox: NSComboBox!
    
    private var trainingDiary: TrainingDiary?

    @IBAction func activityChanged(_ sender: Any) {
        calculateTSSPerDay()
    }
    override func viewDidLoad() {
        if let mainVC = NSApplication.shared.windows[0].contentViewController as? ViewController{
            trainingDiary = mainVC.currentSelectedDiary
        }
        if let td = trainingDiary{
            trainingDiaryName = td.name!
            print(trainingDiaryName)
        }
    }
    
    
    //MARK: - NSComboBoxDataSource
    func comboBox(_ comboBox: NSComboBox, objectValueForItemAt index: Int) -> Any? {
        let activities = trainingDiary!.activitiesArray().map({$0.name})
        if index < activities.count{
            return activities[index]
        }
        return nil
    }
    
    func numberOfItems(in comboBox: NSComboBox) -> Int {
        if let td = trainingDiary{
            return td.activitiesArray().count
        }
        return 0
    }
    
    private func selectedActivity() -> Activity?{
        if let aString = activityComboBox?.stringValue{
            if let td = trainingDiary{
                if let activity = td.activity(forString: aString){
                    return activity
                }
            }
        }
        return nil
    }
    
    private func calculateTSSPerDay(){
        if let activity = selectedActivity(){
            let start = Date()
            print("Calculating TSS Per day...")
            let da = Int(daysOfActivity)
            var decaySum: Double = 0.0
        
            if da > 0{
                for i in 0...(da-1){
                    decaySum += pow(activity.ctlDecayFactor,Double(i))
                }
                
                tssPerDay = (targetCTL - startCTL * pow(activity.ctlDecayFactor, daysInactive + daysOfActivity)) / (activity.ctlImpactFactor * decaySum)

            }
            
            print("DONE in \(Date().timeIntervalSince(start))s")
            calculateTSSPerAlternateDay(forDays: da,activity: activity)
        }
        
    }
    
    private func geometricSumOfDecays(tssPerDay tss: Double, forDays days: Int, activity a: Activity) -> Double{
        var result: Double = 0.0
        for i in 0...(days-1){
            result += tss * pow(a.ctlDecayFactor,Double(i))
        }
        return result
    }
    
    private func calculateTSSPerAlternateDay(forDays days: Int, activity a: Activity){
        if even(number: days-1){
            calculateTSSPerAlternateDayEven(forDays: days, activity: a)
        }else{
            calculateTSSPerAlternateDayOdd(forDays: days, activity: a)
        }
    }

    private func calculateTSSPerAlternateDayOdd(forDays days: Int, activity a: Activity){
        if days > 0{
            var ctlAlternate: Double = 0.0
            
            for i in 1...Int(days/2){
                ctlAlternate += pow(a.ctlDecayFactor,Double(2*i-1))
            }

            tssPerAlternateDay =  geometricSumOfDecays(tssPerDay: tssPerDay, forDays: days, activity: a) / ctlAlternate
            
        }
    }

    private func calculateTSSPerAlternateDayEven(forDays days: Int, activity a: Activity){
        let loopTo = Int(Double(days-1)/2.0)
        var ctlAlternate: Double = 0.0
        
        for i in 0...loopTo{
            ctlAlternate += pow(a.ctlDecayFactor,Double(2*i))
        }
        
        tssPerAlternateDay = geometricSumOfDecays(tssPerDay: tssPerDay, forDays: days, activity: a) / ctlAlternate

    }

    private func even(number: Int) -> Bool{
        return number % 2 == 0
    }
}
