//
//  WorkoutsListViewController.swift
//  Training Diary
//
//  Created by Steven Lord on 01/08/2018.
//  Copyright © 2018 Steven Lord. All rights reserved.
//

import Cocoa

class WorkoutsListViewController: TrainingDiaryViewController, NSComboBoxDataSource{
    
    @IBOutlet var workoutsAC: NSArrayController!
    //MARK: - NSComboBoxDataSource
    func comboBox(_ comboBox: NSComboBox, objectValueForItemAt index: Int) -> Any? {
        if let identifier = comboBox.identifier{
            switch identifier.rawValue{
            case "WorkoutEquipmentComboBox":
                if let a = selectedWorkout()?.activityString{
                    let types = trainingDiary!.validEquipment(forActivityString: a)
                    if index < types.count{
                        return types[index].name
                    }
                }
            case "WorkoutActivityComboBox":
                let activities = trainingDiary!.activitiesArray()
                if index < activities.count{
                    return activities[index].name
                }
            case "WorkoutActivityTypeComboBox":
                if let a = selectedWorkout()?.activityString{
                    let types = trainingDiary!.validActivityTypes(forActivityString: a)
                    if index < types.count{
                        return types[index].name
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
                if let a = selectedWorkout()?.activityString{
                    return trainingDiary!.validEquipment(forActivityString: a).count
                }
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
        if let s = workoutsAC.selectedObjects as? [Workout]{
            if s.count > 0{
                return s[0]
            }
        }
        return nil
    }
    
    
}
