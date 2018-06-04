//
//  HTMLGenerator.swift
//  Training Diary
//
//  Created by Steven Lord on 24/05/2018.
//  Copyright © 2018 Steven Lord. All rights reserved.
//

import Foundation

class HTMLGenerator{
    
    private let documentStart: String = """
                                            <!DOCTYPE html>
                                            <html>
                                        """
    
    private let metaTag: String = """
                                    <meta name="author" content="Steven Thomas Lord">
                                    <meta name="viewport" content="width=device-width, initial-scale=1">
                                    """
    
    func createStandardTablesHTML(_ objectsAndProperties: [(objects: [NSObject], properties: [TrainingDiaryPropertyProtocol], paragraph: String?)]) -> String{
        
        var html: String = documentStart
        html += "<head>\n"
        html += metaTag
        
        //table style
        html += "<style>"
        html += standardTableStyle(forID: "TestTable")
        html += "</style>"
        
        html += "</head>\n"
        html += "<body>\n"
        
        for item in objectsAndProperties{

            if let p = item.paragraph{
                html += "<p>\n"
                html += p
                html += "</p>"
            }
            
            html += createTable(forObjects: item.objects, andProperties: item.properties, tableID: "TestTable")
        }
        
        html += "</body>\n"
        html += "</html>"
        
        return html

        
        
    }
    
    func createStandardTableHTML(_ objects: [NSObject], withProperties properties: [TrainingDiaryPropertyProtocol], withOpeningParagraph paragraph: String?) -> String{
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
        
        html += createTable(forObjects: objects, andProperties: properties, tableID: "TestTable")
        
        html += "</body>\n"
        html += "</html>"
        
        return html
        
    }
    
    private func createTable(forObjects objs: [NSObject], andProperties properties: [TrainingDiaryPropertyProtocol], tableID: String) -> String{
        var table: String = """
        <table id="\(tableID)">\n
        <tr class="Header">
        """
        for p in properties{
            table += "<th>\(p.displayName())</th>\n"
        }
        table += "</tr>"
        
        for o in objs{
            table += "<tr>\n"
            for p in properties{
                if let v = o.value(forKey: p.propertyName()){
                    if let d = v as? Double{
                        let formatter = NumberFormatter()
                        formatter.format = "#,###.#"
                        table += "<td>\(formatter.string(from: NSNumber(value: d)) ?? "")</td>\n"
                    }else{
                        table += "<td>\(v)</td>\n"
                    }
                }else{
                    table += "<td></td>\n"
                }
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
