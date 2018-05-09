//
//  BucketsViewController.swift
//  Training Diary
//
//  Created by Steven Lord on 07/05/2018.
//  Copyright © 2018 Steven Lord. All rights reserved.
//

import Cocoa

class BucketsViewController: TrainingDiaryViewController, NSTableViewDelegate, NSComboBoxDataSource{
    
    let dailyHoursBuckets: BucketGraphDefinition = BucketGraphDefinition(definition: GraphDefinition.init(name: "Daily Hours", axis: .Primary, type: .Bar, format: GraphFormat.init(fill: true, colour: .green, fillGradientStart: .green, fillGradientEnd: .red, gradientAngle: 90.0, size: 2.0, opacity: 1.0), drawZeroes: true, priority: 1), buckets: BucketDefinition.init(data: DataSeriesDefinition.init(aggregationMethod: .Sum, period: .Day, unit: .Hours), size: 1.0))
    let weeklyHoursBuckets: BucketGraphDefinition = BucketGraphDefinition(definition: GraphDefinition.init(name: "Weekly Hours", axis: .Primary, type: .Bar, format: GraphFormat.init(fill: true, colour: .green, fillGradientStart: .green, fillGradientEnd: .red, gradientAngle: 90.0, size: 2.0, opacity: 1.0), drawZeroes: true, priority: 1), buckets: BucketDefinition.init(data: DataSeriesDefinition.init(aggregationMethod: .Sum, period: .Week, unit: .Hours), size: 5.0))
    let monthlyHoursBuckets: BucketGraphDefinition = BucketGraphDefinition(definition: GraphDefinition.init(name: "Monthly Hours", axis: .Primary, type: .Bar, format: GraphFormat.init(fill: true, colour: .green, fillGradientStart: .green, fillGradientEnd: .red, gradientAngle: 90.0, size: 2.0, opacity: 1.0), drawZeroes: true, priority: 1), buckets: BucketDefinition.init(data: DataSeriesDefinition.init(aggregationMethod: .Sum, period: .Month, unit: .Hours), size: 25.0))
    let dailyKMBuckets: BucketGraphDefinition = BucketGraphDefinition(definition: GraphDefinition.init(name: "Daily KM", axis: .Primary, type: .Bar, format: GraphFormat.init(fill: true, colour: .systemPink, fillGradientStart: .blue, fillGradientEnd: .systemPink, gradientAngle: 90.0, size: 2.0, opacity: 1.0), drawZeroes: true, priority: 1), buckets: BucketDefinition.init(data: DataSeriesDefinition.init(aggregationMethod: .Sum, period: .Day, unit: .KM), size: 10.0))
    let weeklyKMBuckets: BucketGraphDefinition = BucketGraphDefinition(definition: GraphDefinition.init(name: "Weekly KM", axis: .Primary, type: .Bar, format: GraphFormat.init(fill: true, colour: .systemPink, fillGradientStart: .blue, fillGradientEnd: .systemPink, gradientAngle: 90.0, size: 2.0, opacity: 1.0), drawZeroes: true, priority: 1), buckets: BucketDefinition.init(data: DataSeriesDefinition.init(aggregationMethod: .Sum, period: .Week, unit: .KM), size: 50.0))
    let monthlyKMBuckets: BucketGraphDefinition = BucketGraphDefinition(definition: GraphDefinition.init(name: "Monthly KM", axis: .Primary, type: .Bar, format: GraphFormat.init(fill: true, colour: .systemPink, fillGradientStart: .blue, fillGradientEnd: .systemPink, gradientAngle: 90.0, size: 2.0, opacity: 1.0), drawZeroes: true, priority: 1), buckets: BucketDefinition.init(data: DataSeriesDefinition.init(aggregationMethod: .Sum, period: .Month, unit: .KM), size: 100.0))
    
    var standardGraphs: [BucketGraphDefinition]
    
    
    @IBOutlet var graphArrayController: BucketGraphArrayController!
    
    @IBOutlet weak var activityComboBox: NSComboBox!
    
    @IBOutlet weak var backgroundGradientTextField: NSTextField!
    @IBOutlet weak var gradientStepper: NSStepper!
    @IBOutlet weak var startColour: NSColorWell!
    @IBOutlet weak var endColour: NSColorWell!

    @objc dynamic var graphView: GraphView?{
        if let p = parent as? BucketsSplitViewController{
            return p.graphView
        }
        return nil
    }
    
    var graph: BucketGraphDefinition = BucketGraphDefinition()
    var graphs: [BucketGraphDefinition]{
        if let g = graphArrayController?.arrangedObjects as? [BucketGraphDefinition]{
            return g
        }
        return []
    }
    
    private var advanceDateComponent: DateComponents?
    private var retreatDateComponent: DateComponents?
    
