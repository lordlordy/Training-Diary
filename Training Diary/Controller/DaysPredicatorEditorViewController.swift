//
//  DaysPredicatorEditorViewController.swift
//  Training Diary
//
//  Created by Steven Lord on 06/03/2018.
//  Copyright © 2018 Steven Lord. All rights reserved.
//

import Cocoa

class DaysPredicatorEditorViewController: TrainingDiaryViewController {

    @IBOutlet weak var predicateEditor: NSPredicateEditor!
    
    @IBAction func add(_ sender: Any) {
        if let pe = predicateEditor{
            pe.addRow(nil)
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let editor = predicateEditor{

            
         //  editor.objectValue = NSCompoundPredicate.init(type: NSCompoundPredicate.LogicalType.not , subpredicates: [])
            
            if let p = editor.objectValue as? NSCompoundPredicate{
                print(p)
                print(p.subpredicates)
                print(p.compoundPredicateType)
            }
            
            
            
            var stringExpressions: [NSExpression] = []
            var stringOperators: [NSNumber] = []
            for p in DayProperty.stringProperties{
                stringExpressions.append(NSExpression(forKeyPath: p.rawValue))
            }
            stringOperators.append(NSNumber(value:NSComparisonPredicate.Operator.contains.rawValue))
            stringOperators.append(NSNumber(value:NSComparisonPredicate.Operator.equalTo.rawValue))
            stringOperators.append(NSNumber(value:NSComparisonPredicate.Operator.notEqualTo.rawValue))
            
            let stringTemplate = NSPredicateEditorRowTemplate.init(leftExpressions: stringExpressions, rightExpressionAttributeType: NSAttributeType.stringAttributeType, modifier: NSComparisonPredicate.Modifier.direct, operators: stringOperators, options: Int(NSComparisonPredicate.Options.caseInsensitive.rawValue))
            
            var doubleExpressions: [NSExpression] = []
            var doubleOperators: [NSNumber] = []
            for p in DayProperty.doubleProperties{
                doubleExpressions.append(NSExpression(forKeyPath: p.rawValue))
            }
            doubleOperators.append(NSNumber(value:NSComparisonPredicate.Operator.equalTo.rawValue))
            doubleOperators.append(NSNumber(value:NSComparisonPredicate.Operator.greaterThan.rawValue))
            doubleOperators.append(NSNumber(value:NSComparisonPredicate.Operator.greaterThanOrEqualTo.rawValue))
            doubleOperators.append(NSNumber(value:NSComparisonPredicate.Operator.lessThan.rawValue))
            doubleOperators.append(NSNumber(value:NSComparisonPredicate.Operator.lessThanOrEqualTo.rawValue))
            
            let doubleTemplate = NSPredicateEditorRowTemplate.init(leftExpressions: doubleExpressions, rightExpressionAttributeType: NSAttributeType.doubleAttributeType, modifier: NSComparisonPredicate.Modifier.direct, operators: doubleOperators, options: Int(NSComparisonPredicate.Options.caseInsensitive.rawValue))

            var intExpressions: [NSExpression] = []
            var intOperators: [NSNumber] = []
            for p in DayProperty.intProperties{
                intExpressions.append(NSExpression(forKeyPath: p.rawValue))
            }
            intOperators.append(NSNumber(value:NSComparisonPredicate.Operator.equalTo.rawValue))
            intOperators.append(NSNumber(value:NSComparisonPredicate.Operator.greaterThan.rawValue))
            intOperators.append(NSNumber(value:NSComparisonPredicate.Operator.greaterThanOrEqualTo.rawValue))
            intOperators.append(NSNumber(value:NSComparisonPredicate.Operator.lessThan.rawValue))
            intOperators.append(NSNumber(value:NSComparisonPredicate.Operator.lessThanOrEqualTo.rawValue))
            
            let intTemplate = NSPredicateEditorRowTemplate.init(leftExpressions: intExpressions, rightExpressionAttributeType: NSAttributeType.integer64AttributeType, modifier: NSComparisonPredicate.Modifier.direct, operators: intOperators, options: Int(NSComparisonPredicate.Options.caseInsensitive.rawValue))
            
            
            var dateExpressions: [NSExpression] = []
            var dateOperators: [NSNumber] = []
            for p in DayProperty.dateProperties{
                dateExpressions.append(NSExpression(forKeyPath: p.rawValue))
            }
            dateOperators.append(NSNumber(value:NSComparisonPredicate.Operator.equalTo.rawValue))
            dateOperators.append(NSNumber(value:NSComparisonPredicate.Operator.greaterThan.rawValue))
            dateOperators.append(NSNumber(value:NSComparisonPredicate.Operator.greaterThanOrEqualTo.rawValue))
            dateOperators.append(NSNumber(value:NSComparisonPredicate.Operator.lessThan.rawValue))
            dateOperators.append(NSNumber(value:NSComparisonPredicate.Operator.lessThanOrEqualTo.rawValue))
            
            let dateTemplate = NSPredicateEditorRowTemplate.init(leftExpressions: dateExpressions, rightExpressionAttributeType: NSAttributeType.dateAttributeType, modifier: NSComparisonPredicate.Modifier.direct, operators: dateOperators, options: Int(NSComparisonPredicate.Options.caseInsensitive.rawValue))
            
            editor.rowTemplates.append(contentsOf: [stringTemplate, doubleTemplate, intTemplate, dateTemplate])
            
            
        }
        
    }
    
}
