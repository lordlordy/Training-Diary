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
    
    private var daysViewController: DaysViewController?
    private var eddingtonNumbersViewController: EddingtonNumbersViewController?
    private var weightHRViewController: WeightHRViewController?
    private var graphViewController: GraphViewController?
    private var comparisonGraphViewController: CompareGraphViewController?
    
    private var trainingDiaryVCs: [TrainingDiaryViewController] = []

    //MARK: - @IBOutlets
    
    @IBOutlet var trainingDiarysArrayController: NSArrayController!
    
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
            if let c = controller as? TrainingDiaryViewController{
                trainingDiaryVCs.append(c)
            }
            if let controller = controller as? DaysViewController{ daysViewController = controller }
            if let controller = controller as? EddingtonNumbersViewController{ eddingtonNumbersViewController = controller }
            if let controller = controller as? WeightHRViewController{ weightHRViewController = controller }
            if let controller = controller as? GraphViewController{ graphViewController = controller }
            if let controller = controller as? CompareGraphViewController{ comparisonGraphViewController = controller }
        }
        
    }

    
 /*   @IBAction func recalcAllTSB(_ sender: NSButton) {
        let start = Date()
        if let td = selectedTrainingDiary(){
            for a in ActivityEnum.allActivities{
                td.calcTSB(forActivity: a, fromDate: td.firstDayOfDiary)
            }
        }
        print("TSB calculation for all activities took \(Date().timeIntervalSince(start)) seconds")

        
    }
    
    @IBAction func recalcFromTSB(_ sender: NSButton) {
        if let td = selectedTrainingDiary(){
            if let d = latestSelectedDate(){
                for a in ActivityEnum.allActivities{
                    td.calcTSB(forActivity: a, fromDate: d)
                }
            }
        }
    }
   */
    
    @IBAction func newDiary(_ sender: Any){
        trainingDiarysArrayController.add(sender)
    }
    
    @IBAction func removeDiary(_ sender: Any){
        trainingDiarysArrayController.remove(sender)
    }
    
    func tableViewSelectionDidChange(_ notification: Notification) {
        if let trainingDiary = trainingDiarysArrayController.selectedObjects[0] as? TrainingDiary{
            
            for c in trainingDiaryVCs{
                c.set(trainingDiary: trainingDiary)
            }
            
        }
    }
 
    //MARK: - @IBActions
    
    @IBAction func printEntities(_ sender: NSButton) {
        printEntities()
    }


    
    @IBAction func printEntityCounts(_ sender: NSButton) {
        CoreDataStackSingleton.shared.printEntityCounts(forDiary: getSelectedTrainingDiary())
    }
    


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
        let td: TrainingDiary = getSelectedTrainingDiary()
        
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
    
    @IBAction func exportJSON(_ sender: NSMenuItem){
        let td: TrainingDiary = getSelectedTrainingDiary()
        let keys = td.attributeKeys
        let dictionary = td.dictionaryWithValues(forKeys: keys)
        print(keys)
        print(dictionary)
        //   let td = ["Test":"Data"]
        do {
            let data = try JSONSerialization.data(withJSONObject: dictionary, options: .prettyPrinted)
            let string = NSString.init(data: data, encoding: String.Encoding.ascii.rawValue)
            print(string!)
        } catch  {
            print("JSON export failed")
        }
        
    }
    
    @IBAction func exportCSV(_ sender: NSMenuItem){
        let csvExporter = CSVExporter()
        let csv = csvExporter.convertToCVS(trainingDiary: getSelectedTrainingDiary())
        
        let homeDir = FileManager.default.homeDirectoryForCurrentUser
        var saveFileName = homeDir.appendingPathComponent("workouts.csv")
        do{
            try csv.workoutCSV.write(to: saveFileName, atomically: false, encoding: .ascii)
        }catch let error as NSError{
            print(error)
        }
        saveFileName = homeDir.appendingPathComponent("days.csv")
        do{
            try csv.dayCSV.write(to: saveFileName, atomically: false, encoding: .ascii)
        }catch let error as NSError{
            print(error)
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
    
    private func getSelectedTrainingDiary() -> TrainingDiary{
        //array controller set to only allow single selection. So the array should always have only one item
        let selectedObject = trainingDiarysArrayController.selectedObjects[0]
        return selectedObject as! TrainingDiary
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
    


    private func selectedTrainingDiary() -> TrainingDiary?{
        if let tdac = trainingDiarysArrayController{
            if tdac.selectedObjects.count > 0{
                return tdac.selectedObjects[0] as? TrainingDiary
            }
        }
        return nil
    }
    
    private func printEntities() {
        print("Re-implementing. Please try later")
        
    }
    

    private func selectedDays() -> [Day]{
        if let dvc = daysViewController{
            if let dac = dvc.daysArrayController{
                return dac.selectedObjects as! [Day]
            }
        }
        return []
    }
    
    private func latestSelectedDate() -> Date?{
        var latestDate: Date?
        for d in selectedDays(){
            if let latest = latestDate{
                if d.date! > latest{
                    latestDate = d.date
                }
            }else{
                latestDate = d.date
            }
        }
        
        return latestDate
    }

}

