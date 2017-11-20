//
//  ViewController.swift
//  Training Diary
//
//  Created by Steven Lord on 07/10/2017.
//  Copyright © 2017 Steven Lord. All rights reserved.
//

/* TO DO
     1. Move JSON support to it's own class - it shouldn't be in the View Controller layer
     2. set up static variables for JSON variable ??
 */

import Cocoa

class ViewController: NSViewController, NSTableViewDelegate, NSTextFieldDelegate {

    //this has to be a variable (ie can't be derived) to be Key Value compliant for Core Data
    @objc dynamic var managedObjectContext: NSManagedObjectContext
    
    private var daysViewController: DaysViewController?
    private var eddingtonNumbersViewController: EddingtonNumbersViewController?
    private var baseDataViewController: BaseDataViewController?
    private var weightHRViewController: WeightHRViewController?
    private var graphViewController: GraphViewController?

    //MARK: - @IBOutlets
    
    @IBOutlet var trainingDiarysArrayController: NSArrayController!
    @IBOutlet weak var tsbActivityComboBox: NSComboBox!
    @IBOutlet weak var atlDaysTextField: NSTextField!
    @IBOutlet weak var ctlDaysTextField: NSTextField!
    
    //MARK: - Initialisers
    
    required init?(coder: NSCoder) {
        
        self.managedObjectContext = CoreDataStackSingleton.shared.trainingDiaryPC.viewContext
        super.init(coder: coder)
        
        ValueTransformer.setValueTransformer(TransformerNSNumberToTimeFormat(), forName: NSValueTransformerName(rawValue: "TransformerNSNumberToTimeFormat"))
    }

    
    //MARK: - override of prepare method
    //this method is called when GUI loads. We use it to get references to underlying view controllers
    override func prepare(for segue: NSStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        guard let tabViewController = segue.destinationController as? NSTabViewController else {return}
        
        for controller in tabViewController.childViewControllers{
            if let controller = controller as? DaysViewController{
                daysViewController = controller
                
            }
            if let controller = controller as? EddingtonNumbersViewController{
                eddingtonNumbersViewController = controller
            }
            if let controller = controller as? BaseDataViewController{
                baseDataViewController = controller
            }
            if let controller = controller as? WeightHRViewController{
                weightHRViewController = controller
            }
            if let controller = controller as? GraphViewController{
                graphViewController = controller
            }
        }
        

    }
    
    @IBAction func tsbActivityChanges(_ sender: NSComboBox) {
        print("Activity changed for TSB to \(sender.stringValue)")
        if let td = selectedTrainingDiary(){
            switch sender.stringValue{
            case Activity.Swim.rawValue:
                atlDaysTextField.integerValue = Int(td.swimATLDays)
                ctlDaysTextField.integerValue = Int(td.swimCTLDays)
            case Activity.Bike.rawValue:
                atlDaysTextField.integerValue = Int(td.bikeATLDays)
                ctlDaysTextField.integerValue = Int(td.bikeCTLDays)
            case Activity.Run.rawValue:
                atlDaysTextField.integerValue = Int(td.runATLDays)
                ctlDaysTextField.integerValue = Int(td.runCTLDays)
            default:
                atlDaysTextField.integerValue = Int(td.atlDays)
                ctlDaysTextField.integerValue = Int(td.ctlDays)
            }

        }
    }
    
    @IBAction func atlDaysChanged(_ sender: NSTextField) {
        print("atl days changed to: \(sender.doubleValue)")
        setSelectedATLDays(toValue: sender.doubleValue)
    }
    
    @IBAction func ctlDaysChanged(_ sender: NSTextField) {
        print("ctl days changed to: \(sender.doubleValue)")
        setSelectedCTLDays(toValue: sender.doubleValue)
    }
    
    @IBAction func newDiary(_ sender: Any){
        print("Adding a new Training Diary")
        trainingDiarysArrayController.add(sender)
    }
    
    @IBAction func removeDiary(_ sender: Any){
        print("Removing Training Diary: \(getSelectedTrainingDiary())")
        trainingDiarysArrayController.remove(sender)
    }
    
