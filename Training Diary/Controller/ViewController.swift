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
    private var currentSelectedDiary: TrainingDiary?

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

        
    }

    
    //MARK: - override of prepare method
    //this method is called when GUI loads. We use it to get references to underlying view controllers
    override func prepare(for segue: NSStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        guard let tabViewController = segue.destinationController as? NSTabViewController else {return}
        
        for controller in tabViewController.childViewControllers{
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
        for c in vc.childViewControllers{
            checkToSetMainViewController(c)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        periodCB.stringValue = Period.YearToDate.rawValue
        totalUnitCB.stringValue = Unit.Hours.rawValue
        swimUnitCB.stringValue = Unit.KM.rawValue
        bikeUnitCB.stringValue = Unit.KM.rawValue
        runUnitCB.stringValue = Unit.KM.rawValue
        gymUnitCB.stringValue = Unit.Reps.rawValue
        if let currentYear = getSelectedTrainingDiary()?.lastDayOfDiary.year(){
            comparisonYear.stringValue = String(currentYear - 1)
        }else{
            comparisonYear.stringValue = "2017"
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
    //MARK: - Testing

    @IBAction func testFeature(_ sender: Any) {
        print("no feature being tested at the moment")
        let button: NSButton = sender as! NSButton
        print("\(button)")
    }
 
    @IBAction func deleteALL(_ sender: Any) {
        
        let dialog = NSAlert()
        dialog.alertStyle = .warning
        dialog.informativeText = "Are you sure?"
        dialog.messageText = "This will delete all entries in all diaries"
        dialog.addButton(withTitle: "Cancel")
        dialog.addButton(withTitle: "DELETE ALL")
    
        
        if (dialog.runModal() == NSApplication.ModalResponse.alertSecondButtonReturn) {
            let weightRequest = NSFetchRequest<NSFetchRequestResult>.init(entityName: ENTITY.Weight.rawValue)
            let physioRequest = NSFetchRequest<NSFetchRequestResult>.init(entityName: ENTITY.Physiological.rawValue)
            let workoutRequest = NSFetchRequest<NSFetchRequestResult>.init(entityName: ENTITY.Workout.rawValue)
            let dayRequest = NSFetchRequest<NSFetchRequestResult>.init(entityName: ENTITY.Day.rawValue)
            let trainingDiaryRequest = NSFetchRequest<NSFetchRequestResult>.init(entityName: ENTITY.TrainingDiary.rawValue)
            do {
                let tds = try CoreDataStackSingleton.shared.trainingDiaryPC.viewContext.fetch(trainingDiaryRequest)
                for t in tds{
                    CoreDataStackSingleton.shared.trainingDiaryPC.viewContext.delete(t as! NSManagedObject)
                }
                let days = try CoreDataStackSingleton.shared.trainingDiaryPC.viewContext.fetch(dayRequest)
                for d in days{
                    CoreDataStackSingleton.shared.trainingDiaryPC.viewContext.delete(d as! NSManagedObject)
                }
                let workouts = try CoreDataStackSingleton.shared.trainingDiaryPC.viewContext.fetch(workoutRequest)
                for r in workouts{
                    CoreDataStackSingleton.shared.trainingDiaryPC.viewContext.delete(r as! NSManagedObject)
                }
                let ws = try CoreDataStackSingleton.shared.trainingDiaryPC.viewContext.fetch(weightRequest)
                for w in ws{
                    CoreDataStackSingleton.shared.trainingDiaryPC.viewContext.delete(w as! NSManagedObject)
                }
                let ps = try CoreDataStackSingleton.shared.trainingDiaryPC.viewContext.fetch(physioRequest)
                for p in ps{
                    CoreDataStackSingleton.shared.trainingDiaryPC.viewContext.delete(p as! NSManagedObject)
                }
            } catch {
                // do something
            }
        }
    }


    // MARK: -  JSON Support
    
    @IBAction func loadFromFile(_ sender: Any) {
        if let url = getPathFromModelDialogue(withTitle: "chose .json file",andFileTypes: ["json"]) {
            let jsonImporter = JSONImporter()
            jsonImporter.importDiary(fromURL: url)
        }
    }
    
    @IBAction func mergeFromFile(_ sender: NSMenuItem) {
        if let td = getSelectedTrainingDiary(){
            let jsonImporter = JSONImporter()
            
            //this will bring up file choser for user to select file to merge and then
            //parse the file returning top level json dictionary
            //not this may return nil if user hits 'cancel' for instance
            if let url = getPathFromModelDialogue(withTitle: "chose .json file",andFileTypes: ["json"]){
                let s = Date()
                jsonImporter.merge(fromURL: url, intoDiary: td)
                print("Merge took \(Date().timeIntervalSince(s)) seconds")
            }

        }
        
    }

    @IBAction func exportHTML(_ sender: NSMenuItem){
        print("TBI exportHTML")
    }
    
    @IBAction func exportJSON(_ sender: NSMenuItem){
        if let td = getSelectedTrainingDiary(){
            guard let window = view.window else { return }
            
            let panel = NSSavePanel()
            panel.directoryURL = FileManager.default.homeDirectoryForCurrentUser
            panel.allowedFileTypes = ["json"]
            panel.canCreateDirectories = true
            panel.nameFieldStringValue = "TrainingDiary.json"
            
            panel.beginSheetModal(for: window) {(result) in
                if result.rawValue == NSFileHandlingPanelOKButton,
                    let url = panel.url{
                    
                    let exporter = JSONExporter()
                    if let jsonString = exporter.createJSON(forTrainingDiary: td){
                        do{
                            try jsonString.write(to: url, atomically: true, encoding: String.Encoding.utf8.rawValue)
                        }catch{
                            print("Unable to save HTML")
                            print(error)
                        }
                    }
                }
            }
        }
        
    }
    
    @IBAction func exportCSV(_ sender: NSMenuItem){
        let csvExporter = CSVExporter()
        
        if let td = getSelectedTrainingDiary(){
            let csv = csvExporter.convertToCVS(trainingDiary: td)
            
            if let saveFolder = selectPathFromModalDialogue(createSubFolder: "Data-\(Date().dateOnlyString())"){
                var saveFileName = saveFolder.appendingPathComponent("workouts.csv")
                do{
                    try csv.workoutCSV.write(to: saveFileName, atomically: false, encoding: .utf8)
                }catch let error as NSError{
                    print(error)
                }
                saveFileName = saveFolder.appendingPathComponent("days.csv")
                do{
                    try csv.dayCSV.write(to: saveFileName, atomically: false, encoding: .utf8)
                }catch let error as NSError{
                    print(error)
                }
            }
        }
    }
    
    //MARK: - CSV Support
    
    @IBAction func importCSV(_ sender: NSMenuItem){
        if let url = getPathFromModelDialogue(withTitle: "chose .csv file to import", andFileTypes: ["csv"]) {
            let start = Date()
            let csvImporter = CSVImporter()
            csvImporter.importDiary(fromURL: url)
            print("\(Date().timeIntervalSince(start)) seconds to import from \(url.absoluteString) ")
        }
       
    }


    
    
    //MARK: - Private functions
    
    private func getSelectedTrainingDiary() -> TrainingDiary?{
        //array controller set to only allow single selection. So the array should always have only one item
        if trainingDiarysArrayController.selectedObjects.count > 0{
            let selectedObject = trainingDiarysArrayController.selectedObjects[0]
            return selectedObject as? TrainingDiary
        }
        return nil
    }
    


    private func getPathFromModelDialogue(withTitle title: String, andFileTypes fileTypes: [String]) -> URL?{
        
        let dialog = NSOpenPanel()
        
        dialog.title                   = title
        dialog.showsResizeIndicator    = true
        dialog.showsHiddenFiles        = false
        dialog.canChooseDirectories    = true
        dialog.canCreateDirectories    = true
        dialog.allowsMultipleSelection = false
        dialog.allowedFileTypes        = fileTypes
        
        
        
        if (dialog.runModal() == NSApplication.ModalResponse.OK) {
            return dialog.url // Pathname of the file
        } else {
            // User clicked on "Cancel"
            return nil
        }
    }
    
    func selectPathFromModalDialogue(createSubFolder folder: String? = nil) -> URL?{
        //see about selecting a directory for the save
        let dialog = NSOpenPanel()
        dialog.message = "Choose directory for save."
        if let f = folder{
            dialog.message = "Choose directory for save. (a sub folder called \(f) will be created"
        }
        dialog.showsResizeIndicator    = true
        dialog.showsHiddenFiles        = false
        dialog.canChooseDirectories    = true
        dialog.canCreateDirectories    = true
        dialog.allowsMultipleSelection = false
        dialog.canChooseFiles           = false
        dialog.prompt = "Select"
        
        if (dialog.runModal() == NSApplication.ModalResponse.OK) {
            if let directory = dialog.url{
                var saveFolder = directory
                if let f = folder{
                     saveFolder = directory.appendingPathComponent(f)
                }
                
                //check for this folder
                var isDirectory: ObjCBool = false
                FileManager.default.fileExists(atPath: saveFolder.path, isDirectory: &isDirectory)
                
                if !isDirectory.boolValue{
                    print("\(saveFolder) does not exist. Will create")
                    do{
                        try FileManager.default.createDirectory(at: saveFolder, withIntermediateDirectories: true, attributes: nil)
                    }catch{
                        print(error)
                        return nil
                    }
                }
                return saveFolder
                
            }
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
            let values = td.valuesFor(dayType: ConstantString.EddingtonAll.rawValue, activity: ConstantString.EddingtonAll.rawValue, activityType: ConstantString.EddingtonAll.rawValue, equipment: ConstantString.EddingtonAll.rawValue, period: periodCB.selectedPeriod()!, unit: totalUnitCB.selectedUnit()!, from: td.lastDayOfDiary, to: td.lastDayOfDiary)
            if values.count > 0{
                currentTotal.stringValue = String(values[0].value)
            }else{
                currentTotal.stringValue = "12345.6789"
            }
            
            if let cDate = comparisonDate(){
                let values = td.valuesFor(dayType: ConstantString.EddingtonAll.rawValue, activity: ConstantString.EddingtonAll.rawValue, activityType: ConstantString.EddingtonAll.rawValue, equipment: ConstantString.EddingtonAll.rawValue, period: periodCB.selectedPeriod()!, unit: totalUnitCB.selectedUnit()!, from: cDate.startOfDay(), to: cDate.endOfDay())
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
            let values = td.valuesFor(dayType: ConstantString.EddingtonAll.rawValue, activity: FixedActivity.Swim.rawValue, activityType: ConstantString.EddingtonAll.rawValue, equipment: ConstantString.EddingtonAll.rawValue, period: periodCB.selectedPeriod()!, unit: swimUnitCB.selectedUnit()!, from: td.lastDayOfDiary, to: td.lastDayOfDiary)
            if values.count > 0{
                currentSwim.stringValue = String(values[0].value)
            }else{
                currentSwim.stringValue = "12345.6789"
            }
            
            if let cDate = comparisonDate(){
                let values = td.valuesFor(dayType: ConstantString.EddingtonAll.rawValue, activity: FixedActivity.Swim.rawValue, activityType: ConstantString.EddingtonAll.rawValue, equipment: ConstantString.EddingtonAll.rawValue, period: periodCB.selectedPeriod()!, unit: swimUnitCB.selectedUnit()!, from: cDate.startOfDay(), to: cDate.endOfDay())
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
            let values = td.valuesFor(dayType: ConstantString.EddingtonAll.rawValue, activity: FixedActivity.Bike.rawValue, activityType: ConstantString.EddingtonAll.rawValue, equipment: ConstantString.EddingtonAll.rawValue, period: periodCB.selectedPeriod()!, unit: bikeUnitCB.selectedUnit()!, from: td.lastDayOfDiary, to: td.lastDayOfDiary)
            if values.count > 0{
                currentBike.stringValue = String(values[0].value)
            }else{
                currentBike.stringValue = "12345.6789"
            }
            
            if let cDate = comparisonDate(){
                let values = td.valuesFor(dayType: ConstantString.EddingtonAll.rawValue, activity: FixedActivity.Bike.rawValue, activityType: ConstantString.EddingtonAll.rawValue, equipment: ConstantString.EddingtonAll.rawValue, period: periodCB.selectedPeriod()!, unit: bikeUnitCB.selectedUnit()!, from: cDate.startOfDay(), to: cDate.endOfDay())
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
            let values = td.valuesFor(dayType: ConstantString.EddingtonAll.rawValue, activity: FixedActivity.Run.rawValue, activityType: ConstantString.EddingtonAll.rawValue, equipment: ConstantString.EddingtonAll.rawValue, period: periodCB.selectedPeriod()!, unit: runUnitCB.selectedUnit()!, from: td.lastDayOfDiary, to: td.lastDayOfDiary)
            if values.count > 0{
                currentRun.stringValue = String(values[0].value)
            }else{
                currentRun.stringValue = "12345.6789"
            }
            
            if let cDate = comparisonDate(){
                let values = td.valuesFor(dayType: ConstantString.EddingtonAll.rawValue, activity: FixedActivity.Run.rawValue, activityType: ConstantString.EddingtonAll.rawValue, equipment: ConstantString.EddingtonAll.rawValue, period: periodCB.selectedPeriod()!, unit: runUnitCB.selectedUnit()!, from: cDate.startOfDay(), to: cDate.endOfDay())
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
            let values = td.valuesFor(dayType: ConstantString.EddingtonAll.rawValue, activity: FixedActivity.Gym.rawValue, activityType: ConstantString.EddingtonAll.rawValue, equipment: ConstantString.EddingtonAll.rawValue, period: periodCB.selectedPeriod()!, unit: gymUnitCB.selectedUnit()!, from: td.lastDayOfDiary, to: td.lastDayOfDiary)
            if values.count > 0{
                currentGym.stringValue = String(values[0].value)
            }else{
                currentGym.stringValue = "12345.6789"
            }
            
            if let cDate = comparisonDate(){
                let values = td.valuesFor(dayType: ConstantString.EddingtonAll.rawValue, activity: FixedActivity.Gym.rawValue, activityType: ConstantString.EddingtonAll.rawValue, equipment: ConstantString.EddingtonAll.rawValue, period: periodCB.selectedPeriod()!, unit: gymUnitCB.selectedUnit()!, from: cDate.startOfDay(), to: cDate.endOfDay())
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

