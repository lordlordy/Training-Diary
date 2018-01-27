//
//  AdminViewController.swift
//  Training Diary
//
//  Created by Steven Lord on 25/01/2018.
//  Copyright © 2018 Steven Lord. All rights reserved.
//

import Cocoa

class AdminViewController: NSViewController, TrainingDiaryViewController {
  
    @objc dynamic var trainingDiary: TrainingDiary?
    @objc dynamic var filterPredicate: NSPredicate?
    @IBOutlet weak var predicateEditor: NSPredicateEditor!
    
    @IBAction func uniqueActivities(_ sender: Any){
        let results = trainingDiary!.uniqueActivityTypePairs()
        for r in results{
            print(r)
        }
    }
    
    @IBAction func printPredicate(_ sender: Any){
        if let p = predicateEditor{
            print(p.predicate ?? "no predicate")
        }
    }
    
    func set(trainingDiary td: TrainingDiary) {
        trainingDiary = td
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let editor = predicateEditor{
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

            
            editor.rowTemplates.append(contentsOf: [doubleTemplate, stringTemplate, booleanTemplate])
        }
    
    }
    


    
}
