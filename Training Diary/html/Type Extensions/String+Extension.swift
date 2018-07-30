//
//  String+Extension.swift
//  Training Diary
//
//  Created by Steven Lord on 02/11/2017.
//  Copyright © 2017 Steven Lord. All rights reserved.
//

import Foundation

extension String {
    func removeWhitespaces() -> String {
        return components(separatedBy: .whitespaces).joined()
    }
}
