//
//  DaysSplitViewController.swift
//  Training Diary
//
//  Created by Steven Lord on 05/03/2018.
//  Copyright © 2018 Steven Lord. All rights reserved.
//

import Cocoa

class DaysSplitViewController: TrainingDiarySplitViewController{
    
    @IBOutlet var daysArrayController: DaysArrayController!
    
    @objc func copy(_ sender: Any){
        print("copy called")
        if let selectedDays = daysArrayController?.selectedObjects as? [Day] {
            var pasteTest: String = ""
            
            //set up headers
            for p in DayProperty.stringProperties{
                pasteTest += "\(p.rawValue)\t"
            }
            for p in DayProperty.doubleProperties{
                pasteTest += "\(p.rawValue)\t"
            }
            for p in DayProperty.intProperties{
                pasteTest += "\(p.rawValue)\t"
            }
            pasteTest += "\n"

            
            for day in selectedDays{
                for p in DayProperty.stringProperties{
                    if let value = day.value(forKey: p.rawValue) as? String{
                        pasteTest += value
                    }
                    pasteTest += "\t"
                }
                for p in DayProperty.doubleProperties{
                    if let value = day.value(forKey: p.rawValue) as? Double{
                        pasteTest += String(value)
                    }
                    pasteTest += "\t"
                }
                for p in DayProperty.intProperties{
                    if let value = day.value(forKey: p.rawValue) as? Int{
                        pasteTest += String(value)
                    }
                    pasteTest += "\t"
                }
                pasteTest += "\n"
            }
            
            
            
            let item = NSPasteboardItem(pasteboardPropertyList: pasteTest  , ofType: .string)
            NSPasteboard.general.declareTypes([.string], owner: nil)
            NSPasteboard.general.writeObjects([item!])
        }
    }
    
    override func set(trainingDiary td: TrainingDiary){
        super.set(trainingDiary: td)
        if let dac = daysArrayController{
            dac.trainingDiary = td
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        daysArrayController.filterPredicate = NSPredicate(format: "date >= %@ AND date <= %@", argumentArray: [Date().addDays(numberOfDays: -90),Date().addDays(numberOfDays: 10)])
    }
    
}
