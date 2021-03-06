//
//  ViewController.swift
//  Training Diary
//
//  Created by Steven Lord on 07/10/2017.
//  Copyright © 2017 Steven Lord. All rights reserved.
//

import Cocoa

class ViewController: NSViewController, NSTableViewDelegate, NSTextFieldDelegate {

    //this has to be a variable (ie can't be derived) to be Key Value compliant for Core Data
    @objc dynamic var managedObjectContext: NSManagedObjectContext
        
    private var trainingDiaryVCs: [TrainingDiaryViewControllerProtocol] = []
    var currentSelectedDiary: TrainingDiary?

    //MARK: - @IBOutlets
    
    @IBOutlet var trainingDiaryAC: TrainingDiaryArrayController!
    @IBOutlet var trainingDiarysArrayController: NSArrayController!
    @IBOutlet weak var mainStatusField: NSTextField!
    @IBOutlet weak var mainProgressBar: NSProgressIndicator!
    
    @IBOutlet weak var periodCB: PeriodComboBox!
    @IBOutlet weak var totalUnitCB: UnitComboBox!
    @IBOutlet weak var swimUnitCB: UnitComboBox!
    @IBOutlet weak var bikeUnitCB: UnitComboBox!
    @IBOutlet weak var runUnitCB: UnitComboBox!
    @IBOutlet weak var gymUnitCB: UnitComboBox!
    
    @IBOutlet weak var comparisonYear: NSTextField!
    @IBOutlet weak var comparisonTotal: NSTextField!
    @IBOutlet weak var currentTotal: NSTextField!
    @IBOutlet weak var comparisonSwim: NSTextField!
    @IBOutlet weak var currentSwim: NSTextField!
    @IBOutlet weak var comparisonBike: NSTextField!
    @IBOutlet weak var currentBike: NSTextField!
    @IBOutlet weak var comparisonRun: NSTextField!
    @IBOutlet weak var currentRun: NSTextField!
    @IBOutlet weak var comparisonGym: NSTextField!
    @IBOutlet weak var currentGym: NSTextField!
    
    @IBAction func comparisonYearChanged(_ sender: NSTextField) { updateAll() }
    @IBAction func periodCBChanged(_ sender: PeriodComboBox)    { updateAll()  }
    @IBAction func totalUnitCBChanged(_ sender: UnitComboBox)   { updateTotal() }
    @IBAction func swimUnitCBChanged(_ sender: UnitComboBox)    { updateSwim() }
    @IBAction func bikeUnitCBChanged(_ sender: UnitComboBox)    { updateBike() }
    @IBAction func runUnitCBChanged(_ sender: UnitComboBox)     { updateRun() }
    @IBAction func gymUnitCBChanged(_ sender: UnitComboBox)     { updateGym() }
    
    
    @IBAction func addNewTrainingDiary(_ sender: Any) {
        if let tdac = trainingDiaryAC{
            tdac.add(sender)
        }
    }
        
    //MARK: - Initialisers
    
    required init?(coder: NSCoder) {
        
        self.managedObjectContext = CoreDataStackSingleton.shared.trainingDiaryPC.viewContext
        super.init(coder: coder)
        
        ValueTransformer.setValueTransformer(TransformerNSNumberToTimeFormat(), forName: NSValueTransformerName(rawValue: "TransformerNSNumberToTimeFormat"))
        ValueTransformer.setValueTransformer(NumberToDetailedTimeTransformer(), forName: NSValueTransformerName(rawValue: "NumberToDetailedTimeTransformer"))
        ValueTransformer.setValueTransformer(NumberToSummaryTimeFormatter(), forName: NSValueTransformerName(rawValue: "NumberToSummaryTimeFormatter"))
        ValueTransformer.setValueTransformer(TextViewToStringTransformer(), forName: NSValueTransformerName(rawValue: "TextViewToStringTransformer"))
        ValueTransformer.setValueTransformer(ActivityToStringTransformer(), forName: NSValueTransformerName(rawValue: "ActivityToStringTransformer"))
        ValueTransformer.setValueTransformer(ActivityTypeToStringTransformer(), forName: NSValueTransformerName(rawValue: "ActivityTypeToStringTransformer"))
        ValueTransformer.setValueTransformer(AgeFormatter(), forName: NSValueTransformerName(rawValue: "AgeFormatter"))
    

        
    }

    
    //MARK: - override of prepare method
    //this method is called when GUI loads. We use it to get references to underlying view controllers
    override func prepare(for segue: NSStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        guard let tabViewController = segue.destinationController as? NSTabViewController else {return}
        
        for controller in tabViewController.children{
            if let c = controller as? TrainingDiaryViewControllerProtocol{
                print("adding \(c)")
                trainingDiaryVCs.append(c)
            }

            checkToSetMainViewController(controller)
        }
        
    }
    
