//
//  HTMLGenerateAndSave.swift
//  Training Diary
//
//  Created by Steven Lord on 19/05/2018.
//  Copyright © 2018 Steven Lord. All rights reserved.
//

import Cocoa

class HTMLGenerateAndSave{
    
    private let documentStart: String = """
                                            <!DOCTYPE html>
                                            <html>
                                        """
    
    private let metaTag: String = """
                                    <meta name="author" content="Steven Thomas Lord">
                                    <meta name="viewport" content="width=device-width, initial-scale=1">
                                    """
    
    func saveAsHTML(_ eddingtonNumbers: [LTDEddingtonNumber], withOpeningParagraph paragraph: String?) {
        var html: String = documentStart
        html += "<head>\n"
        html += metaTag
        
        //table style
        html += "<style>"
        if let tableStyle = Bundle.main.url(forResource: "eddingtonTableStyle", withExtension: "txt"){
            do{
                let contents = try String.init(contentsOf: tableStyle)
                html += contents
            }catch{
                print("eddingtonTableStyle.txt not loaded")
            }
        }
        html += standardTableStyle(forID: "TestTable")
        
        html += "</style>"

        
        //table scripts
        if let tableScripts = Bundle.main.url(forResource: "EddingtonTableScripts", withExtension: "txt"){
            do{
                let contents = try String.init(contentsOf: tableScripts)
                html += contents
            }catch{
                print("eddingtonTableScripts.txt not loaded")
            }
        }
        html += "</head>\n"
        html += "<body>\n"
        
        if let p = paragraph{
            html += "<p>\n"
            html += p
            html += "</p>"
        }
        
        
        if let tableStart = Bundle.main.url(forResource: "tableStart", withExtension: "txt"){
            do{
                let contents = try String.init(contentsOf: tableStart)
                html += contents
            }catch{
                print("tableStart.txt not loaded")
            }
        }
//   //     var count: Int = 0
//        for e in eddingtonNumbers.sorted(by: {$0.code < $1.code}){
//            for l in e.getLeaves().sorted(by: {$0.code < $1.code}){
//           //     count += 1
//                html += "<tr>\n"
//                html += "<td>\(l.dayType!)</td>\n"
//                html += "<td>\(l.activity!)</td>\n"
//                html += "<td>\(l.equipment!)</td>\n"
//                html += "<td>\(l.activityType!)</td>\n"
//                html += "<td>\(l.period!)</td>\n"
//                html += "<td>\(l.unit!)</td>\n"
//                html += "<td>\(l.value)</td>\n"
//                html += "<td>\(l.plusOne)</td>\n"
//                html += "</tr>"
//            }
//        }
//
//        html += "</table>\n"
        
        html += createTable(forObjects: eddingtonNumbers, andProperties: LTDEddingtonNumberProperty.csvProperties.map({$0.rawValue}), tableID: "TestTable")
        
        html += "</body>\n"
        html += "</html>"
        
        if let url = OpenAndSaveDialogues().saveFilePath(suggestedFileName: "ltdEddingtonNumbers", allowFileTypes: ["html"]){
            do{
                try html.write(to: url, atomically: true, encoding: .utf8)
            }catch{
                print("Unable to save HTML")
                print(error)
            }
        }
        
    }
    
    func saveStandardTableHTML(_ eddingtonNumbers: [LTDEddingtonNumber], withOpeningParagraph paragraph: String?) {
        var html: String = documentStart
        html += "<head>\n"
        html += metaTag
        
        //table style
        html += "<style>"
        html += standardTableStyle(forID: "TestTable")
        html += "</style>"
        
        html += "</head>\n"
        html += "<body>\n"
        
        if let p = paragraph{
            html += "<p>\n"
            html += p
            html += "</p>"
        }
        
        html += createTable(forObjects: eddingtonNumbers, andProperties: LTDEddingtonNumberProperty.csvProperties.map({$0.rawValue}), tableID: "TestTable")
        
        html += "</body>\n"
        html += "</html>"
        
        if let url = OpenAndSaveDialogues().saveFilePath(suggestedFileName: "ltdEddingtonNumbers", allowFileTypes: ["html"]){
            do{
                try html.write(to: url, atomically: true, encoding: .utf8)
            }catch{
                print("Unable to save HTML")
                print(error)
            }
        }
        
    }
    
    private func createTable(forObjects objs: [NSObject], andProperties properties: [String], tableID: String) -> String{
        var table: String = """
                            <table id="\(tableID)">\n
                            <tr class="Header">
                            """
        for p in properties{
            table += "<th>\(p)</th>\n"
        }
        table += "</tr>"

        for o in objs{
            table += "<tr>\n"
            for p in properties{
                let v = o.value(forKey: p)!
                table += "<td>\(v)</td>\n"
            }
            table += "</tr>\n"
        }
        
        table += "</table>\n"
        return table
        
    }
    
    private func standardTableStyle(forID: String) -> String{
        return  """
        * {
        box-sizing: border-box;
        }
        #\(forID) {
        border-collapse: collapse;
        width: 100%;
        border: 1px solid #ddd;
        font-size: 12px;
        }
        #\(forID) th, #\(forID) td {
        text-align: left;
        padding: 1px;
        border: 1px solid #ddd;
        }
        
        #\(forID) tr {
        border-bottom: 1px solid #ddd;
        }
        
        #\(forID) tr.header, #\(forID) tr:hover {
        background-color: #f1f1f1;
        }
        """
        
    }
    
}
