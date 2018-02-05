//
//  AdminViewController.swift
//  Training Diary
//
//  Created by Steven Lord on 25/01/2018.
//  Copyright © 2018 Steven Lord. All rights reserved.
//

import Cocoa

class AdminViewController: NSViewController, TrainingDiaryViewController, NSComboBoxDataSource {
  
    @objc dynamic var trainingDiary: TrainingDiary?
    var mainViewController: ViewController?
    
//    @objc dynamic var filterPredicate: NSPredicate?
//    @IBOutlet weak var edNumOutlineView: NSOutlineView!
  //  @IBOutlet var treeController: NSTreeController!
    
    @IBOutlet weak var predicateEditor: NSPredicateEditor!
    
 //   @objc dynamic var eddingtonNumberLevels: [EdLevel] = []

    //MARK: - IBActions
    
    @IBAction func adhoc(_ sender: Any){
 /*       let ltdEd = trainingDiary!.lTDEdNumbers!.allObjects as! [LTDEdNum]
        //remove existing entities
        CoreDataStackSingleton.shared.deleteAll(entity: ENTITY.LTDEddingtonNumber, forTrainingDiary: trainingDiary!)
        for l in ltdEd.sorted(by: {$0.code < $1.code}){
            let activityLevel = level(forString: l.activity!, inLevels: &eddingtonNumberLevels)
            let equipLevel = level(forString: l.equipment!, inLevels: &activityLevel.children)
            let typeLevel = level(forString: l.activityType!, inLevels: &equipLevel.children)
            let unitLevel = level(forString: l.unit!, inLevels: &typeLevel.children)
            let periodLevel = level(forString: l.period!, inLevels: &unitLevel.children)
            periodLevel.edNumber = l
 
            //Core data approach
                //create levels
            let aLevel = trainingDiary!.getLTDEddingtonNumber(forActivity: l.activity!)
            aLevel.activity = l.activity
            
            let eLevel = aLevel.getChild(forName: l.equipment!)
            eLevel.activityType = l.activity
            eLevel.equipment = l.equipment
            
            let tLevel = eLevel.getChild(forName: l.activityType!)
            tLevel.activity = l.activity
            tLevel.equipment = l.equipment
            tLevel.activityType = l.activityType
            
            let uLevel = tLevel.getChild(forName: l.unit!)
            uLevel.activity = l.activity
            uLevel.equipment = l.equipment
            uLevel.activityType = l.activityType
            uLevel.unit = l.unit
            
            let pLevel = uLevel.getChild(forName: l.period!)
            pLevel.activity = l.activity
            pLevel.equipment = l.equipment
            pLevel.activityType = l.activityType
            pLevel.unit = l.unit
            pLevel.period = l.period
            pLevel.value = l.value
            pLevel.plusOne = l.plusOne
            
            
        }
        
 */
        
 /*
        var count: Int = 0
        //activity
        for i1 in trainingDiary!.ltdEddingtonNumbers!.allObjects as! [LTDEddingtonNumber]{
            count += 1
            let a = i1.name
        
            print("\(count):\(a!) parent: \(i1.parent?.name)")
            //equip
            for i2 in i1.children!.allObjects as! [LTDEddingtonNumber]{
                count += 1
                let e = i2.name
                print("\(count):\(a!):\(e!) parent: \(i2.parent?.name)")
                //type
                for i3 in i2.children!.allObjects as! [LTDEddingtonNumber]{
                    count += 1
                    let at = i3.name
                    print("\(count):\(a!):\(e!):\(at!) parent: \(i3.parent?.name)")
                    // unit
                    for i4 in i3.children!.allObjects as! [LTDEddingtonNumber]{
                        count += 1
                        let u = i4.name
                        print("\(count):\(a!):\(e!):\(at!):\(u!) parent: \(i4.parent?.name)")
                        // period
                        for i5 in i4.children!.allObjects as! [LTDEddingtonNumber]{
                            count += 1
                            let p = i5.name
                            print("\(count):\(a!):\(e!):\(at!):\(u!):\(p!) parent: \(i5.parent?.name)")
                        }
                    }
                }
            }
        }
        
  */


 /*       if let tc = treeController{
            tc.content = eddingtonNumberLevels
            tc.rearrangeObjects()
          //  tc.reloadData()
        }
  */
/*        if let enov = edNumOutlineView{
            enov.needsDisplay = true
        }
  */
    //    print("Training diary has \(trainingDiary!.ltdEddingtonNumbers!.count) LTDEddingtonNUmbers")
        
    }
    
 /*   private func level(forString s: String, inLevels levels: inout [EdLevel]) -> EdLevel{
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
    */
    @IBAction func uniqueActivities(_ sender: Any){
        let results = trainingDiary!.uniqueActivityTypePairs()
        for r in results{
            print(r)
        }
    }
    
    @IBAction func recalcTSB(_ sender: Any) {
        DispatchQueue.global(qos: .userInitiated).async {

            let start = Date()
            let numberOfActivities = Double(self.trainingDiary!.activitiesArray().count)
            var i = 0.0
            
            DispatchQueue.main.async {
                if let mvc = self.mainViewController{
                    mvc.mainProgressBar!.doubleValue = 0.0
                    mvc.mainStatusField!.stringValue = "Starting TSB calc..."
                }
            }
            
            for a in self.trainingDiary!.activitiesArray(){
       
                let s = Date()
                self.trainingDiary!.calcTSB(forActivity: a, fromDate: self.trainingDiary!.firstDayOfDiary)
                
                DispatchQueue.main.async {
                    i += 1.0
                    if let mvc = self.mainViewController{
                        mvc.mainStatusField!.stringValue = "\(a.name!) TSB calculated in \(Int(Date().timeIntervalSince(s)))s"
                        mvc.mainProgressBar!.doubleValue = i * 100.0 / numberOfActivities
                    }
                }
            }
            
            DispatchQueue.main.async {
                if let mvc = self.mainViewController{
                    mvc.mainStatusField.stringValue = "TSB Calc completed in \(Int(Date().timeIntervalSince(start)))s"
                }
            }

        }
    }
    @IBAction func printEntityCounts(_ sender: Any) {
        CoreDataStackSingleton.shared.printEntityCounts(forDiary: trainingDiary!)
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
                            print(w.equipmentName!)
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
    
    //MARK: - TrainingDiaryViewController implentation
    
    func set(trainingDiary td: TrainingDiary) {
        trainingDiary = td
    }
    
    //MARK: - NSComboBoxDataSource implementation  TSBTableActivityCB
    func comboBox(_ comboBox: NSComboBox, objectValueForItemAt index: Int) -> Any? {
        if let identifier = comboBox.identifier{
            switch identifier.rawValue{

            case "TSBTableActivityCB":
                let activities = trainingDiary!.activitiesArray().map({$0.name})
                if index < activities.count{
                    return activities[index]
                }
            default:
                print("What combo box is this \(identifier.rawValue) which I'm (AdminViewController) a data source for? ")
            }
        }
        return nil
    }
    
    func numberOfItems(in comboBox: NSComboBox) -> Int {
        if let identifier = comboBox.identifier{
            switch identifier.rawValue{
            case "TSBTableActivityCB":
                return trainingDiary!.activitiesArray().count
            default:
                return 0
            }
        }
        return 0
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
  //      if let tc = treeController{
    //        tc.childrenKeyPath = "children"
    //    }
        
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