    private func checkToSetMainViewController(_ vc: NSViewController){
        if let controller = vc as? ReferenceToMainProtocol{
            print("Setting main view controller for \(controller)")
            controller.setMainViewControllerReference(to: self)
        }
        for c in vc.children{
            checkToSetMainViewController(c)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        periodCB.stringValue = Period.YearToDate.rawValue
        totalUnitCB.stringValue = Unit.hours.rawValue
        swimUnitCB.stringValue = Unit.km.rawValue
        bikeUnitCB.stringValue = Unit.km.rawValue
        runUnitCB.stringValue = Unit.km.rawValue
        gymUnitCB.stringValue = Unit.reps.rawValue
        if let currentYear = getSelectedTrainingDiary()?.lastDayOfDiary.year(){
            comparisonYear.stringValue = String(currentYear - 1)
        }else{
            comparisonYear.stringValue = "2018"
        }
    }

    

    
    @IBAction func newDiary(_ sender: Any){
        trainingDiarysArrayController.add(sender)
    }
    
    @IBAction func removeDiary(_ sender: Any){
        trainingDiarysArrayController.remove(sender)
    }
    
    func tableViewSelectionDidChange(_ notification: Notification) {
        if let trainingDiary = trainingDiarysArrayController.selectedObjects[0] as? TrainingDiary{
            
            if trainingDiary == currentSelectedDiary{
                return // do nothing as selection not changed
            }
            currentSelectedDiary = trainingDiary
            
            for c in trainingDiaryVCs{
                c.set(trainingDiary: trainingDiary)
            }
            
            
            updateAll()
        }
    }
 
    //MARK: - @IBActions



    // MARK: -  JSON Support
    
    @IBAction func loadFromFile(_ sender: Any) {
        if let url = OpenAndSaveDialogues().selectedPath(withTitle: "chose .json or .csv file",andFileTypes: FileExtension.importTypes.map({$0.rawValue})) {

            if let fileExtension = FileExtension(rawValue: url.pathExtension){
                switch fileExtension{
                case FileExtension.json:
                    let jsonImporter = JSONImporter()
                    jsonImporter.importDiary(fromURL: url)
                case FileExtension.csv:
                    let csvImporter = CSVImporter()
                    csvImporter.importDiary(fromURL: url)
                case FileExtension.html:
                    print("Cannot import html")
                }
            }
        }
    }
    
    @IBAction func mergeFromFile(_ sender: NSMenuItem) {
        if let td = getSelectedTrainingDiary(){
            
            //this will bring up file choser for user to select file to merge and then
            //parse the file returning top level json dictionary
            //not this may return nil if user hits 'cancel' for instance
            if let url = OpenAndSaveDialogues().selectedPath(withTitle: "chose .json or .csv file",andFileTypes: FileExtension.importTypes.map({$0.rawValue})){
                if let fileExtension = FileExtension(rawValue: url.pathExtension){
                    switch fileExtension{
                    case FileExtension.json:
                        let jsonImporter = JSONImporter()
                        jsonImporter.merge(fromURL: url, intoDiary: td)
                    case FileExtension.csv:
                        let csvImporter = CSVImporter()
                        csvImporter.merge(fromURL: url, intoDiary: td)
                    case FileExtension.html:
                        print("Cannot import html")
                    }
                }
            }
        }
    }

    @IBAction func exportHTML(_ sender: NSMenuItem){
        print("TBI exportHTML")
    }
    
    @IBAction func exportJSONForYear(_ sender: NSMenuItem){
        print("export json for year")
        let msg = NSAlert()
        msg.addButton(withTitle: "OK")
        msg.addButton(withTitle: "Cancel")
        msg.messageText = "Select a year"
        msg.informativeText = "Type a year (eg 2009)"
        
        let txt = NSTextField(frame:NSRect(x:0, y:0, width: 100, height: 24))
        let formatter = NumberFormatter()
        formatter.format = "0000"
        txt.formatter = formatter
        txt.intValue = Int32(Date().year())
        msg.accessoryView = txt
        
        let response: NSApplication.ModalResponse = msg.runModal()
        
        if response == NSApplication.ModalResponse.alertFirstButtonReturn{
            if let td = getSelectedTrainingDiary(){
                if let url = OpenAndSaveDialogues().saveFilePath(suggestedFileName: "TrainingDiary", allowFileTypes: ["json"]){
                    if let jsonString = JSONExporter().createJSON(forTrainingDiary: td, andYear: Int(txt.intValue)){
                        do{
                            try jsonString.write(to: url, atomically: true, encoding: String.Encoding.utf8.rawValue)
                        }catch{
                            print("Unable to save JSON")
                            print(error)
                        }
                    }
                }                
            }
        }else{
            print("cancelled")
        }
        
    }
    
    @IBAction func exportJSON(_ sender: NSMenuItem){
        if let td = getSelectedTrainingDiary(){
            
            if let url = OpenAndSaveDialogues().saveFilePath(suggestedFileName: "TrainingDiary", allowFileTypes: ["json"]){
                if let jsonString = JSONExporter().createJSON(forTrainingDiary: td){
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
    
    //MARK: - CSV Support

    @IBAction func exportCSVForYear(_ sender: NSMenuItem){
        print("export csv for year")
        let msg = NSAlert()
        msg.addButton(withTitle: "OK")
        msg.addButton(withTitle: "Cancel")
        msg.messageText = "Select a year"
        msg.informativeText = "Type a year (eg 2009)"
        
        let txt = NSTextField(frame:NSRect(x:0, y:0, width: 100, height: 24))
        let formatter = NumberFormatter()
        formatter.format = "0000"
        txt.formatter = formatter
        txt.intValue = Int32(Date().year())
        msg.accessoryView = txt
        
        let response: NSApplication.ModalResponse = msg.runModal()
        
        if response == NSApplication.ModalResponse.alertFirstButtonReturn{
            if let td = getSelectedTrainingDiary(){
                let csv = CSVExporter().convertToCSV(trainingDiary: td, forYear: Int(txt.intValue))
                saveCSV(csv, subFolderName: txt.stringValue)
            }
        }else{
            print("cancelled")
        }
        
    }
    

    
    @IBAction func exportCSV(_ sender: NSMenuItem){
        let csvExporter = CSVExporter()
        
        if let td = getSelectedTrainingDiary(){
            let csv = csvExporter.convertToCSV(trainingDiary: td)
            
            saveCSV(csv, subFolderName: "Data-\(Date().dateOnlyString())")
        }
    }
    
    
    
    //MARK: - Private functions
    
    fileprivate func saveCSV(_ csv: CSVExporter.TrainingDiaryCVSStrings, subFolderName name: String) {
        if let saveFolder = OpenAndSaveDialogues().chooseFolderForSave(createSubFolder: name){
            var saveFileName = saveFolder.appendingPathComponent("workouts.csv")
            do{
                try csv.workouts.write(to: saveFileName, atomically: false, encoding: .utf8)
            }catch let error as NSError{
                print(error)
            }
            saveFileName = saveFolder.appendingPathComponent("days.csv")
            do{
                try csv.days.write(to: saveFileName, atomically: false, encoding: .utf8)
            }catch let error as NSError{
                print(error)
            }
            if csv.weights != ""{
                saveFileName = saveFolder.appendingPathComponent("weights.csv")
                do{
                    try csv.weights.write(to: saveFileName, atomically: false, encoding: .utf8)
                }catch let error as NSError{
                    print(error)
                }
            }
            if csv.physiologicals != ""{
                saveFileName = saveFolder.appendingPathComponent("physiologicals.csv")
                do{
                    try csv.physiologicals.write(to: saveFileName, atomically: false, encoding: .utf8)
                }catch let error as NSError{
                    print(error)
                }
            }
            if csv.plans != ""{
                saveFileName = saveFolder.appendingPathComponent("plans.csv")
                do{
                    try csv.plans.write(to: saveFileName, atomically: false, encoding: .utf8)
                }catch let error as NSError{
                    print(error)
                }
                saveFileName = saveFolder.appendingPathComponent("basicWeekDays.csv")
                do{
                    try csv.basicWeek.write(to: saveFileName, atomically: false, encoding: .utf8)
                }catch let error as NSError{
                    print(error)
                }
                saveFileName = saveFolder.appendingPathComponent("planDays.csv")
                do{
                    try csv.planDays.write(to: saveFileName, atomically: false, encoding: .utf8)
                }catch let error as NSError{
                    print(error)
                }
            }
        }
    }
    
    private func getSelectedTrainingDiary() -> TrainingDiary?{
        //array controller set to only allow single selection. So the array should always have only one item
        if trainingDiarysArrayController.selectedObjects.count > 0{
            let selectedObject = trainingDiarysArrayController.selectedObjects[0]
            return selectedObject as? TrainingDiary
        }
        return nil
    }
    
    private func selectedTrainingDiary() -> TrainingDiary?{
        if let tdac = trainingDiarysArrayController{
            if tdac.selectedObjects.count > 0{
                return tdac.selectedObjects[0] as? TrainingDiary
            }
        }
        return nil
    }
    
    //MARK: - Calculated propertiesCalculated
    private func updateAll(){
        updateTotal()
        updateSwim()
        updateBike()
        updateRun()
        updateGym()
    }
    
    private func updateTotal(){
        if let td = selectedTrainingDiary(){
            let values = td.valuesFor(dayType: ConstantString.EddingtonAll.rawValue, activity: ConstantString.EddingtonAll.rawValue, activityType: ConstantString.EddingtonAll.rawValue, equipment: ConstantString.EddingtonAll.rawValue, period: periodCB.selectedPeriod()!, aggregationMethod: totalUnitCB.selectedUnit()!.defaultAggregator(), unit: totalUnitCB.selectedUnit()!, from: td.lastDayOfDiary, to: td.lastDayOfDiary)
            if values.count > 0{
                currentTotal.stringValue = String(values[0].value)
            }else{
                currentTotal.stringValue = "12345.6789"
            }
            
            if let cDate = comparisonDate(){
                let values = td.valuesFor(dayType: ConstantString.EddingtonAll.rawValue, activity: ConstantString.EddingtonAll.rawValue, activityType: ConstantString.EddingtonAll.rawValue, equipment: ConstantString.EddingtonAll.rawValue, period: periodCB.selectedPeriod()!, aggregationMethod: totalUnitCB.selectedUnit()!.defaultAggregator(), unit: totalUnitCB.selectedUnit()!, from: cDate.startOfDay(), to: cDate.endOfDay())
                if values.count > 0{
                    comparisonTotal.stringValue = String(values[0].value)
                }else{
                    comparisonTotal.stringValue = "12345.6789"
                }
            }
            
        }
    }
    
    private func updateSwim(){
        if let td = selectedTrainingDiary(){
            let values = td.valuesFor(dayType: ConstantString.EddingtonAll.rawValue, activity: FixedActivity.Swim.rawValue, activityType: ConstantString.EddingtonAll.rawValue, equipment: ConstantString.EddingtonAll.rawValue, period: periodCB.selectedPeriod()!, aggregationMethod: swimUnitCB.selectedUnit()!.defaultAggregator(), unit: swimUnitCB.selectedUnit()!, from: td.lastDayOfDiary, to: td.lastDayOfDiary)
            if values.count > 0{
                currentSwim.stringValue = String(values[0].value)
            }else{
                currentSwim.stringValue = "12345.6789"
            }
            
            if let cDate = comparisonDate(){
                let values = td.valuesFor(dayType: ConstantString.EddingtonAll.rawValue, activity: FixedActivity.Swim.rawValue, activityType: ConstantString.EddingtonAll.rawValue, equipment: ConstantString.EddingtonAll.rawValue, period: periodCB.selectedPeriod()!, aggregationMethod: swimUnitCB.selectedUnit()!.defaultAggregator(), unit: swimUnitCB.selectedUnit()!, from: cDate.startOfDay(), to: cDate.endOfDay())
                if values.count > 0{
                    comparisonSwim.stringValue = String(values[0].value)
                }else{
                    comparisonSwim.stringValue = "12345.6789"
                }
            }
            
        }
    }

    private func updateBike(){
        if let td = selectedTrainingDiary(){
            let values = td.valuesFor(dayType: ConstantString.EddingtonAll.rawValue, activity: FixedActivity.Bike.rawValue, activityType: ConstantString.EddingtonAll.rawValue, equipment: ConstantString.EddingtonAll.rawValue, period: periodCB.selectedPeriod()!, aggregationMethod: bikeUnitCB.selectedUnit()!.defaultAggregator(), unit: bikeUnitCB.selectedUnit()!, from: td.lastDayOfDiary, to: td.lastDayOfDiary)
            if values.count > 0{
                currentBike.stringValue = String(values[0].value)
            }else{
                currentBike.stringValue = "12345.6789"
            }
            
            if let cDate = comparisonDate(){
                let values = td.valuesFor(dayType: ConstantString.EddingtonAll.rawValue, activity: FixedActivity.Bike.rawValue, activityType: ConstantString.EddingtonAll.rawValue, equipment: ConstantString.EddingtonAll.rawValue, period: periodCB.selectedPeriod()!, aggregationMethod: bikeUnitCB.selectedUnit()!.defaultAggregator(), unit: bikeUnitCB.selectedUnit()!, from: cDate.startOfDay(), to: cDate.endOfDay())
                if values.count > 0{
                    comparisonBike.stringValue = String(values[0].value)
                }else{
                    comparisonBike.stringValue = "12345.6789"
                }
            }
            
        }
    }
 
    private func updateRun(){
        if let td = selectedTrainingDiary(){
            let values = td.valuesFor(dayType: ConstantString.EddingtonAll.rawValue, activity: FixedActivity.Run.rawValue, activityType: ConstantString.EddingtonAll.rawValue, equipment: ConstantString.EddingtonAll.rawValue, period: periodCB.selectedPeriod()!, aggregationMethod: runUnitCB.selectedUnit()!.defaultAggregator(), unit: runUnitCB.selectedUnit()!, from: td.lastDayOfDiary, to: td.lastDayOfDiary)
            if values.count > 0{
                currentRun.stringValue = String(values[0].value)
            }else{
                currentRun.stringValue = "12345.6789"
            }
            
            if let cDate = comparisonDate(){
                let values = td.valuesFor(dayType: ConstantString.EddingtonAll.rawValue, activity: FixedActivity.Run.rawValue, activityType: ConstantString.EddingtonAll.rawValue, equipment: ConstantString.EddingtonAll.rawValue, period: periodCB.selectedPeriod()!, aggregationMethod: runUnitCB.selectedUnit()!.defaultAggregator(), unit: runUnitCB.selectedUnit()!, from: cDate.startOfDay(), to: cDate.endOfDay())
                if values.count > 0{
                    comparisonRun.stringValue = String(values[0].value)
                }else{
                    comparisonRun.stringValue = "12345.6789"
                }
            }
            
        }
    }
    
    private func updateGym(){
        if let td = selectedTrainingDiary(){
            let values = td.valuesFor(dayType: ConstantString.EddingtonAll.rawValue, activity: FixedActivity.Gym.rawValue, activityType: ConstantString.EddingtonAll.rawValue, equipment: ConstantString.EddingtonAll.rawValue, period: periodCB.selectedPeriod()!, aggregationMethod: gymUnitCB.selectedUnit()!.defaultAggregator(), unit: gymUnitCB.selectedUnit()!, from: td.lastDayOfDiary, to: td.lastDayOfDiary)
            if values.count > 0{
                currentGym.stringValue = String(values[0].value)
            }else{
                currentGym.stringValue = "12345.6789"
            }
            
            if let cDate = comparisonDate(){
                let values = td.valuesFor(dayType: ConstantString.EddingtonAll.rawValue, activity: FixedActivity.Gym.rawValue, activityType: ConstantString.EddingtonAll.rawValue, equipment: ConstantString.EddingtonAll.rawValue, period: periodCB.selectedPeriod()!, aggregationMethod: gymUnitCB.selectedUnit()!.defaultAggregator(), unit: gymUnitCB.selectedUnit()!, from: cDate.startOfDay(), to: cDate.endOfDay())
                if values.count > 0{
                    comparisonGym.stringValue = String(values[0].value)
                }else{
                    comparisonGym.stringValue = "12345.6789"
                }
            }
            
        }
    }
    
    private func comparisonDate() -> Date?{
        if let cYear = Int(comparisonYear.stringValue){
            if let td = getSelectedTrainingDiary(){
                var calendar = Calendar(identifier: Calendar.Identifier.gregorian)
                calendar.timeZone = TimeZone(secondsFromGMT: 0)!
                var dc = calendar.dateComponents([.day,.month], from: td.lastDayOfDiary)
                dc.year = cYear
                return calendar.date(from: dc)
            }
        }
        return nil
    }

}

