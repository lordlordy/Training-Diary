//
//  EddingtonTableViewController.swift
//  Training Diary
//
//  Created by Steven Lord on 08/03/2018.
//  Copyright © 2018 Steven Lord. All rights reserved.
//

import Cocoa

class EddingtonTableViewController: TrainingDiaryViewController, NSComboBoxDataSource, ReferenceToMainProtocol {

    private var mainViewController: ViewController?

    
    //MARK: - Filter Actions
    @IBAction func dayTypeField(_ sender: NSTextField) {
        dayType = sender.stringValue
        if dayType == "" {dayType = nil}
        updatePredicate()
    }
    
    @IBAction func equipmentField(_ sender: NSTextField) {
        self.equipment = sender.stringValue
        if self.equipment == "" {self.equipment = nil}
        updatePredicate()
    }
    @IBAction func activityField(_ sender: NSTextField) {
        self.activity = sender.stringValue
        if self.activity == "" {self.activity = nil}
        updatePredicate()
    }
    @IBAction func activityTypeField(_ sender: NSTextField) {
        self.activityType = sender.stringValue
        if self.activityType == "" {self.activityType = nil}
        updatePredicate()
    }
    
    @IBAction func periodField(_ sender: NSTextField) {
        self.period = sender.stringValue
        if self.period == "" {self.period = nil}
        updatePredicate()
    }
    
    @IBAction func unitField(_ sender: NSTextField) {
        self.unit = sender.stringValue
        if self.unit == "" {self.unit = nil}
        updatePredicate()
    }
    
    //MARK: - Button actions
    @IBAction func add(_ sender: Any){
        if let eac = getEddingtonNumberArrayController(){
            eac.add(sender)
        }
    }
    
    @IBAction func remove(_ sender: Any){
        if let eac = getEddingtonNumberArrayController(){
            eac.remove(sender)
        }
    }
    
