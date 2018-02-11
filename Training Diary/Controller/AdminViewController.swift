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
    
    @IBOutlet weak var predicateEditor: NSPredicateEditor!
    
    @objc dynamic var yearNodes: [PeriodNode] = []

    //MARK: - IBActions
    @IBAction func outlineViewDoubleClicked(_ sender: NSOutlineView) {
        
        let item = sender.item(atRow: sender.clickedRow)
        
        if sender.isItemExpanded(item){
            sender.collapseItem(item)
        }else{
            sender.expandItem(item)
        }
        
    }

    
    private func getYearNode(forName n: String) -> PeriodNode?{
        for y in yearNodes{
            if y.name == n { return y }
        }
        return nil
    }

    @IBAction func printPredicate(_ sender: Any){
        if let p = predicateEditor{
            print(p.predicate ?? "no predicate")
        }
    }
    
    //MARK: - TrainingDiaryViewController implentation
    
    func set(trainingDiary td: TrainingDiary) {
        trainingDiary = td
    }
    

    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let _ = trainingDiary{
            createOutlineView()
        }
        
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
    


    private func createOutlineView(){
        yearNodes = []
        for d in trainingDiary!.descendingOrderedDays(){
            let year: String = String(d.date!.year())
            let month: String = d.date!.monthAsString()
            var yearNode: PeriodNode
            var monthNode: PeriodNode
            
            if let yNode = getYearNode(forName: year){
                yearNode = yNode
            }else{
                yearNode = PeriodNodeImplementation(name: year, from: d.date!.startOfYear(), to: d.date!.endOfYear(), isRoot: true)
                yearNodes.append(yearNode)
            }
            
            if let mNode = yearNode.child(forName: month){
                monthNode = mNode
            }else{
                monthNode = PeriodNodeImplementation(name: d.date!.monthAsString(), from: d.date!.startOfMonth(), to: d.date!.endOfMonth(), isRoot: false)
                yearNode.add(child: monthNode)
            }
            monthNode.add(child: d)
        }
        
    }
    
}
