//
//  EddingtonSearchViewController.swift
//  Training Diary
//
//  Created by Steven Lord on 27/02/2018.
//  Copyright © 2018 Steven Lord. All rights reserved.
//

import Cocoa

class EddingtonSearchViewController: TrainingDiaryViewController {
    
//    @objc dynamic var trainingDiary: TrainingDiary?
    @IBOutlet weak var predicateEditor: NSPredicateEditor!
    @IBOutlet var eddingtonNumberAC: NSArrayController!
    @IBOutlet weak var tableView: TableViewWithColumnSort!
    
    @IBAction func saveAsHTML(_ sender: Any) {
        saveFilteredHTML()
    }
    
    @IBAction func removeSelection(_ sender: Any) {
        if let selection = eddingtonNumberAC?.selectedObjects as? [LTDEddingtonNumber]{
            for s in selection{
                CoreDataStackSingleton.shared.delete(entity: s)
            }
            tableView!.reloadData()
        }
    }
    
    @IBAction func calcSelection(_ sender: Any) {
        var edNums = Set<LTDEddingtonNumber>()
        for s in eddingtonNumberAC!.selectedObjects{
            if let leaf = s as? LTDEddingtonNumber{
                edNums.insert(leaf)
                
            }
        }
        let calculator = EddingtonNumberCalculator()
        for e in edNums{
            let result = calculator.quickCaclulation(forDayType: e.dayType!,forActivity: e.activity!, andType: e.activityType!, equipment: e.equipment!, andPeriod: Period(rawValue: e.period!)!, andUnit: Unit(rawValue: e.unit!)!, inTrainingDiary: trainingDiary!)
            trainingDiary!.addLTDEddingtonNumber(forDayType: e.dayType!, forActivity: e.activity!, type: e.activityType!, equipment: e.equipment!, period: Period(rawValue: e.period!)!, unit: Unit(rawValue: e.unit!)!, value: result.ednum, plusOne: result.plusOne, maturity: result.maturity)
            
            print("\(e.shortCode) : \(result)")
        }
        
    }

    override func viewDidLoad(){
        super.viewDidLoad()
        
        if let editor = predicateEditor{
            editor.addRow(nil)
            
            var stringExpressions: [NSExpression] = []
            var stringOperators: [NSNumber] = []
            for p in LTDEddingtonNumberProperty.StringProperties{
                stringExpressions.append(NSExpression(forKeyPath: p.rawValue))
            }
            stringOperators.append(NSNumber(value:NSComparisonPredicate.Operator.contains.rawValue))
            stringOperators.append(NSNumber(value:NSComparisonPredicate.Operator.equalTo.rawValue))
            stringOperators.append(NSNumber(value:NSComparisonPredicate.Operator.notEqualTo.rawValue))

            let stringTemplate = NSPredicateEditorRowTemplate.init(leftExpressions: stringExpressions, rightExpressionAttributeType: NSAttributeType.stringAttributeType, modifier: NSComparisonPredicate.Modifier.direct, operators: stringOperators, options: Int(NSComparisonPredicate.Options.caseInsensitive.rawValue))
            
            let booleanExpressions: [NSExpression] = [NSExpression(forKeyPath: LTDEddingtonNumberProperty.isWeekDay.rawValue),NSExpression(forKeyPath: LTDEddingtonNumberProperty.isMonth.rawValue)]
            var booleanOperators: [NSNumber] = []
            booleanOperators.append(NSNumber(value:NSComparisonPredicate.Operator.equalTo.rawValue))
            booleanOperators.append(NSNumber(value:NSComparisonPredicate.Operator.notEqualTo.rawValue))
            
            let booleanTemplate = NSPredicateEditorRowTemplate.init(leftExpressions: booleanExpressions, rightExpressionAttributeType: NSAttributeType.booleanAttributeType, modifier: NSComparisonPredicate.Modifier.direct, operators: booleanOperators, options: Int(NSComparisonPredicate.Options.caseInsensitive.rawValue))
            
            
            editor.rowTemplates.append(contentsOf: [stringTemplate, booleanTemplate])
            

        }
        
    }

    
    private func saveFilteredHTML(){
       
        if let edNumSet = eddingtonNumberAC.arrangedObjects as? [LTDEddingtonNumber]{
            let htmlSaver = HTMLGenerateAndSave()
            htmlSaver.saveAsHTML(edNumSet, fromView: view)
        }
        

    }
    
}