    @IBAction func exportSelectionAsJSON(_ sender: Any) {
        if let url = OpenAndSaveDialogues().saveFilePath(suggestedFileName: "EddingtonNumbers", allowFileTypes: ["json"]){
            if let jsonString = JSONExporter().createJSON(forEddingtonNumbers: selectedRows()){
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
            
            let csv = CSVExporter().convertToCSV(selectedRows())
            
            var saveFileName = directoryURL.appendingPathComponent("eddingtonNumbers.csv")
            do{
                try csv.eddingtonNumbers.write(to: saveFileName, atomically: false, encoding: .utf8)
            }catch let error as NSError{
                print(error)
            }
            for d in csv.annualHistory{
                let adjustedKey: String = d.key.replacingOccurrences(of: EddingtonNumber.codeDelimiter, with: "~")
                saveFileName = directoryURL.appendingPathComponent(adjustedKey + "-AnnualHistory.csv")
                do{
                    try d.value.write(to: saveFileName, atomically: false, encoding: .utf8)
                }catch let error as NSError{
                    print(error)
                }
            }
            for d in csv.contributors{
                let adjustedKey: String = d.key.replacingOccurrences(of: EddingtonNumber.codeDelimiter, with: "~")
                saveFileName = directoryURL.appendingPathComponent(adjustedKey + "-Contributors.csv")
                do{
                    try d.value.write(to: saveFileName, atomically: false, encoding: .utf8)
                }catch let error as NSError{
                    print(error)
                }
            }
            for d in csv.history{
                let adjustedKey: String = d.key.replacingOccurrences(of: EddingtonNumber.codeDelimiter, with: "~")
                saveFileName = directoryURL.appendingPathComponent(adjustedKey + "-History.csv")
                do{
                    try d.value.write(to: saveFileName, atomically: false, encoding: .utf8)
                }catch let error as NSError{
                    print(error)
                }
            }
        }
        
    }
    
    //MARK: - Calc

    @IBAction func calculateSelection(_ sender: NSButton) {
        
        let start = Date()
        var slowCalcs: [(code: String, seconds: TimeInterval)] = []
        mainViewController!.mainStatusField!.stringValue = "EDDINGTON NUMBER CALCULATION: starting..."
        DispatchQueue.global(qos: .userInitiated).async {
            var count: Double = 0.0
            let total: Double = Double(self.selectedRows().count)
            for edNum in self.selectedRows(){
                count += 1
                let secs = Int(Date().timeIntervalSince(start))
                DispatchQueue.main.sync {
                    self.mainViewController!.mainStatusField!.stringValue = "EDDINGTON NUMBER CALCULATION: \(Int(count)) of \(Int(total)) : \(edNum.eddingtonCode) (\(secs)s) ..."
                }
                let subStart = Date()
                let calculator = EddingtonNumberCalculator()
                calculator.calculate(eddingtonNumber: edNum)
                DispatchQueue.main.async {
                    
                    edNum.update(forCalculator: calculator)
                    
                    self.mainViewController!.mainProgressBar!.doubleValue = 100.0 * count / total
                }
                let timeTaken = Date().timeIntervalSince(subStart)
                if timeTaken > 1.0{
                    slowCalcs.append((edNum.eddingtonCode, timeTaken))
                }
                print("Time taken for \(edNum.eddingtonCode): \(timeTaken) seconds")
            }
            print("Slow calculations:")
            var totalSlowSeconds = 0.0
            for s in slowCalcs.sorted(by: {$0.seconds > $1.seconds}) {
                print(s)
                totalSlowSeconds += s.seconds
            }
            print("Slow calculations totaled \(totalSlowSeconds) seconds")
            let slowAverage = totalSlowSeconds / Double(slowCalcs.count)
            let totalSeconds = Date().timeIntervalSince(start)
            let otherAverage = (totalSeconds - totalSlowSeconds) / (total - Double(slowCalcs.count))
            print("Slow average = \(slowAverage) other average = \(otherAverage)")
            print("Time taken for new Ed num calculation: \(totalSeconds) seconds.")
            DispatchQueue.main.async {
                self.mainViewController!.mainStatusField!.stringValue = "EDDINGTON NUMBER CALCULATION: Calc complete in \(Int(totalSeconds))s"
                print("TOTAL TIME = \(Date().timeIntervalSince(start))")
            }
        }
        
 //       updateGraph()
    }
    
    //MARK: - ReferenceToMainProtocol
    func setMainViewControllerReference(to vc: ViewController){
        mainViewController = vc
    }
    
    
    //MARK: - NSComboBoxDataSource
    func comboBox(_ comboBox: NSComboBox, objectValueForItemAt index: Int) -> Any? {
        if let identifier = comboBox.identifier{
            switch identifier.rawValue{
                
            case "EddingtonActivityComboBox":
                let activities = trainingDiary!.eddingtonActivities()
                if index < activities.count{
                    return activities[index]
                }
            case "EddingtonActivityTypeComboBox":
                guard let c = comboBox.superview as? NSTableCellView else{ return 0 }
                if let e = c.objectValue as? EddingtonNumber{
                    if let a = e.activity{
                        let types = trainingDiary!.eddingtonActivityTypes(forActivityString: a)
                        if index < types.count{
                            return types[index]
                        }
                    }
                }
            case "EddingtonEquipmentComboBox":
                guard let c = comboBox.superview as? NSTableCellView else{ return 0 }
                if let e = c.objectValue as? EddingtonNumber{
                    if let a = e.activity{
                        let types = trainingDiary!.eddingtonEquipment(forActivityString: a)
                        if index < types.count{
                            return types[index]
                        }
                    }
                }
                
            case "EddingtonDayTypeComboBox":
                if let td = trainingDiary{
                    let values = td.eddingtonDayTypes()
                    if index < values.count{
                        return values[index]
                    }
                }
            default:
                print("What combo box is this \(identifier.rawValue) which I'm (DaysViewController) a data source for? ")
            }
        }
        return nil
    }
    
    func numberOfItems(in comboBox: NSComboBox) -> Int {
        if let identifier = comboBox.identifier{
            switch identifier.rawValue{
                
            case "EddingtonActivityComboBox":
                return trainingDiary!.eddingtonActivities().count
            case "EddingtonActivityTypeComboBox":
                guard let c = comboBox.superview as? NSTableCellView else{ return 0 }
                if let e = c.objectValue as? EddingtonNumber{
                    return trainingDiary!.eddingtonActivityTypes(forActivityString: e.activity!).count
                }
            case "EddingtonEquipmentComboBox":
                guard let c = comboBox.superview as? NSTableCellView else{ return 0 }
                if let e = c.objectValue as? EddingtonNumber{
                    return trainingDiary!.eddingtonEquipment(forActivityString: e.activity!).count
                }
            case "EddingtonDayTypeComboBox":
                if let td = trainingDiary{
                    return td.eddingtonDayTypes().count
                }
            default:
                return 0
            }
        }
        return 0
    }
    
    //MARK: - Private
    
    private var dayType: String?
    private var activity: String?
    private var activityType: String?
    private var equipment: String?
    private var period: String?
    private var unit: String?
    
    private func updatePredicate(){
        var predicateString: String = ""
        var arguments: [Any] = []
        var isFirstPredicate = true
        if let dt = dayType{
            predicateString = addTo(predicateString: predicateString, withPredicateString: "dayType CONTAINS %@", isFirstPredicate)
            arguments.append(dt)
            isFirstPredicate = false
        }
        if let a = activity{
            predicateString = addTo(predicateString: predicateString, withPredicateString: " activity CONTAINS %@", isFirstPredicate)
            arguments.append(a)
            isFirstPredicate = false
        }
        if let at = activityType{
            predicateString = addTo(predicateString: predicateString, withPredicateString: " activityType CONTAINS %@", isFirstPredicate)
            arguments.append(at)
            isFirstPredicate = false
        }
        if let e = equipment{
            predicateString = addTo(predicateString: predicateString, withPredicateString: " equipment CONTAINS %@", isFirstPredicate)
            arguments.append(e)
            isFirstPredicate = false
        }
        if let p = period{
            predicateString = addTo(predicateString: predicateString, withPredicateString: " period CONTAINS %@", isFirstPredicate)
            arguments.append(p)
            isFirstPredicate = false
        }
        if let u = unit{
            predicateString = addTo(predicateString: predicateString, withPredicateString: " unit CONTAINS %@", isFirstPredicate)
            arguments.append(u)
            isFirstPredicate = false
        }

        
        if let ac = getEddingtonNumberArrayController(){
            if predicateString != ""{
                let myPredicate = NSPredicate.init(format: predicateString, argumentArray: arguments)
                ac.filterPredicate = myPredicate
                
            }else{
                ac.filterPredicate = nil
                isFirstPredicate = true
            }

        }
    
    }
    
    private func addTo(predicateString: String, withPredicateString: String,_ isFirstPredicate: Bool) -> String{
        if isFirstPredicate{
            return withPredicateString
        }else{
            return predicateString + " AND " + withPredicateString
        }
    }
    
    private func getEddingtonNumberArrayController() -> NSArrayController?{
        //this is sitting in EddingtonSplitViewControllerfunc
        if let p = parent?.parent as? EddingtonSplitViewController{
            return p.eddingtonNumberAC
        }
        return nil
    }
    
    private func selectedRows() -> [EddingtonNumber]{
        if let eac = getEddingtonNumberArrayController(){
            if let selectedObjects = eac.selectedObjects{
                return selectedObjects as! [EddingtonNumber]
            }
        }
        return []
    }
    
}