    func tableViewSelectionDidChange(_ notification: Notification) {
        if let trainingDiary = trainingDiarysArrayController.selectedObjects[0] as? TrainingDiary{
            daysViewController?.setValue(trainingDiary, forKeyPath: "trainingDiary")
            eddingtonNumbersViewController?.setValue(trainingDiary, forKeyPath: "trainingDiary")
            baseDataViewController?.setValue(trainingDiary, forKeyPath: "trainingDiary")
            weightHRViewController?.setValue(trainingDiary, forKeyPath: "trainingDiary")
            //by using the method I can insert code in that method to add obervers on the training diary
            graphViewController?.setTrainingDiary(trainingDiary)
            if let cb = tsbActivityComboBox{
                cb.selectItem(at: 0)
                tsbActivityChanges(cb)
            }
        }
    }
 
    //MARK: - @IBActions
    
    @IBAction func printEntities(_ sender: NSButton) {
        printEntities()
    }

    @IBAction func mergeFromFile(_ sender: NSMenuItem) {
        let td: TrainingDiary = getSelectedTrainingDiary()
        
        let jsonImporter = JSONImporter()
        
        //this will bring up file choser for user to select file to merge and then
        //parse the file returning top level json dictionary
        //not this may return nil if user hits 'cancel' for instance
        if let url = getPathFromModelDialogue(){
            jsonImporter.merge(fromURL: url, intoDiary: td)
        }
    }
    
    @IBAction func printEntityCounts(_ sender: NSButton) {
        CoreDataStackSingleton.shared.printEntityCounts(forDiary: getSelectedTrainingDiary())
    }
    
    

    
    @IBAction func calculateEddingtonNumbers(_ sender: Any){
        print("Calcing Eddington Numbers from base data...")
        let start = Date()
        //need to check this defaults to local timezone
        let cal = Calendar.init(identifier: Calendar.Identifier.gregorian)
        let dc = cal.dateComponents([Calendar.Component.year], from: start)
        //current year
        let year = dc.value(for: Calendar.Component.year)!
        //bit painful converting Int to Int16. Since this is a year it'll definitely be in range.
        let y: Int16 = Int16.init(exactly:year)!
        let edNums = EddingtonNumberCalculator.shared.calcEddingtonNumbersFromBaseData(forTrainingDiary: self.getSelectedTrainingDiary(), andYear: y)
        let nonZero = edNums.filter({$0.value > 0})
        print("Calculated \(edNums.count) Eddington Numbers (\(nonZero.count) non zero) in \(Date().timeIntervalSince(start)) seconds")
    }
    
    @IBAction func deleteEddingtonNumbers(_ sender: Any){
        let start = Date()
        CoreDataStackSingleton.shared.deleteAllEddingtonNumbers(forTrainingDiary: getSelectedTrainingDiary())
        print("All eddington numbers deleted in \(Date().timeIntervalSince(start)) seconds")
    }

