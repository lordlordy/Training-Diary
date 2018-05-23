//
//  EddingtonTreeViewController.swift
//  Training Diary
//
//  Created by Steven Lord on 08/03/2018.
//  Copyright © 2018 Steven Lord. All rights reserved.
//

import Cocoa

class EddingtonTreeViewController: TrainingDiaryViewController, ReferenceToMainProtocol{

    
    @IBOutlet var treeController: NSTreeController!
    
    private var mainViewController: ViewController!
    
    func setMainViewControllerReference(to vc: ViewController) {
        mainViewController = vc
    }
 
    @IBAction func calculateAll(_ sender: NSButton) {
        calculatedLTD()
    }
    
    @IBAction func calculateTreeSelection(_ sender: Any) {
        let calculator = EddingtonNumberCalculator()
        for e in selectedEddingtonNumbers(){
            let result = calculator.quickCaclulation(forDayType: e.dayType!,forActivity: e.activity!, andType: e.activityType!, equipment: e.equipment!, andPeriod: Period(rawValue: e.period!)!, andUnit: Unit(rawValue: e.unit!)!, inTrainingDiary: trainingDiary!)
            trainingDiary!.addLTDEddingtonNumber(forDayType: e.dayType!, forActivity: e.activity!, type: e.activityType!, equipment: e.equipment!, period: Period(rawValue: e.period!)!, unit: Unit(rawValue: e.unit!)!, value: result.ednum, plusOne: result.plusOne, maturity: result.maturity)
            
            print("\(e.shortCode) : \(result)")
        }
    }
    
    @IBAction func outlineViewDoubleClicked(_ sender: NSOutlineView) {
        let item = sender.item(atRow: sender.clickedRow)
        
        if sender.isItemExpanded(item){
            sender.collapseItem(item)
        }else{
            sender.expandItem(item)
        }
    }
    
    @IBAction func exportSelectionAsHTML(_ sender: Any) {
        HTMLGenerateAndSave().saveAsHTML(selectedEddingtonNumbers().sorted(by: {$0.code < $1.code}), fromView: view)
    }
    
    @IBAction func exportSelectionAsJSON(_ sender: Any) {
        
        if let url = OpenAndSaveDialogues().saveFilePath(suggestedFileName: "LTDEddingtonNumbers", allowFileTypes: ["json"]){
                        
            if let jsonString = JSONExporter().createJSON(forLTDEddingtonNumbers: Array(selectedEddingtonNumbers())){
                do{
                    try jsonString.write(to: url, atomically: true, encoding: String.Encoding.utf8.rawValue)
                }catch{
                    print("Unable to save JSON")
                    print(error)
                }
            }
        }
        
    }
    
    @IBAction func exportSelectionAsCSV(_ sender: Any) {
        
        if let url = OpenAndSaveDialogues().saveFilePath(suggestedFileName: "LTDEddingtonNumbers", allowFileTypes: ["csv"]){
            do{
                try CSVExporter().convertToCSV(Array(selectedEddingtonNumbers())).write(to: url, atomically: true, encoding: .utf8)
            }catch{
                print("Unable to save CSV")
                print(error)
            }
        }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if let tc = treeController{
            tc.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        }
    }
    
    //MARK: - Private
    
