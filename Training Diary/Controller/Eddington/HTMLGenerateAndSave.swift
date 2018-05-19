//
//  HTMLGenerateAndSave.swift
//  Training Diary
//
//  Created by Steven Lord on 19/05/2018.
//  Copyright © 2018 Steven Lord. All rights reserved.
//

import Cocoa

class HTMLGenerateAndSave{
    
    
    func saveAsHTML(_ eddingtonNumbers: [LTDEddingtonNumber], fromView view: NSView) {
        var html: String = ""
        
        if let tableStart = Bundle.main.url(forResource: "tableStart", withExtension: "txt"){
            do{
                let contents = try String.init(contentsOf: tableStart)
                html += contents
            }catch{
                print("tableStart.txt not loaded")
            }
        }
        var count: Int = 0
        for e in eddingtonNumbers.sorted(by: {$0.code < $1.code}){
            for l in e.getLeaves().sorted(by: {$0.code < $1.code}){
                count += 1
                html += "<tr>\n"
                html += "<td>\(l.dayType!)</td>\n"
                html += "<td>\(l.activity!)</td>\n"
                html += "<td>\(l.equipment!)</td>\n"
                html += "<td>\(l.activityType!)</td>\n"
                html += "<td>\(l.period!)</td>\n"
                html += "<td>\(l.unit!)</td>\n"
                html += "<td>\(l.value)</td>\n"
                html += "<td>\(l.plusOne)</td>\n"
                html += "</tr>"
            }
        }
        
        
        if let tableEnd = Bundle.main.url(forResource: "tableEnd", withExtension: "txt"){
            do{
                let contents = try String.init(contentsOf: tableEnd)
                html += contents
            }catch{
                print("tableEnd.txt not loaded")
            }
        }
        
        guard let window = view.window else {
            print("Failed to get window")
            return
        }
        
        let panel = NSSavePanel()
        panel.directoryURL = FileManager.default.homeDirectoryForCurrentUser
        panel.allowedFileTypes = ["html"]
        panel.canCreateDirectories = true
        panel.nameFieldStringValue = "ltdEddingtonNumbers.html"
        
        panel.beginSheetModal(for: window) {(result) in
            if result.rawValue == NSFileHandlingPanelOKButton,
                let url = panel.url{
                
                do{
                    try html.write(to: url, atomically: true, encoding: .utf8)
                }catch{
                    print("Unable to save HTML")
                    print(error)
                }
            }
        }
        
    }
    
}
