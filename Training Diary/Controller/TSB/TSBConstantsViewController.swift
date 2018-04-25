//
//  TSBConstantsViewController.swift
//  Training Diary
//
//  Created by Steven Lord on 15/04/2018.
//  Copyright © 2018 Steven Lord. All rights reserved.
//

import Cocoa

class TSBConstantsViewController: TrainingDiaryViewController, NSTableViewDelegate, ReferenceToMainProtocol{
    
    enum GraphType: String{
        case effect, decay, replacement
    }
    
    private var mainViewController: ViewController?
    
    @IBOutlet var activitiesArrayController: NSArrayController!
    @IBOutlet weak var graphTypeComboBox: NSComboBox!
    
    
    @IBAction func graphTypeChange(_ sender: NSComboBox) {
        updateGraph()
    }
    
    @IBAction func recalculateSelection(_ sender: Any) {
        
        DispatchQueue.global(qos: .userInitiated).async {
            
            let start = Date()
            let numberOfActivities = Double(self.selectedActivity().count)
            var i = 0.0
            
            DispatchQueue.main.async {
                if let mvc = self.mainViewController{
                    mvc.mainProgressBar!.doubleValue = 0.0
                    mvc.mainStatusField!.stringValue = "Starting TSB calc..."
                }
            }
            
            for a in self.selectedActivity(){
                
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
    

    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let cb = graphTypeComboBox{
            cb.selectItem(at: 0)
        }
        for a in trainingDiary!.activitiesArray(){
            a.addObserver(self, forKeyPath: ActivityProperty.atlDecay.rawValue, options: .new, context: nil)
            a.addObserver(self, forKeyPath: ActivityProperty.atlImpact.rawValue, options: .new, context: nil)
            a.addObserver(self, forKeyPath: ActivityProperty.ctlDecay.rawValue, options: .new, context: nil)
            a.addObserver(self, forKeyPath: ActivityProperty.ctlImpact.rawValue, options: .new, context: nil)
        }
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        for a in selectedActivity(){
            if let parentVC = parent as? TSBConstantsSplitViewController{
                parentVC.recalculateData(forActivity: a)
            }
        }
    }
    
    
    //MARK: - NSTableViewDelegate
    func tableViewSelectionDidChange(_ notification: Notification) {
        updateGraph()
    }
    
    //MARK: - ReferenceToMainProtocol
    func setMainViewControllerReference(to vc: ViewController){
        mainViewController = vc
    }
    
    private func updateGraph(){
        let selection = selectedActivity()
        if selection.count > 0{
            if let parentVC = parent as? TSBConstantsSplitViewController{
                parentVC.setGraphTo(activity: selection[0], graphType: selectedGraphType())
            }
        }
    }
    
    
    private func selectedActivity() -> [Activity]{
        if let aac = activitiesArrayController{
            if let activities = aac.selectedObjects as? [Activity]{
                return activities
            }
        }
        return []
    }
    
    private func selectedGraphType() -> GraphType{
        if let cb = graphTypeComboBox{
            if cb.stringValue == "Decay" { return GraphType.decay }
            if cb.stringValue == "Replacement TSS" { return GraphType.replacement}
        }
        return GraphType.effect
    }
}