    private func calculatedLTD(){
        //this is a calculation of all possible ed nums
        var total = 0
        let dayCountThreshold: Int = 25
        
        let timeRemainingFormatter = DateComponentsFormatter()
        timeRemainingFormatter.allowedUnits = [ .hour, .minute, .second]
        timeRemainingFormatter.unitsStyle = .abbreviated
        timeRemainingFormatter.includesApproximationPhrase = true
        timeRemainingFormatter.includesTimeRemainingPhrase = true
        timeRemainingFormatter.maximumUnitCount = 2
        
        let timeTakenFormatter = DateComponentsFormatter()
        timeTakenFormatter.allowedUnits = [ .hour, .minute, .second]
        timeTakenFormatter.unitsStyle = .abbreviated
        
        mainViewController!.mainStatusField!.stringValue = "EDDINGTON LTD CALCULATION OF ALL: estimating total to be calculated... "
        
        //test approach - need to evaluate if this is worth doing
        let localWorkoutCopy: [Workout] = trainingDiary!.allWorkouts()
        
        DispatchQueue.global(qos: .userInitiated).async {
            
            //count how many we're calculting
            for dt in self.trainingDiary!.eddingtonDayTypes(){
                
                let isDerivedDayType: Bool = DayType(rawValue:dt)?.isDerived() ?? false
                
                if (dt == ConstantString.EddingtonAll.rawValue || isDerivedDayType || self.trainingDiary!.dayCount(forTypeString: dt) > dayCountThreshold){
                    
                    var periods: [Period] = [Period.Day]
                    if dt == ConstantString.EddingtonAll.rawValue{
                        periods = Period.eddingtonNumberPeriods
                    }
                    for a in self.trainingDiary!.eddingtonActivities(){
                        for e in self.trainingDiary!.eddingtonEquipment(forActivityString: a){
                            for at in self.trainingDiary!.eddingtonActivityTypes(forActivityString: a){
                                
                                var units = Unit.activityUnits
                                
                                if (a == ConstantString.EddingtonAll.rawValue && at == ConstantString.EddingtonAll.rawValue && e == ConstantString.EddingtonAll.rawValue){
                                    units = Unit.allUnits
                                }else if (at == ConstantString.EddingtonAll.rawValue && e == ConstantString.EddingtonAll.rawValue){
                                    //metrics only calculated on the activity for ALL types and ALL Equipment
                                    units.append(contentsOf: Unit.metrics)
                                }
                                
                                // lets check if worth doing any calcs
                                
                                let workoutCount = localWorkoutCopy.filter({ (w: Workout) -> Bool in
                                    let aCorrect = a == "All" || w.activityString == a
                                    let atCorrect = at == "All" || w.activityTypeString == at
                                    let eCorrect = e == "All" || w.equipmentName == e
                                    return aCorrect && atCorrect && eCorrect}).count
                                
                                if workoutCount > Int(Constant.WorkoutThresholdForEdNumberCount.rawValue){
                                    for _ in units.sorted(by: {$0.rawValue < $1.rawValue}){
                                        for _ in periods{
                                            total += 1
                                        }// end Period loop
                                    }// end unit loop
                                }//end else on workout count chedk
                            }// end type loop
                        }// end equipment loop
                    }// end activity loop
                }// end of dayType count check
            }//end dayType loop
            
            let start = Date()
            
            var count: Int = 0
            let calculator = EddingtonNumberCalculator()
            var name: String = ""
            
            for dt in self.trainingDiary!.eddingtonDayTypes(){
                let isDerivedDayType: Bool = DayType(rawValue:dt)?.isDerived() ?? false
                if (dt == ConstantString.EddingtonAll.rawValue || isDerivedDayType || self.trainingDiary!.dayCount(forTypeString: dt) > dayCountThreshold){
                   
                    var periods: [Period] = [Period.Day]
                    if dt == ConstantString.EddingtonAll.rawValue{
                        periods = Period.eddingtonNumberPeriods
                    }
                    for a in self.trainingDiary!.eddingtonActivities(){
                        for e in self.trainingDiary!.eddingtonEquipment(forActivityString: a){
                            for at in self.trainingDiary!.eddingtonActivityTypes(forActivityString: a){
                                
                                var units = Unit.activityUnits
                                
                                if (a == ConstantString.EddingtonAll.rawValue && at == ConstantString.EddingtonAll.rawValue && e == ConstantString.EddingtonAll.rawValue){
                                    units = Unit.allUnits
                                }else if (at == ConstantString.EddingtonAll.rawValue && e == ConstantString.EddingtonAll.rawValue){
                                    //metrics only calculated on the activity for ALL types and ALL Equipment
                                    units.append(contentsOf: Unit.metrics)
                                }
                                
                                // lets check if worth doing any calcs
                                let workoutCount = localWorkoutCopy.filter({ (w: Workout) -> Bool in
                                    let aCorrect    = a == "All" || w.activityString == a
                                    let atCorrect   = at == "All" || w.activityTypeString == at
                                    let eCorrect    = e == "All" || w.equipmentName == e
                                    return aCorrect && atCorrect && eCorrect}).count
                                
                                if workoutCount <= Int(Constant.WorkoutThresholdForEdNumberCount.rawValue){
                                    print("Only \(workoutCount) workouts for \(dt):\(a):\(e):\(at) so not bothering to calculate eddington numbers")
                                }else{
                                    for u in units.sorted(by: {$0.rawValue < $1.rawValue}){
                                        for p in periods{
                                            count += 1
                                            name = dt
                                            name += ":" + a
                                            name += ":" + e
                                            name += ":" + at
                                            name += ":" + p.rawValue
                                            name += ":" + u.rawValue
                                            autoreleasepool{ // added for memory management
                                                print(name)
                                                let result = calculator.quickCaclulation(forDayType: dt, forActivity: a, andType: at, equipment: e, andPeriod: p, andUnit: u, inTrainingDiary: self.trainingDiary!)
                                                
                                                DispatchQueue.main.sync {
                                                    let time = Date().timeIntervalSince(start)
                                                    let stillToCalculate = total - count
                                                    let estimatedRemaining = Double(stillToCalculate) * time / Double(count)
                                                    let remaining = timeRemainingFormatter.string(from: estimatedRemaining) ?? ""
                                                    let taken = timeTakenFormatter.string(from: time) ?? ""
                                                    print("\(remaining) of EDNUM LTD CALC: \(count) of \(total) : \(name) (\(taken)s...")
                                                    self.mainViewController!.mainStatusField!.stringValue = "\(remaining) of EDNUM LTD CALC: \(count) of \(total) : \(name) (\(taken))..."
                                                    self.mainViewController!.mainProgressBar!.doubleValue = 100.0 * Double(count) / Double(total)
                                                    if result.ednum > 0{
                                                        self.trainingDiary!.addLTDEddingtonNumber(forDayType: dt, forActivity: a, type: at, equipment: e, period: p, unit: u, value: result.ednum, plusOne: result.plusOne, maturity: result.maturity)
                                                    }
                                                }// end DispatchQueue.main
                                            }// end autoreleasepool
                                        }// end Period loop
                                    }// end unit loop
                                }//end else on workout count chedk
                            }// end type loop
                        }// end equipment loop
                    }// end activity loop
                }// end of dayType count check
            }// end of dayType loop
            
            DispatchQueue.main.async {
                let timeTaken = timeTakenFormatter.string(from: Date().timeIntervalSince(start)) ?? ""
                self.mainViewController!.mainStatusField.stringValue = "EDDINGTON LTD CALCULATION OF ALL: ALL LTD complete in \(timeTaken)"
                self.mainViewController!.mainProgressBar!.doubleValue = 100.0
            }
        }// end DispatchGlobal
    }
    
    private func selectedEddingtonNumbers() -> Set<LTDEddingtonNumber>{
        var edNums = Set<LTDEddingtonNumber>()
        for s in treeController!.selectedObjects{
            if let node = s as? LTDEddingtonNumber{
                for e in node.getLeaves(){
                    edNums.insert(e)
                }
            }
        }
        return edNums
    }
    
}
