//
//  EddingtonSplitViewController.swift
//  Training Diary
//
//  Created by Steven Lord on 08/03/2018.
//  Copyright © 2018 Steven Lord. All rights reserved.
//

import Cocoa

class EddingtonSplitViewController: TrainingDiarySplitViewController {

    
    @IBOutlet var eddingtonNumberAC: NSArrayController!
    
    @IBOutlet var annualHistoryAC: NSArrayController!
    @IBOutlet var historyAC: NSArrayController!
    @IBOutlet var contributorsAC: NSArrayController!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let eddNumAC = eddingtonNumberAC{
            eddNumAC.addObserver(self, forKeyPath: "selection", options: .new, context: nil)
        }

    }
    
    //MARK: - value observing
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        switch keyPath!{
        case "selection":
            if let controller = getGraphView(){
                controller.updateGraph()
            }
        default:
            print("why am I observing \(String(describing: keyPath))")
        }
    }
    
    
    
    private func getGraphView() -> EddingtonGraphViewController?{
        for child in children{
            for grandChild in child.children{
                if let result = grandChild as? EddingtonGraphViewController{
                    return result
                }
            }
        }
        return nil
    }
    
  /*
    private func findGraphVC(_ vcs: [NSViewController]) -> EddingtonGraphViewController?{

        for v in vcs{
            if let controller = v as? EddingtonGraphViewController{
                return controller
            }else if v.childViewControllers.count > 0{
                if let result = findGraphVC(v.childViewControllers){
                    return result
                }
            }else{
                return nil
            }
        }
        
        return nil
        
    }
 */
}
