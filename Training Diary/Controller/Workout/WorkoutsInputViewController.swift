//
//  WorkoutsInputViewController.swift
//  Training Diary
//
//  Created by Steven Lord on 05/03/2018.
//  Copyright © 2018 Steven Lord. All rights reserved.
//

import Cocoa

class WorkoutsInputViewController: TrainingDiaryViewController, NSComboBoxDataSource, NSTableViewDelegate{
    
    private var currentWorkout: Workout?
    
    @IBAction func add(_ sender: Any) {
        if let wsvc = parent as? WorkoutSplitViewController{
            if let wac = wsvc.workoutArrayController{
                wac.add(sender)
            }
        }
    }
    
    @IBAction func remove(_ sender: Any) {
        if let wsvc = parent as? WorkoutSplitViewController{
            if let wac = wsvc.workoutArrayController{
                wac.remove(sender)
            }
        }
    }
    
    //MARK: - Property Observing
    
//    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
////        if let key = keyPath{
////            if let w = object as? Workout{
////                switch key{
////                case WorkoutProperty.equipmentName.rawValue:
////                    if let td = trainingDiary{
////                        if let workout = currentWorkout{
////                            if let e = workout.equipmentName{
////                                if let equipment = td.equipment(forActivity: w.activityString!, andName: e){
////                                    workout.equipment = equipment
////                                }
////                            }
////                        }
////                    }
////                case WorkoutProperty.activityString.rawValue:
////                    if let td = w.day?.trainingDiary{
////                        w.activity = td.activity(forString: w.activityString!)
////                    }else{
////                        print("Failed as couldn't connect to training diary")
////                    }
////
////                case WorkoutProperty.activityTypeString.rawValue:
////                    if let td = w.day?.trainingDiary{
////                        if let ats = w.activityTypeString{
////                            w.activityType = td.activityType(forActivity: w.activityString!, andType: ats)
////                        }
////                    }else{
////                        print("Failed as couldn't connect to training diary")
////                    }
////
////                default:
////                    print("!! Didn't thinkk I set an observer for \(String(describing: keyPath))")
////                }
////            }
////        }
//    }
    
    //MARK: - NSTableViewDelegate
//    func tableViewSelectionDidChange(_ notification: Notification) {
////        if let workout = currentWorkout{
////            workout.removeObserver(self, forKeyPath: WorkoutProperty.equipmentName.rawValue)
////            workout.removeObserver(self, forKeyPath: WorkoutProperty.activityString.rawValue)
////            workout.removeObserver(self, forKeyPath: WorkoutProperty.activityTypeString.rawValue)
////        }
////        if let wsvc = parent as? WorkoutSplitViewController{
////            if let wac = wsvc.workoutArrayController{
////                let workouts = wac.selectedObjects as! [Workout]
////                if workouts.count == 1{
////                    currentWorkout = workouts[0]
////                    workouts[0].addObserver(self, forKeyPath: WorkoutProperty.equipmentName.rawValue, options: NSKeyValueObservingOptions.new, context: nil)
////                    workouts[0].addObserver(self, forKeyPath: WorkoutProperty.activityString.rawValue, options: NSKeyValueObservingOptions.new, context: nil)
////                    workouts[0].addObserver(self, forKeyPath: WorkoutProperty.activityTypeString.rawValue, options: NSKeyValueObservingOptions.new, context: nil)
////                }else{
////                    currentWorkout = nil
////                }
////            }
////        }
//
//    }
    
    //MARK: - NSComboBoxDataSource
    func comboBox(_ comboBox: NSComboBox, objectValueForItemAt index: Int) -> Any? {
        if let identifier = comboBox.identifier{
            switch identifier.rawValue{
            case "WorkoutEquipmentComboBox":
                if let a = selectedWorkout()?.activityString{
                    let types = trainingDiary!.validEquipment(forActivityString: a).map({$0.name})
                    if index < types.count{
                        return types[index]
                    }
                }
            case "WorkoutActivityComboBox":
                let activities = trainingDiary!.activitiesArray().map({$0.name})
                if index < activities.count{
                    return activities[index]
                }
            case "WorkoutActivityTypeComboBox":
                if let a = selectedWorkout()?.activityString{
                    let types = trainingDiary!.validActivityTypes(forActivityString: a).map({$0.name})
                    if index < types.count{
                        return types[index]
                    }
                }
            default:
                print("What combo box is this \(identifier.rawValue) which I'm (DaysViewController) a data source for? ")
            }
        }
        return nil
    }
    
    func numberOfItems(in comboBox: NSComboBox) -> Int {
        if let identifier = comboBox.identifier{
            switch identifier.rawValue{
            case "WorkoutEquipmentComboBox":
                return trainingDiary!.activeBikes().count
            case "WorkoutActivityComboBox":
                return trainingDiary!.activitiesArray().count
            case "WorkoutActivityTypeComboBox":
                if let a = selectedWorkout()?.activityString{
                    return trainingDiary!.validActivityTypes(forActivityString: a).count
                }
            default:
                return 0
            }
        }
        return 0
    }
    
    private func selectedWorkout() -> Workout?{
        if let wsvc = parent as? WorkoutSplitViewController{
            if let wac = wsvc.workoutArrayController{
                if let selection = wac.selectedObjects{
                    if selection.count > 0{
                        return selection[0] as? Workout
                    }
                }
            }
        }
        return nil
    }
    
}
