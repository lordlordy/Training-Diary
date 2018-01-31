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
//    @objc dynamic var filterPredicate: NSPredicate?
    @IBOutlet weak var edNumOutlineView: NSOutlineView!
    @IBOutlet var treeController: NSTreeController!
    
    @IBOutlet weak var predicateEditor: NSPredicateEditor!
    
    @objc dynamic var eddingtonNumberLevels: [EdLevel] = []

    @IBAction func adhoc(_ sender: Any){
        let ltdEd = trainingDiary!.lTDEdNumbers!.allObjects as! [LTDEdNum]
        for l in ltdEd{
            let activityLevel = level(forString: l.activity!, inLevels: &eddingtonNumberLevels)
            let equipLevel = level(forString: l.equipment!, inLevels: &activityLevel.edChildren)
            let typeLevel = level(forString: l.activityType!, inLevels: &equipLevel.edChildren)
            let unitLevel = level(forString: l.unit!, inLevels: &typeLevel.edChildren)
            _ = level(forString: l.period!, inLevels: &unitLevel.edChildren)
        }
        
        for l in eddingtonNumberLevels{
            print("\(l.name) : \(l.descendantCount)")
        }
        
        if let tc = treeController{
            tc.content = eddingtonNumberLevels
            tc.rearrangeObjects()
          //  tc.reloadData()
        }
        
        if let enov = edNumOutlineView{
            enov.needsDisplay = true
        }
        
        
    }
    
    private func level(forString s: String, inLevels levels: inout [EdLevel]) -> EdLevel{
        var newLevel: EdLevel?
        for l in levels{
            if l.name == s{
                newLevel = l
            }
        }
        if newLevel == nil{
            newLevel = EdLevel(name: s)
            levels.append(newLevel!)
        }
        return newLevel!
    }
    
    @IBAction func uniqueActivities(_ sender: Any){
        let results = trainingDiary!.uniqueActivityTypePairs()
        for r in results{
            print(r)
        }
    }
    
    @IBAction func connectActivities(_ sender: Any){
        // connects up activity objects in to workouts
        
        var activiesConnected: Int = 0
        var activityTypesConnected: Int = 0
        
        for w in trainingDiary!.workouts{
            if w.activity == nil{
                if let td = trainingDiary{
                    if let a = w.activityString{
                        w.activity = td.activity(forString: a)
                        print("Connected activity  for workout \(String(describing: w.day!.date?.dateOnlyShorterString()))")
                        activiesConnected += 1
                    }
                }
            }
            if w.activityType == nil{
                w.activityType = trainingDiary!.activityType(forActivity: w.activityString!, andType: w.activityTypeString!)
                print("Connected activity type for workout \(String(describing: w.day!.date?.dateOnlyShorterString()))")
                activityTypesConnected += 1
            }
        }

        print("\(activiesConnected) workouts connected to activity")
        print("\(activityTypesConnected) workouts connected to activity type")
    }
    
    @IBAction func listMissingConnections(_ sender: Any){
        var missingActivity: Int = 0
        var missingActivityType: Int = 0
        var missingDaySet: Int = 0
        var missingTrainingDiarySet: Int = 0
        
        let days: [Day] = CoreDataStackSingleton.shared.getAllEntities(ofType: ENTITY.Day) as! [Day]
        let workouts: [Workout] = CoreDataStackSingleton.shared.getAllEntities(ofType: ENTITY.Workout) as! [Workout]
        
        for d in days{
            if d.trainingDiary == nil{
                missingTrainingDiarySet += 1
                print("Training diary nil for day \(d.date!.dateOnlyShorterString()).")
                print("DOE")
            }
        }
        
        for w in workouts{
            if w.day == nil{
                missingDaySet += 1
                print("day nil for workout \(String(describing: w.activityString)):\(String(describing: w.activityTypeString)) ")
                
            }else{
                
                if w.activity == nil{
                    missingActivity += 1
                    print("activity nil for workout \(String(describing: w.activityString)) - \(w.day!.date!.dateOnlyShorterString())")
                }
                if w.activityType == nil{
                    missingActivityType += 1
                    print("activity nil for workout \(String(describing: w.activityTypeString)) - \(w.day!.date!.dateOnlyShorterString())")
                }
                if w.activityString == nil{ print("Workout is missing activity string \(w.day!.date!.dateOnlyShorterString())") }
                if w.activityTypeString == nil{ print("Workout is missing activity string \(w.day!.date!.dateOnlyShorterString())") }
            }
        }
        print("Workouts missing activity: \(missingActivity)")
        print("Workouts missing activity type: \(missingActivityType)")
        print("Workouts missing day: \(missingDaySet)")
        print("Days missing training diary: \(missingTrainingDiarySet)")
    }
    
    @IBAction func deleleteEntitiesWithMissingConnections(_ sender: Any){
        var missingDaySet: Int = 0
        var missingTrainingDiarySet: Int = 0
        
        let days: [Day] = CoreDataStackSingleton.shared.getAllEntities(ofType: ENTITY.Day) as! [Day]
        let workouts: [Workout] = CoreDataStackSingleton.shared.getAllEntities(ofType: ENTITY.Workout) as! [Workout]
        
        for d in days{
            if d.trainingDiary == nil{
                missingTrainingDiarySet += 1
                print("Training diary nil for day \(d.date!.dateOnlyShorterString()). Removing...")
                CoreDataStackSingleton.shared.delete(entity: d)
                print("DONE")
            }
        }
        
        for w in workouts{
            if w.day == nil{
                missingDaySet += 1
                print("day nil for workout \(String(describing: w.activityString)):\(String(describing: w.activityTypeString)) ... ")
                CoreDataStackSingleton.shared.delete(entity: w)
                print("DONE")
                
            }
            
        }
    }
    
    @IBAction func printUniqueBikeNames(_ sender: Any){
        var i: Int = 0
        if let td = trainingDiary{
            print(td.uniqueBikeNames())
            for w in td.workouts{
                if w.activity?.name == FixedActivity.Bike.rawValue{
                    if w.equipment == nil{
                        print("Equipment not set for bike workout \(String(describing: w.day?.date?.dateOnlyShorterString()))")
                        i += 1
                    }
                    if w.equipmentName == nil{
                        print("setting equipment name for \(String(describing: w.day?.date?.dateOnlyShorterString())) to...")
                        if let e = w.equipment{
                            w.equipmentName = e.name
                            print(w.equipmentName)
                        }else{
                            print("FAILED TO SET")
                        }
                        
                    }
                }
            }
        }
        print("\(i) workouts missing equipment (ie bike) set")
        
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
