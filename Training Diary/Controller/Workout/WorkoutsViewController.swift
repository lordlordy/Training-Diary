//
//  WorkoutsViewController.swift
//  Training Diary
//
//  Created by Steven Lord on 02/03/2018.
//  Copyright © 2018 Steven Lord. All rights reserved.
//

import Cocoa

class WorkoutsViewController: TrainingDiarySplitViewController {
    
    
    @IBOutlet var workoutsArrayController: NSArrayController!
    
    @objc dynamic var workoutsAC: NSArrayController?{
        for c in children{
            if let vc = c as? WorkoutsListViewController{
                return vc.workoutsAC
            }
        }
        return nil
    }
    
    @IBAction func exportSelectionAsCSV(_ sender: Any) {
        
        if let directoryURL = OpenAndSaveDialogues().saveFilePath(suggestedFileName: "Workouts", allowFileTypes: ["csv"]){
            if let workouts = workoutsArrayController?.selectedObjects as? [Workout]{
                
                let csv = CSVExporter().convertToCSV(workouts)
                do{
                    try csv.write(to: directoryURL, atomically: false, encoding: .utf8)
                }catch let error as NSError{
                    print(error)
                }

            }else{
                print("Failed to get any selected Workouts from Array Controller: \(String(describing: workoutsArrayController))")
            }
        }
    }
    
    @IBAction func exportSelectionAsJSON(_ sender: Any) {
        
        if let url = OpenAndSaveDialogues().saveFilePath(suggestedFileName: "Workouts", allowFileTypes: ["json"]){
            
            if let jsonString = JSONExporter().createJSON(forWorkouts: workoutsArrayController?.selectedObjects as? [Workout] ?? []){
                do{
                    try jsonString.write(to: url, atomically: true, encoding: String.Encoding.utf8.rawValue)
                }catch{
                    print("Unable to save JSON")
                    print(error)
                }
            }
        }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let editor = predicateEditor(){
            editor.addRow(nil)
            
            var doubleExpressions: [NSExpression] = []
            var doubleOperators: [NSNumber] = []
            for p in WorkoutProperty.DoubleProperties{
                doubleExpressions.append(NSExpression(forKeyPath: p.rawValue))
            }
            doubleOperators.append(NSNumber(value:NSComparisonPredicate.Operator.equalTo.rawValue))
            doubleOperators.append(NSNumber(value:NSComparisonPredicate.Operator.greaterThan.rawValue))
            doubleOperators.append(NSNumber(value:NSComparisonPredicate.Operator.greaterThanOrEqualTo.rawValue))
            doubleOperators.append(NSNumber(value:NSComparisonPredicate.Operator.lessThan.rawValue))
            doubleOperators.append(NSNumber(value:NSComparisonPredicate.Operator.lessThanOrEqualTo.rawValue))
            
            let doubleTemplate = NSPredicateEditorRowTemplate.init(leftExpressions: doubleExpressions, rightExpressionAttributeType: NSAttributeType.doubleAttributeType, modifier: NSComparisonPredicate.Modifier.direct, operators: doubleOperators, options: Int(NSComparisonPredicate.Options.caseInsensitive.rawValue))
            
            var stringExpressions: [NSExpression] = []
            var stringOperators: [NSNumber] = []
            for p in WorkoutProperty.StringProperties{
                stringExpressions.append(NSExpression(forKeyPath: p.rawValue))
            }
            stringOperators.append(NSNumber(value:NSComparisonPredicate.Operator.contains.rawValue))
            stringOperators.append(NSNumber(value:NSComparisonPredicate.Operator.equalTo.rawValue))
            
            let stringTemplate = NSPredicateEditorRowTemplate.init(leftExpressions: stringExpressions, rightExpressionAttributeType: NSAttributeType.stringAttributeType, modifier: NSComparisonPredicate.Modifier.direct, operators: stringOperators, options: Int(NSComparisonPredicate.Options.caseInsensitive.rawValue))
            
            var booleanExpressions: [NSExpression] = []
            var booleanOperators: [NSNumber] = []
            for p in WorkoutProperty.BooleanProperties{
                booleanExpressions.append(NSExpression(forKeyPath: p.rawValue))
            }
            booleanOperators.append(NSNumber(value:NSComparisonPredicate.Operator.equalTo.rawValue))
            booleanOperators.append(NSNumber(value:NSComparisonPredicate.Operator.notEqualTo.rawValue))
            
            let booleanTemplate = NSPredicateEditorRowTemplate.init(leftExpressions: booleanExpressions, rightExpressionAttributeType: NSAttributeType.booleanAttributeType, modifier: NSComparisonPredicate.Modifier.direct, operators: booleanOperators, options: Int(NSComparisonPredicate.Options.caseInsensitive.rawValue))
            
            
            var dateExpressions: [NSExpression] = []
            var dateOperators: [NSNumber] = []
            dateExpressions.append(NSExpression(forKeyPath: "day.date"))
            dateOperators.append(NSNumber(value:NSComparisonPredicate.Operator.equalTo.rawValue))
            dateOperators.append(NSNumber(value:NSComparisonPredicate.Operator.greaterThan.rawValue))
            dateOperators.append(NSNumber(value:NSComparisonPredicate.Operator.greaterThanOrEqualTo.rawValue))
            dateOperators.append(NSNumber(value:NSComparisonPredicate.Operator.lessThan.rawValue))
            dateOperators.append(NSNumber(value:NSComparisonPredicate.Operator.lessThanOrEqualTo.rawValue))
            
            let dateTemplate = NSPredicateEditorRowTemplate.init(leftExpressions: dateExpressions, rightExpressionAttributeType: NSAttributeType.dateAttributeType, modifier: NSComparisonPredicate.Modifier.direct, operators: dateOperators, options: Int(NSComparisonPredicate.Options.caseInsensitive.rawValue))
            
            editor.rowTemplates.append(contentsOf: [doubleTemplate, stringTemplate, booleanTemplate, dateTemplate])
        }
        
    }
    
    
    private func predicateEditor() -> NSPredicateEditor?{
        for vc in children{
            if let wpvc = vc as? WorkoutPredicateViewController{
                return wpvc.predicateEditor
            }
        }
        return nil
        
    }
    
    
}

