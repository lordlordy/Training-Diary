//
//  PeriodTextField.swift
//  Training Diary
//
//  Created by Steven Lord on 19/01/2018.
//  Copyright © 2018 Steven Lord. All rights reserved.
//

import Cocoa

class PeriodTextField: NSTextField {

    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)

        // Drawing code here.
    }
    
    func getDateComponentsEquivalent() -> DateComponents?{
        var number: String = ""
        var period: String = ""
        var dc: DateComponents?
        parseLoop: for c in stringValue{
            switch c{
            case "0","1","2","3","4","5","6","7","8","9":
                number += String(c)
            case "d":
                period += String(c)
                dc = DateComponents(day: Int(number))
            case "m":
                period += String(c)
                dc = DateComponents(month: Int(number))
            case "y":
                period += String(c)
                dc = DateComponents(year: Int(number))
                break parseLoop
            default:
                //invalid data
                number = ""
                period = ""
                break parseLoop
            }
        }
        stringValue = number + period
        return dc
    }
    
    func getNegativeDateComponentsEquivalent() -> DateComponents?{
        var number: String = ""
        var period: String = ""
        var dc: DateComponents?
        parseLoop: for c in stringValue{
            switch c{
            case "0","1","2","3","4","5","6","7","8","9":
                number += String(c)
            case "d":
                period += String(c)
                dc = DateComponents(day: -1*Int(number)!)
            case "m":
                period += String(c)
                dc = DateComponents(month: -1*Int(number)!)
            case "y":
                period += String(c)
                dc = DateComponents(year: -1*Int(number)!)
                break parseLoop
            default:
                //invalid data
                number = ""
                period = ""
                break parseLoop
            }
        }
        stringValue = number + period
        return dc
    }
    
}
