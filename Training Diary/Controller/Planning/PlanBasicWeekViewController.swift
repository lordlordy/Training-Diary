//
//  PlanBasicWeekViewController.swift
//  Training Diary
//
//  Created by Steven Lord on 21/04/2018.
//  Copyright © 2018 Steven Lord. All rights reserved.
//

import Cocoa

class PlanBasicWeekViewController: TrainingDiaryViewController{
    
    @IBOutlet var comments: NSTextView!
    @IBOutlet weak var swim: NSTextField!
    @IBOutlet weak var bike: NSTextField!
    @IBOutlet weak var run: NSTextField!
    @IBOutlet weak var total: NSTextField!
    
    private let datePickerView = NSView.init(frame: NSRect(x:0,y:0, width: 300  , height: 100))
    private let fromDP = NSDatePicker.init(frame: NSRect(x: 50, y: 25, width: 120, height: 24))
    private let toDP = NSDatePicker.init(frame: NSRect(x: 50, y: 0, width: 120, height: 24))
    private let fromTF = NSTextField(frame: NSRect(x: 0, y: 25, width: 50, height: 24))
    private let toTF = NSTextField(frame: NSRect(x: 0, y: 0, width: 50, height: 24))
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        fromDP.datePickerElements = .yearMonthDayDatePickerElementFlag
        fromDP.datePickerStyle = .textFieldAndStepperDatePickerStyle
        
        toDP.datePickerElements = .yearMonthDayDatePickerElementFlag
        toDP.datePickerStyle = .textFieldAndStepperDatePickerStyle

        fromTF.stringValue = "From:"
        fromTF.alignment = .right
        fromTF.isEditable = false
        fromTF.backgroundColor = .windowBackgroundColor
       
        toTF.stringValue = "To:"
        toTF.alignment = .right
        toTF.isEditable = false
        toTF.backgroundColor = .windowBackgroundColor
        
        datePickerView.addSubview(fromTF)
        datePickerView.addSubview(fromDP)
        datePickerView.addSubview(toTF)
        datePickerView.addSubview(toDP)

    }
    
    @IBAction func createPlan(_ sender: Any) {
        
        if let pscv = parent?.parent as? PlanningSplitViewController{
            pscv.createPlan()
        }
        
    }

    
    @IBAction func deriveBasicWeekFrom(_ sender: Any) {
        let msg = NSAlert()
        let _ = msg.addButton(withTitle: "OK")      // 1st button
        let _ = msg.addButton(withTitle: "Cancel")  // 2nd button
        msg.messageText = "Caclculate Basic Week"
        msg.informativeText = "Input period to calculate average TSS each day to create basic week from"
        
        msg.accessoryView = datePickerView
        let response: NSApplication.ModalResponse = msg.runModal()
        
        if (response == NSApplication.ModalResponse.alertFirstButtonReturn) {
            print("OK")
            print("From: \(fromDP.dateValue)")
            print("To: \(toDP.dateValue)")
            let averages = averageTTS(from: fromDP.dateValue, to: toDP.dateValue)
            if let vc = parent?.parent as? PlanningSplitViewController{
                for d in vc.basicWeekDays(){
                    d.swimTSS = averages[d.name!]?.swim ?? 0.0
                    d.bikeTSS = averages[d.name!]?.bike ?? 0.0
                    d.runTSS = averages[d.name!]?.run ?? 0.0
                    print(d)
                }
            }
        
        } else {
            print("Cancel")
        }
    }
    

    private func averageTTS(from: Date, to: Date) -> [String:(swim: Double, bike: Double, run: Double)]{
        guard let td = trainingDiary else { return [:] }
        
        let includedDays: [Day] = td.daysArray().filter({$0.date! >= from.startOfDay() && $0.date! <= to.endOfDay()})
        
        var dict: [String: (swim: Double, bike: Double, run: Double)] = [:]
        var dictCount: [String: Int] = [:]
        
        for d in includedDays{
            let dayOfWeek = d.date!.dayOfWeekName()
            let runningTotal: (swim: Double, bike: Double, run: Double) = dict[dayOfWeek] ?? (0.0,0.0,0.0)
            dictCount[dayOfWeek] = (dictCount[dayOfWeek] ?? 0) + 1
            dict[dayOfWeek] = (runningTotal.swim + d.swimTSS, runningTotal.bike + d.bikeTSS, runningTotal.run + d.runTSS)
        }
        
        var result: [String: (swim: Double, bike: Double, run: Double)] = [:]
        for d in dict{
            let count: Double = Double(dictCount[d.key] ?? 1)
            result[d.key] = (d.value.swim / count, d.value.bike / count, d.value.run / count)
        }
        
        return result
        
    }
    
}
