//
//  DaysInputViewController.swift
//  Training Diary
//
//  Created by Steven Lord on 04/03/2018.
//  Copyright © 2018 Steven Lord. All rights reserved.
//

import Cocoa

class DaysInputViewController: TrainingDiaryViewController {

    
    @IBOutlet weak var daysTableView: TableViewWithColumnSort!
    
    @objc dynamic var arrayController: NSArrayController?{
        print("Parent is \(parent)")
        if let p = parent{
            print("my parents parent is \(p.parent)")
        }
        if let dsvc = parent?.parent as? DaysSplitViewController{
            print("returning daysArrayController from my grandparent")
            return dsvc.daysArrayController
        }
        return nil
    }
    
    @objc dynamic var grandParent: DaysSplitViewController?{
        if let grandParent = parent?.parent as? DaysSplitViewController{
            return grandParent
        }
        return nil
    }
    
    @IBAction func add(_ sender: Any) {
        if let parentVC = parent?.parent as? DaysSplitViewController{
            if let dac = parentVC.daysArrayController{
                dac.add(sender)
            }
        }
    }
    
    @IBAction func remove(_ sender: Any) {
        if let parentVC = parent?.parent as? DaysSplitViewController{
            if let dac = parentVC.daysArrayController{
                dac.remove(sender)
            }
        }
    }
    
    @IBAction func reload(_ sender: Any) {
        if let dtv = daysTableView{
            dtv.reloadData()
        }
    }
    
    @IBAction func calcTSBForSelection(_ sender: Any) {
        if let pvc = parent?.parent as? DaysSplitViewController{
            if let selectedDay = pvc.daysArrayController.selectedObjects as? [Day]{
                if selectedDay.count > 0{
                    if let td = trainingDiary{
                        for a in td.activitiesArray(){
                            td.calcTSB(forActivity: a, fromDate: selectedDay[0].date!)
                            td.calculateMonotonyAndStrain(forActivity: a, fromDate: selectedDay[0].date!)
                        }
                        daysTableView!.reloadData()
                    }
                }
            }
        }
    }
    
    @IBAction func exportSelectionAsHTML(_ sender: Any) {
        print("Export selection as HTML not yet implemented")
    }
    
    @IBAction func exportSelectionAsCSV(_ sender: Any) {

        if let directoryURL = OpenAndSaveDialogues().chooseFolderForSave(createSubFolder: "Data-\(Date().dateOnlyString())"){
            let days = selectedDays()
            //only exporting dates here. Need to pass in a set of Weights and Physios so we can include Weight / HR for any days that have values
            let weightsAndPhysios = getWeightsAndPhysios(forDays: days)
            
            let csv = CSVExporter().convertToCSV(trainingDiary!, days, weightsAndPhysios.weights, weightsAndPhysios.physios, [])
            var saveFileName = directoryURL.appendingPathComponent("workouts.csv")
            do{
                try csv.workouts.write(to: saveFileName, atomically: false, encoding: .utf8)
            }catch let error as NSError{
                print(error)
            }
            saveFileName = directoryURL.appendingPathComponent("days.csv")
            do{
                try csv.days.write(to: saveFileName, atomically: false, encoding: .utf8)
            }catch let error as NSError{
                print(error)
            }
        }
        
    }
    
    @IBAction func exportSelectionAsJSON(_ sender: Any) {
        
        if let url = OpenAndSaveDialogues().saveFilePath(suggestedFileName: "Days", allowFileTypes: ["json"]){
            
            let days = selectedDays()
            let weightsAndPhysios = getWeightsAndPhysios(forDays: days)
            
            if let jsonString = JSONExporter().createJSON(forDays: days, forPhysiologicals: weightsAndPhysios.physios   , forWeights: weightsAndPhysios.weights, forPlans: []){
                do{
                    try jsonString.write(to: url, atomically: true, encoding: String.Encoding.utf8.rawValue)
                }catch{
                    print("Unable to save JSON")
                    print(error)
                }
            }
        }
        
    }
    
    
    private func selectedDays() -> [Day]{
        if let pvc = parent?.parent as? DaysSplitViewController{
            return pvc.daysArrayController.selectedObjects as? [Day] ?? []
        }
        return []
    }
    
    private func getWeightsAndPhysios(forDays days: [Day]) -> (weights: [Weight], physios: [Physiological]){
        if days.count > 0{
            let sortedDays = days.sorted(by: {$0.date! < $1.date!}) //sorted ascending
            let earliestDate = sortedDays[0].date!.startOfDay()
            let latestDate = sortedDays[days.count - 1].date!.endOfDay()
            let weights = (trainingDiary?.weights?.allObjects as? [Weight])?.filter({$0.fromDate! >= earliestDate && $0.fromDate! <= latestDate}) ?? []
            let physios = (trainingDiary?.physiologicals?.allObjects as? [Physiological])?.filter({$0.fromDate! >= earliestDate && $0.fromDate! <= latestDate}) ?? []
            return (weights, physios)
        }
        return ([],[])
    }
    
}
