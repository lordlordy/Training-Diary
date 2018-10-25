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
        
    @IBAction func exportSelectionAsJSON(_ sender: Any) {
        let selection = selectedPlansOrderedChronological()
        if selection.count == 1{
            let selectedPlan = selection[0]
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
        let selection = selectedPlansOrderedChronological()
        if selection.count == 1{
            let selectedPlan = selection[0]
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

    @IBAction func exportSelectionAsHTML(_ sender: Any) {
        let selection = selectedPlansOrderedChronological()
        if selection.count == 1{
            let selectedPlan = selection[0]
                
            var tables:  [(objects: [NSObject], properties: [TrainingDiaryPropertyProtocol], paragraph: String?)] = []
            
            tables.append(([selectedPlan], PlanProperty.csvProperties,"PLAN: \(selectedPlan.name ?? "")"))
            tables.append((selectedPlan.orderedBasicWeek(), BasicWeekDayProperty.csvProperties,"BASIC WEEK"))
            tables.append((selectedPlan.orderedPlanDays(), PlanDayProperty.csvProperties,"PLAN DAYS"))
            
            
            let html = HTMLGenerator().createStandardTablesHTML(tables)
            if let url = OpenAndSaveDialogues().saveFilePath(suggestedFileName: "Plan-\(selectedPlan.name ?? "")", allowFileTypes: ["html"]){
                do{
                    try html.write(to: url, atomically: true, encoding: .utf8)
                }catch{
                    print("Unable to save JSON")
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

    }
    
    func basicWeekDays() -> [BasicWeekDay]{
        return basicWeekArrayController.arrangedObjects as? [BasicWeekDay] ?? []
    }
    
    
    func updateActuals(){
        if let td = trainingDiary{
            for p in selectedPlansOrderedChronological(){
                p.updateFirstDay()
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
        let plans = selectedPlansOrderedChronological()
        if plans.count == 1{
            plans[0].createPlan()
        }
        setGraphDataCache()
    }
    
    func recalculatePlan(){
        for p in selectedPlansOrderedChronological(){
            p.calcTSB()
        }
        setGraphDataCache()
    }
 
    func planSelectionChanged(){
        setGraphDataCache()
    }
    

    //MARK: - Private
    
    private func updateEndCTLs(){
        let days = selectedPlanDaysOrdered()
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
    
    private func setGraphDataCache(){
        if let vc = getGraphViewController(){
            vc.setCache(planDays: selectedPlanDaysOrdered())
        }
        updateEndCTLs()
    }
    
    private func selectedPlansOrderedChronological() -> [Plan]{
        return plansArrayController?.selectedObjects as? [Plan] ?? []
    }
    
    private func selectedPlanDaysOrdered() -> [PlanDay]{
        var planDays: [PlanDay] = []
        for p in selectedPlansOrderedChronological(){
            planDays.append(contentsOf: p.orderedPlanDays())
        }
        return planDays.sorted(by:{$0.date! < $1.date!})
    }
    
    private func getGraphViewController() -> PlanGraphViewController?{
        for v in children{
            if let gvc = v as? PlanGraphViewController{
                return gvc
            }
            for gcvc in v.children{
                if let gvc = gcvc as? PlanGraphViewController{
                    return gvc
                }
            }
        }
        return nil
    }

    private func getPlanOutputViewController() -> PlanOutputViewController?{
        for v in children{
            if let gvc = v as? PlanOutputViewController{
                return gvc
            }
            for gcvc in v.children{
                if let gvc = gcvc as? PlanOutputViewController{
                    return gvc
                }
            }
        }
        return nil
    }

    private func getBasicWeekViewController() -> PlanBasicWeekViewController?{
        for v in children{
            if let gvc = v as? PlanBasicWeekViewController{
                return gvc
            }
            for gcvc in v.children{
                if let gvc = gcvc as? PlanBasicWeekViewController{
                    return gvc
                }
            }
        }
        return nil
    }


}
