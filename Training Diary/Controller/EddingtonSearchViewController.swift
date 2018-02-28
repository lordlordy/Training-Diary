//
//  EddingtonSearchViewController.swift
//  Training Diary
//
//  Created by Steven Lord on 27/02/2018.
//  Copyright © 2018 Steven Lord. All rights reserved.
//

import Cocoa

class EddingtonSearchViewController: NSViewController, TrainingDiaryViewController {
    
    @objc dynamic var trainingDiary: TrainingDiary?
    @IBOutlet weak var predicateEditor: NSPredicateEditor!
    @IBOutlet var eddingtonNumberAC: NSArrayController!
    
    @IBAction func testButton(_ sender: Any) {
        saveFilteredHTML()
    }
    
    func set(trainingDiary td: TrainingDiary) {
        trainingDiary = td
    }
    

    override func viewDidLoad(){
        super.viewDidLoad()
        
        if let editor = predicateEditor{
            editor.addRow(nil)
            
            var stringExpressions: [NSExpression] = []
            var stringOperators: [NSNumber] = []
            for p in LTDEddingtonNumberProperty.StringProperties{
                stringExpressions.append(NSExpression(forKeyPath: p.rawValue))
            }
            stringOperators.append(NSNumber(value:NSComparisonPredicate.Operator.contains.rawValue))
            stringOperators.append(NSNumber(value:NSComparisonPredicate.Operator.equalTo.rawValue))
            stringOperators.append(NSNumber(value:NSComparisonPredicate.Operator.notEqualTo.rawValue))

            let stringTemplate = NSPredicateEditorRowTemplate.init(leftExpressions: stringExpressions, rightExpressionAttributeType: NSAttributeType.stringAttributeType, modifier: NSComparisonPredicate.Modifier.direct, operators: stringOperators, options: Int(NSComparisonPredicate.Options.caseInsensitive.rawValue))
            
            let booleanExpressions: [NSExpression] = [NSExpression(forKeyPath: LTDEddingtonNumberProperty.isWeekDay.rawValue)]
            var booleanOperators: [NSNumber] = []
            booleanOperators.append(NSNumber(value:NSComparisonPredicate.Operator.equalTo.rawValue))
            booleanOperators.append(NSNumber(value:NSComparisonPredicate.Operator.notEqualTo.rawValue))
            
            let booleanTemplate = NSPredicateEditorRowTemplate.init(leftExpressions: booleanExpressions, rightExpressionAttributeType: NSAttributeType.booleanAttributeType, modifier: NSComparisonPredicate.Modifier.direct, operators: booleanOperators, options: Int(NSComparisonPredicate.Options.caseInsensitive.rawValue))
            
            let compoundTemplate = NSPredicateEditorRowTemplate.init(compoundTypes: [1])
            print(compoundTemplate)
           
            editor.rowTemplates.append(contentsOf: [stringTemplate, booleanTemplate, compoundTemplate])

        }
        
    }

    
    private func saveFilteredHTML(){
        var html: String = """
            <!DOCTYPE html>
            <html>
            <head>
            <meta name="viewport" content="width=device-width, initial-scale=1">
            <style>
            * {
            box-sizing: border-box;
            }

            #edNumTable {
            border-collapse: collapse;
            border: 1px solid #ddd;
            font-size: 12px;
            }

            #edNumTable th, #edNumTable td {
            border: 1px solid #ddd;
            text-align: left;
            padding: 2px;
            }

            #edNumTable tr {
            border-bottom: 1px solid #ddd;
            }

            #edNumTable tr.header, #edNumTable tr:hover {
            background-color: #f1f1f1;
            }
            </style>
            </head>
            <body>
            <table id="edNumTable">
            <tr class="Header">
            <th >Code</th>
            <th >#</th>
            <th >+1</th>
            <th >Maturity</th>
            </tr>
            """
        

        let formatter = NumberFormatter.init()
        formatter.format = "0.00"
        
        if let edNumSet = eddingtonNumberAC.arrangedObjects as? [LTDEddingtonNumber]{
            for e in edNumSet{
                let maturity = formatter.string(from: NSNumber(value: e.maturity)) ?? ""
                html += "<tr>\n"
                html += "<td>\(e.code)</td>\n"
                html += "<td>\(e.value)</td>\n"
                html += "<td>\(e.plusOne)</td>\n"
                html += "<td>\(maturity)</td>\n"
                html += "</tr>"
            }
        }
        
        html += "</table>"
        html += "</body>"
        html += "</html>"


        
        let homeDir = FileManager.default.homeDirectoryForCurrentUser
        let saveFileName = homeDir.appendingPathComponent("selectedLTDEddingtonNumbers.html")
        do{
            try html.write(to: saveFileName, atomically: false, encoding: .ascii)
        }catch let error as NSError{
            print(error)
        }
    }
    
}