    @IBAction func graphPeriodChanged(_ sender: PeriodTextField) {
        advanceDateComponent = sender.getDateComponentsEquivalent()
        retreatDateComponent = sender.getNegativeDateComponentsEquivalent()
        for g in selectedGraphs(){
            if let toDate = g.bucketDefinition.dataSeriesDefinition.to{
                g.bucketDefinition.dataSeriesDefinition.from = Calendar.current.date(byAdding: retreatDateComponent!, to: toDate)
            }
        }
    }
    
    @IBAction func advanceAPeriod(_ sender: Any){
        if let adc = advanceDateComponent{
            moveSelectedGraphs(by: adc)
        }
    }
    
    @IBAction func retreatAPeriod(_ sender: Any){
        if let rdc = retreatDateComponent{
            moveSelectedGraphs(by: rdc)
        }
    }
    
    @IBAction func gradientTextFieldChanged(_ sender: Any) {
        gradientStepper!.doubleValue = backgroundGradientTextField!.doubleValue
    }
    @IBAction func stepperChanged(_ sender: Any) {
        backgroundGradientTextField!.doubleValue = gradientStepper!.doubleValue
    }
    

    
    @IBAction func dayTypeChanged(_ sender: NSComboBox) {
        for g in selectedGraphs(){
            g.bucketDefinition.dataSeriesDefinition.dayTypeString = sender.stringValue
        }
    }
    
    @IBAction func activityChanged(_ sender: NSComboBox) {
        for g in selectedGraphs(){
            g.bucketDefinition.dataSeriesDefinition.activityString = sender.stringValue
        }
    }
    
    @IBAction func activityTypeChanged(_ sender: NSComboBox) {
        for g in selectedGraphs(){
            g.bucketDefinition.dataSeriesDefinition.activityTypeString = sender.stringValue
        }
    }
    
    @IBAction func equipmentChanged(_ sender: NSComboBox) {
        for g in selectedGraphs(){
            g.bucketDefinition.dataSeriesDefinition.equipmentString = sender.stringValue
        }
    }
    
    @IBAction func periodChanged(_ sender: NSComboBox) {
        for g in selectedGraphs(){
            g.bucketDefinition.dataSeriesDefinition.periodString = sender.stringValue
        }
    }
    
    @IBAction func aggregationMethodChanged(_ sender: AggregationMethodComboBox) {
        for g in selectedGraphs(){
            g.bucketDefinition.dataSeriesDefinition.aggregationMethodString = sender.stringValue
        }
    }
    
    @IBAction func unitChanged(_ sender: UnitComboBox) {
        for g in selectedGraphs(){
            g.bucketDefinition.dataSeriesDefinition.unitString = sender.stringValue
        }
    }
    
    required init?(coder: NSCoder) {
        standardGraphs = [dailyHoursBuckets, weeklyHoursBuckets, monthlyHoursBuckets, dailyKMBuckets, weeklyKMBuckets, monthlyKMBuckets]
        super.init(coder: coder)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setTrainingDiaryOnStandardGraphs()
        if let gac = graphArrayController{
            gac.add(contentsOf: standardGraphs)
            gac.setSelectedObjects([dailyHoursBuckets])            
        }
        if let td = trainingDiary{
            for g in graphs{
                g.bucketDefinition.dataSeriesDefinition.from = td.firstDayOfDiary
                g.bucketDefinition.dataSeriesDefinition.to = td.lastDayOfDiary
            }
        }
        

        updateGraphData()
    }
    
    
    override func set(trainingDiary td: TrainingDiary) {
        super.set(trainingDiary: td)
        if let gac = graphArrayController{
            gac.trainingDiary = td
        }
        for g in graphs{
            g.bucketDefinition.dataSeriesDefinition.trainingDiary = td
            g.bucketDefinition.dataSeriesDefinition.from = td.firstDayOfDiary
            g.bucketDefinition.dataSeriesDefinition.to = td.lastDayOfDiary
        }
        updateGraphData()
    }
    
    //MARK: - NSTableViewDelegate
    func tableViewSelectionDidChange(_ notification: Notification) {
        let selectedGraphs = graphArrayController!.selectedObjects as! [BucketGraphDefinition]

        if selectedGraphs.count > 0{
            if let gv = graphView{
                gv.xAxisLabelStrings = selectedGraphs[0].bucketDefinition.bucketLabels
            }
        }
        
        if let p = parent as? BucketsSplitViewController{
            p.setGraphs(to: selectedGraphs.map({$0.graph}))
        }
    
    }
    
