//
//  WeightHRVTablesViewController.swift
//  Training Diary
//
//  Created by Steven Lord on 25/04/2018.
//  Copyright © 2018 Steven Lord. All rights reserved.
//

import Cocoa

class WeightHRVTablesViewController: TrainingDiaryViewController{
    
    @objc dynamic var rollingDays: Int = 7{
        didSet{
            if let gvc = graphViewController{
                gvc.rollingDays = rollingDays
                datePickerChanged() // this will prompt redrawing graphs with new rolling data
            }
        }
    }
    
    @IBOutlet weak var fromDatePicker: NSDatePicker!
    @IBOutlet weak var toDatePicker: NSDatePicker!
    @IBOutlet var weightArrayController: WeightsArrayController!
    @IBOutlet var hrArrayController: PhysiologicalsArrayController!
    
    private var advanceDateComponent: DateComponents?
    private var retreatDateComponent: DateComponents?
    
    var graphViewController: WeightHRVGraphViewController?{
        if let p = parent as? WeightHRVSplitViewController{
            return p.graphViewController
        }
        return nil
    }
    

    @IBAction func exportSelectionAsJSON(_ sender: Any) {
        let weights: [Weight] = weightArrayController.selectedObjects as? [Weight] ?? []
        let physios: [Physiological] = hrArrayController.selectedObjects as? [Physiological] ?? []
        
        if let url = OpenAndSaveDialogues().saveFilePath(suggestedFileName: "WeightsAndPhysiologicals", allowFileTypes: ["json"]){
            
            if let jsonString = JSONExporter().createJSON(forTrainingDiary: trainingDiary!,  forDays: [], forPhysiologicals: physios, forWeights: weights, forPlans: []){
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
        if let directoryURL = OpenAndSaveDialogues().chooseFolderForSave(createSubFolder: "Data-\(Date().dateOnlyString())"){
           
            let weights: [Weight] = weightArrayController.selectedObjects as? [Weight] ?? []
            let physios: [Physiological] = hrArrayController.selectedObjects as? [Physiological] ?? []
            
            let csv = CSVExporter().convertToCSV(trainingDiary!, [], weights, physios, [])
            var saveFileName = directoryURL.appendingPathComponent("weights.csv")
            do{
                try csv.weights.write(to: saveFileName, atomically: false, encoding: .utf8)
            }catch let error as NSError{
                print(error)
            }
            saveFileName = directoryURL.appendingPathComponent("physiologicals.csv")
            do{
                try csv.physiologicals.write(to: saveFileName, atomically: false, encoding: .utf8)
            }catch let error as NSError{
                print(error)
            }
        }
    }
    
    @IBAction func fromDatePickerChanged(_ sender: Any) { datePickerChanged() }
    @IBAction func toDatePickerChanged(_ sender: Any) { datePickerChanged() }
    
    @IBAction func periodChanged(_ sender: PeriodTextField) {
        advanceDateComponent = sender.getDateComponentsEquivalent()
        retreatDateComponent = sender.getNegativeDateComponentsEquivalent()
        if let to = toDatePicker?.dateValue{
            if let dc = retreatDateComponent{
                if let from = Calendar.current.date(byAdding: dc, to: to){
                    if let fdp = fromDatePicker{
                        fdp.dateValue = from
                        updateForChange(fromDate: from, toDate: to)
                    }
                }
            }
        }
    }
    
    @IBAction func retreatAPeriod(_ sender: Any) {
        if let retreat = retreatDateComponent{
            advanceDates(byDateComponents: retreat)
        }
    }
    
    @IBAction func advanceAPeriod(_ sender: Any) {
        if let advance = advanceDateComponent{
            advanceDates(byDateComponents: advance)
        }
    }
    
    @IBAction func graphComboBoxChanged(_ sender: NSComboBox) {
        if let gvc = graphViewController{
            gvc.setGraphs(forKey: sender.stringValue )
            
        }
    }
    
    override func viewDidLoad(){
        super.viewDidLoad()
        newTrainingDiarySet()
    }
    
    override func set(trainingDiary td: TrainingDiary){
        super.set(trainingDiary: td)
        newTrainingDiarySet()
    }
    
    //MARK: - PRIVATE
    private func newTrainingDiarySet(){
        if let td = trainingDiary{
            let to = td.lastDayOfDiary
            setPickerDates(fromDate: to.addDays(numberOfDays: -31), toDate: to)
        }
    }
    
    private func setPickerDates(fromDate from: Date, toDate to: Date){
        if let tdp = toDatePicker{
            tdp.dateValue = to
        }
        if let fdp = fromDatePicker{
            fdp.dateValue = from
        }
        updateForChange(fromDate: from, toDate: to)
    }
    
    private func datePickerChanged(){
        if let from = fromDatePicker?.dateValue{
            if let to = toDatePicker?.dateValue{
                updateForChange(fromDate: from, toDate: to)
            }
        }
    }
    
    private func advanceDates(byDateComponents dc: DateComponents){
        if let fdp = fromDatePicker{
            if let tdp = toDatePicker{
                if let from = Calendar.current.date(byAdding: dc, to: fdp.dateValue){
                    if let to = Calendar.current.date(byAdding: dc, to: tdp.dateValue){
                        fdp.dateValue = from
                        tdp.dateValue = to
                        updateForChange(fromDate: from, toDate: to)
                    }
                }
            }
        }
    }
    
    
    private func updateForChange(fromDate from: Date, toDate to: Date){

        if let gvc = graphViewController{
            gvc.setGraphDate(fromDate: from, toDate: to)
        }
        let predicate = NSPredicate(format: "fromDate >= %@ AND fromDate <= %@", argumentArray: [from.startOfDay(),to.endOfDay()])
        if let wac = weightArrayController{
            wac.filterPredicate = predicate
        }
        if let hac = hrArrayController{
            hac.filterPredicate = predicate
        }
        if let gvc = graphViewController{
            gvc.setGraphDate(fromDate: from, toDate: to)
        }
    }
    
    
}
