//
//  PlanningSplitViewController.swift
//  Training Diary
//
//  Created by Steven Lord on 21/04/2018.
//  Copyright © 2018 Steven Lord. All rights reserved.
//

import Cocoa

class PlanningSplitViewController: TrainingDiarySplitViewController{


    @IBOutlet var plansArrayController: PlansArrayController!
    @IBOutlet var basicWeekArrayController: NSArrayController!
    @IBOutlet var planDaysArrayController: NSArrayController!
    
    private var basicWeekDays: [BasicWeekDay] = []
    
    @IBAction func exportSelectionAsJSON(_ sender: Any) {
        if let selectedPlan = selectedPlan(){
            if let url = OpenAndSaveDialogues().saveFilePath(suggestedFileName: "Plan", allowFileTypes: ["json"]){
                if let jsonString = JSONExporter().createJSON(forPlan: selectedPlan){
                    do{
                        try jsonString.write(to: url, atomically: true, encoding: String.Encoding.utf8.rawValue)
                    }catch{
                        print("Unable to save JSON")
                        print(error)
                    }
                }
            }
        }
    }
    
    @IBAction func exportSelectionAsCSV(_ sender: Any) {
        if let selectedPlan = selectedPlan(){
            if let directoryURL = OpenAndSaveDialogues().chooseFolderForSave(createSubFolder: "Data-\(Date().dateOnlyString())"){
                
                let csv = CSVExporter().convertToCSV(trainingDiary!,[], [], [], [selectedPlan])
                var saveFileName = directoryURL.appendingPathComponent("plans.csv")
                do{
                    try csv.plans.write(to: saveFileName, atomically: false, encoding: .utf8)
                }catch let error as NSError{
                    print(error)
                }
                saveFileName = directoryURL.appendingPathComponent("basicWeek.csv")
                do{
                    try csv.basicWeek.write(to: saveFileName, atomically: false, encoding: .utf8)
                }catch let error as NSError{
                    print(error)
                }
                saveFileName = directoryURL.appendingPathComponent("planDays.csv")
                do{
                    try csv.planDays.write(to: saveFileName, atomically: false, encoding: .utf8)
                }catch let error as NSError{
                    print(error)
                }
            }
        }
    }
    
    override func viewDidLoad(){
        super.viewDidLoad()
        if let bwac = basicWeekArrayController{
            bwac.sortDescriptors = [NSSortDescriptor.init(key: BasicWeekDayProperty.order.rawValue, ascending: true, selector: nil)]
        }
        if let pdac = planDaysArrayController{
            pdac.sortDescriptors = [NSSortDescriptor.init(key: PlanDayProperty.date.rawValue, ascending: true, selector: nil)]
        }

        setGraphDataCache()
        addBasicWeekDayObservers()

    }
    
    func setStartingTSBValuesFromTrainingDiary(){
        if let td = trainingDiary{
            if let p = selectedPlan(){
                if let d = td.getDay(forDate: p.from!.addDays(numberOfDays: -1)){
                    p.bikeStartATL = d.bikeATL
                    p.bikeStartCTL = d.bikeCTL
                    p.runStartATL = d.runATL
                    p.runStartCTL = d.runCTL
                    p.swimStartATL = d.swimATL
                    p.swimStartCTL = d.swimCTL
                }else{
                    let d = td.latestDay()!
                    let daysPostDiary = Int(p.from!.timeIntervalSince(td.lastDayOfDiary)/Constant.SecondsPerDay.rawValue)
                    if let swim = td.activity(forString: FixedActivity.Swim.rawValue){
                        p.swimStartCTL = d.swimCTL * swim.ctlDecayFactor(afterNDays: daysPostDiary)
                        p.swimStartATL = d.swimATL * swim.atlDecayFactor(afterNDays: daysPostDiary)
                    }
                    if let bike = td.activity(forString: FixedActivity.Bike.rawValue){
                        p.bikeStartCTL = d.bikeCTL * bike.ctlDecayFactor(afterNDays: daysPostDiary)
                        p.bikeStartATL = d.bikeATL * bike.atlDecayFactor(afterNDays: daysPostDiary)
                    }
                    if let run = td.activity(forString: FixedActivity.Run.rawValue){
                        p.runStartCTL = d.runCTL * run.ctlDecayFactor(afterNDays: daysPostDiary)
                        p.runStartATL = d.runATL * run.atlDecayFactor(afterNDays: daysPostDiary)
                    }
                }
            }
        }

    }
    
    func copyStartingTSBValuesToFirstPlanDay(){
        if let p = selectedPlan(){
            let opd = p.orderedPlanDays()
            if opd.count > 0{
                let firstPlanDay = opd[0]
                firstPlanDay.bikeATL = p.bikeStartATL
                firstPlanDay.bikeCTL = p.bikeStartCTL
                firstPlanDay.runATL = p.runStartATL
                firstPlanDay.runCTL = p.runStartCTL
                firstPlanDay.swimATL = p.swimStartATL
                firstPlanDay.swimCTL = p.swimStartCTL
                
                firstPlanDay.actualBikeATL = p.bikeStartATL
                firstPlanDay.actualBikeCTL = p.bikeStartCTL
                firstPlanDay.actualRunATL = p.runStartATL
                firstPlanDay.actualRunCTL = p.runStartCTL
                firstPlanDay.actualSwimATL = p.swimStartATL
                firstPlanDay.actualSwimCTL = p.swimStartCTL
                
                firstPlanDay.actualThenPlanBikeATL = p.bikeStartATL
                firstPlanDay.actualThenPlanBikeCTL = p.bikeStartCTL
                firstPlanDay.actualThenPlanRunATL = p.runStartATL
                firstPlanDay.actualThenPlanRunCTL = p.runStartCTL
                firstPlanDay.actualThenPlanSwimATL = p.swimStartATL
                firstPlanDay.actualThenPlanSwimCTL = p.swimStartCTL
            }
        }
    }
    