    //MARK: - NSComboBoxDataSource
    func comboBox(_ comboBox: NSComboBox, objectValueForItemAt index: Int) -> Any? {
        if let identifier = comboBox.identifier{
            switch identifier.rawValue{
            case "BucketTableEquipmentComboBox":
                if let a = selectedGraph()?.bucketDefinition.dataSeriesDefinition.activityString{
                    let types = trainingDiary!.eddingtonEquipment(forActivityString: a).sorted(by: {$0 < $1})
                    if index < types.count{
                        return types[index]
                    }
                }
            case "BucketEquipmentComboBox":
                    if let a = activityComboBox?.stringValue{
                        let types = trainingDiary!.eddingtonEquipment(forActivityString: a).sorted(by: {$0 < $1})
                        if index < types.count{
                            return types[index]
                        }
                }
            case "BucketTableActivityComboBox", "BucketActivityComboBox":
                let activities = trainingDiary!.activityStrings()
                if index < activities.count{
                    return activities[index]
                }
            case "BucketTableActivityTypeComboBox":
                if let a = selectedGraph()?.bucketDefinition.dataSeriesDefinition.activityString{
                    let types = trainingDiary!.eddingtonActivityTypes(forActivityString: a)
                    if index < types.count{
                        return types[index]
                    }
                }
            case "BucketActivityTypeComboBox":
                if let a = activityComboBox?.stringValue{
                    let types = trainingDiary!.eddingtonActivityTypes(forActivityString: a)
                    if index < types.count{
                        return types[index]
                    }
                }
            case "BucketDayTypeComboBox", "BucketTableDayTypeComboBox":
                let types = trainingDiary!.eddingtonDayTypes().sorted(by: {$0 < $1})
                if index < types.count{
                    return types[index]
                }
            default:
                print("What combo box is this \(identifier.rawValue) which I'm (BucketsViewController) a data source for? ")
            }
        }
        return nil
    }
    
    func numberOfItems(in comboBox: NSComboBox) -> Int {
        if let identifier = comboBox.identifier{
            switch identifier.rawValue{
            case "BucketTableEquipmentComboBox":
                if let a = selectedGraph()?.bucketDefinition.dataSeriesDefinition.activityString{
                    return trainingDiary!.eddingtonEquipment(forActivityString: a).count
                }
            case "BucketEquipmentComboBox":
                if let a = activityComboBox?.stringValue{
                    return trainingDiary!.eddingtonEquipment(forActivityString: a).count
                }
            case "BucketTableActivityComboBox", "BucketActivityComboBox":
                return trainingDiary!.activityStrings().count
            case "BucketTableActivityTypeComboBox":
                if let a = selectedGraph()?.bucketDefinition.dataSeriesDefinition.activityString{
                    return trainingDiary!.eddingtonActivityTypes(forActivityString: a).count
                }
            case "BucketActivityTypeComboBox":
                if let a = activityComboBox?.stringValue{
                    return trainingDiary!.eddingtonActivityTypes(forActivityString: a).count
                }
            case "BucketDayTypeComboBox", "BucketTableDayTypeComboBox":
                return trainingDiary!.eddingtonDayTypes().count
            default:
                return 0
            }
        }
        return 0
    }

    private func selectedGraph() -> BucketGraphDefinition?{
        let selection = selectedGraphs()
        if selection.count > 0{
            return selection[0]
        }
        return nil
    }
    
    private func selectedGraphs() -> [BucketGraphDefinition]{
        return graphArrayController?.selectedObjects as? [BucketGraphDefinition] ?? []
    }
    
    
    private func updateGraphData(){
        for g in graphs{
            g.updateData()
        }
    }
    
    private func moveSelectedGraphs(by dc: DateComponents){
        for g in selectedGraphs(){
            if let toDate = g.bucketDefinition.dataSeriesDefinition.to{
                g.bucketDefinition.dataSeriesDefinition.to = Calendar.current.date(byAdding: dc, to: toDate)
            }
            if let fromDate = g.bucketDefinition.dataSeriesDefinition.from{
                g.bucketDefinition.dataSeriesDefinition.from = Calendar.current.date(byAdding: dc, to: fromDate)
            }
        }
    }
    
    private func setTrainingDiaryOnStandardGraphs(){


        dailyHoursBuckets.bucketDefinition.dataSeriesDefinition.trainingDiary = trainingDiary
        weeklyHoursBuckets.bucketDefinition.dataSeriesDefinition.trainingDiary = trainingDiary
        monthlyHoursBuckets.bucketDefinition.dataSeriesDefinition.trainingDiary = trainingDiary
        dailyKMBuckets.bucketDefinition.dataSeriesDefinition.trainingDiary = trainingDiary
        weeklyKMBuckets.bucketDefinition.dataSeriesDefinition.trainingDiary = trainingDiary
        monthlyKMBuckets.bucketDefinition.dataSeriesDefinition.trainingDiary = trainingDiary
 

    }
    


}