    @IBAction func calculateHistoryForYear(_ sender: Any){
        /* There has to be a better way that this
 */
        let dialog = NSAlert()
        dialog.alertStyle = .informational
        dialog.messageText = "Please select a year"
        dialog.informativeText = "Eddington numbers will be calculated LTD to the end of selected year and annualf or that year."
        
        // figure out current year
        let cal = Calendar.init(identifier: Calendar.Identifier.gregorian)
        let year = cal.dateComponents([Calendar.Component.year], from: Date()).value(for: Calendar.Component.year)!
        
        for i in 2004...year-9 {
            dialog.addButton(withTitle: String(i))
        }
        
        let r = dialog.runModal()
        let selectedYear = r.rawValue + 1004
        let start = Date()
        switch selectedYear{
        case 2004:
        let ednums = EddingtonNumberCalculator.shared.calcEddingtonNumbersFromBaseData(forTrainingDiary: getSelectedTrainingDiary(), andYear: 2004)
            print("History for \(selectedYear) produced \(ednums.count) EddingtonNumbers and took \(Date().timeIntervalSince(start)) seconds")

        case 2005:
            let ednums = EddingtonNumberCalculator.shared.calcEddingtonNumbersFromBaseData(forTrainingDiary: getSelectedTrainingDiary(), andYear: 2005)
            print("History for \(selectedYear) produced \(ednums.count) EddingtonNumbers and took \(Date().timeIntervalSince(start)) seconds")

        case 2006:
            let ednums = EddingtonNumberCalculator.shared.calcEddingtonNumbersFromBaseData(forTrainingDiary: getSelectedTrainingDiary(), andYear: 2006)
            print("History for \(selectedYear) produced \(ednums.count) EddingtonNumbers and took \(Date().timeIntervalSince(start)) seconds")

        case 2007:
            let ednums = EddingtonNumberCalculator.shared.calcEddingtonNumbersFromBaseData(forTrainingDiary: getSelectedTrainingDiary(), andYear: 2007)
            print("History for \(selectedYear) produced \(ednums.count) EddingtonNumbers and took \(Date().timeIntervalSince(start)) seconds")

        case 2008:
            let ednums = EddingtonNumberCalculator.shared.calcEddingtonNumbersFromBaseData(forTrainingDiary: getSelectedTrainingDiary(), andYear: 2008)
            print("History for \(selectedYear) produced \(ednums.count) EddingtonNumbers and took \(Date().timeIntervalSince(start)) seconds")

        default: print("How on earth did you press that button? I thought it didn't exist")
        }
                
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
        if let url = getPathFromModelDialogue() {
            let jsonImporter = JSONImporter()
            jsonImporter.importDiary(fromURL: url)
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
    

    
    //MARK: - Private functions
    
    private func getSelectedTrainingDiary() -> TrainingDiary{
        //array controller set to only allow single selection. So the array should always have only one item
        let selectedObject = trainingDiarysArrayController.selectedObjects[0]
        return selectedObject as! TrainingDiary
    }
    


    private func getPathFromModelDialogue() -> URL?{
        
        let dialog = NSOpenPanel();
        
        dialog.title                   = "Choose a .json file";
        dialog.showsResizeIndicator    = true;
        dialog.showsHiddenFiles        = false;
        dialog.canChooseDirectories    = true;
        dialog.canCreateDirectories    = true;
        dialog.allowsMultipleSelection = false;
        dialog.allowedFileTypes        = ["json"];
        
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
    
    /* Returns the ATL days for the activity selected in tsbActivityComboBox
 */
    private func getSelectedTSBConstants() -> (atlDays: Double, ctlDays: Double){
        var result  = (atlDays: 0.0, ctlDays: 0.0)
        if let td = selectedTrainingDiary(){
            if let comboBox = tsbActivityComboBox{
                switch comboBox.stringValue{
                case Activity.Swim.rawValue:
                    result.atlDays = td.swimATLDays
                    result.ctlDays = td.swimCTLDays
                case Activity.Bike.rawValue:
                    result.atlDays = td.bikeATLDays
                    result.ctlDays = td.bikeCTLDays
                case Activity.Run.rawValue:
                    result.atlDays = td.runATLDays
                    result.ctlDays = td.runCTLDays
                default:
                    result.atlDays = td.atlDays
                    result.ctlDays = td.ctlDays
                }
            }
        }
        return result
    }
    
    // sets the ATL days for the activity selected in tsbActivityComboBox. Only sets if changed
    private func setSelectedATLDays(toValue value: Double){
        if value != getSelectedTSBConstants().atlDays{
            if let td = selectedTrainingDiary(){
                if let comboBox = tsbActivityComboBox{
                    switch comboBox.stringValue{
                    case Activity.Swim.rawValue:
                        td.setValue(value, forKey: TrainingDiaryProperty.swimATLDays.rawValue)
                    case Activity.Bike.rawValue:
                        td.setValue(value, forKey: TrainingDiaryProperty.bikeATLDays.rawValue)
                    case Activity.Run.rawValue:
                        td.setValue(value, forKey: TrainingDiaryProperty.runATLDays.rawValue)
                    default:
                        td.setValue(value, forKey: TrainingDiaryProperty.atlDays.rawValue)
                    }
                }
            }
        }
    }

    // sets the ATL days for the activity selected in tsbActivityComboBox. Only sets if changed
    private func setSelectedCTLDays(toValue value: Double){
        if value != getSelectedTSBConstants().atlDays{
            if let td = selectedTrainingDiary(){
                if let comboBox = tsbActivityComboBox{
                    switch comboBox.stringValue{
                    case Activity.Swim.rawValue:
                        td.setValue(value, forKey: TrainingDiaryProperty.swimCTLDays.rawValue)
                    case Activity.Bike.rawValue:
                        td.setValue(value, forKey: TrainingDiaryProperty.bikeCTLDays.rawValue)
                    case Activity.Run.rawValue:
                        td.setValue(value, forKey: TrainingDiaryProperty.runCTLDays.rawValue)
                    default:
                        td.setValue(value, forKey: TrainingDiaryProperty.ctlDays.rawValue)
                    }
                }
            }
        }
    }

}

