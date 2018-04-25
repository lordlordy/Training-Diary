//
//  LTDEddingtonNumberWebViewController.swift
//  Training Diary
//
//  Created by Steven Lord on 16/01/2018.
//  Copyright © 2018 Steven Lord. All rights reserved.
//

import Cocoa
import WebKit

class LTDEddingtonNumberWebViewController:  TrainingDiaryViewController, WKNavigationDelegate {

  //  @objc dynamic var trainingDiary: TrainingDiary?
    @IBOutlet weak var webView: WKWebView!
    
    override func set(trainingDiary td: TrainingDiary){
        super.set(trainingDiary: td)
        if let wv = webView{
            wv.navigationDelegate = self
            wv.loadHTMLString("<html><body><p><a>my site</a></p></body></html>", baseURL: nil)
            
            
            //          if let url = Bundle.main.url(forResource: "filteringTable", withExtension: "html"){
            //            let request = URLRequest(url: url)
            //          print(request)
            //        wv.load(request)
            
            //  }
        }
        
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.


    }
    
}