    func updateActuals(){
        if let td = trainingDiary{
            if let p = selectedPlan(){
                let dd = td.getDaysDictionary(fromDate: p.from!)
                for pDay in p.orderedPlanDays(){
                    if let d = dd[pDay.date!.dateOnlyShorterString()]{
                        pDay.actualSwimTSS = d.swimTSS
                        pDay.actualBikeTSS = d.bikeTSS
                        pDay.actualRunTSS = d.runTSS
                    }
                }
            }
        }
    }
    
    func createPlan(){
        if let p = selectedPlan(){
            p.createPlan()
        }
        setGraphDataCache()
    }
    
    func recalculatePlan(){
        if let p = selectedPlan(){
            p.calcTSB()
        }
        setGraphDataCache()
    }
 
    func planSelectionChanged(){
        setGraphDataCache()
        addBasicWeekDayObservers()
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if let bwvc = getBasicWeekViewController(){
            if let p = keyPath{
                switch p{
                case BasicWeekDayProperty.swimTSS.rawValue:
                    bwvc.swim.needsDisplay = true
                    bwvc.total.needsDisplay = true
                case BasicWeekDayProperty.bikeTSS.rawValue:
                    bwvc.bike.needsDisplay = true
                    bwvc.total.needsDisplay = true
                case BasicWeekDayProperty.runTSS.rawValue:
                    bwvc.run.needsDisplay = true
                    bwvc.total.needsDisplay = true
                default:
                    print("Not sure why PlanningSplitViewController is oberving \(p)")
                }
            }
        }
    }
    
    private func updateEndCTLs(){
        if let p = selectedPlan(){
            let days = p.orderedPlanDays()
            if days.count > 0{
                let lastDay = days[days.count - 1]
                if let vc = getPlanOutputViewController(){
                    
                    vc.swimTextField.doubleValue = lastDay.swimCTL
                    vc.bikeTextField.doubleValue = lastDay.bikeCTL
                    vc.runTextField.doubleValue = lastDay.runCTL
                    vc.allTextField.doubleValue = lastDay.allCTL
                    
                    vc.swimPredictedTextField.doubleValue = lastDay.actualThenPlanSwimCTL
                    vc.bikePredictedTextField.doubleValue = lastDay.actualThenPlanBikeCTL
                    vc.runPredictedTextField.doubleValue = lastDay.actualThenPlanRunCTL
                    vc.allPredictedTextField.doubleValue = lastDay.actualThenPlanAllCTL
                }
            }
        }
        
    }
    
    private func setGraphDataCache(){
        if let vc = getGraphViewController(){
            vc.setCache(planDays: selectedPlanDaysOrdered())
        }
        updateEndCTLs()
    }
    
    private func selectedPlan() -> Plan?{
        if let selectedPlans = plansArrayController?.selectedObjects as? [Plan]{
            if selectedPlans.count == 1{
                return selectedPlans[0]
            }
        }
        return nil
    }
    
    private func selectedPlanDaysOrdered() -> [PlanDay]{
        if let plan = selectedPlan() {
            if let pDays =  plan.planDays?.allObjects as? [PlanDay]{
                return pDays.sorted(by:{$0.date! < $1.date!})
            }
        }
        return []
    }
    
    private func getGraphViewController() -> PlanGraphViewController?{
        for v in childViewControllers{
            if let gvc = v as? PlanGraphViewController{
                return gvc
            }
            for gcvc in v.childViewControllers{
                if let gvc = gcvc as? PlanGraphViewController{
                    return gvc
                }
            }
        }
        return nil
    }

    private func getPlanOutputViewController() -> PlanOutputViewController?{
        for v in childViewControllers{
            if let gvc = v as? PlanOutputViewController{
                return gvc
            }
            for gcvc in v.childViewControllers{
                if let gvc = gcvc as? PlanOutputViewController{
                    return gvc
                }
            }
        }
        return nil
    }

    private func getBasicWeekViewController() -> PlanBasicWeekViewController?{
        for v in childViewControllers{
            if let gvc = v as? PlanBasicWeekViewController{
                return gvc
            }
            for gcvc in v.childViewControllers{
                if let gvc = gcvc as? PlanBasicWeekViewController{
                    return gvc
                }
            }
        }
        return nil
    }
    
    private func addBasicWeekDayObservers(){
        
        for b in basicWeekDays{
            for p in BasicWeekDayProperty.observables{
                b.removeObserver(self, forKeyPath: p.rawValue)
            }
        }
        
        if let bwd = selectedPlan()?.basicWeek?.allObjects as? [BasicWeekDay]{
            basicWeekDays = bwd
            for b in basicWeekDays{
                for p in BasicWeekDayProperty.observables{
                    b.addObserver(self, forKeyPath: p.rawValue, options: .new, context: nil)
                }
            }
        }
    }
    

}
