//
//  StringExtension.swift
//  Unsplasher
//
//  Created by Adrián Bouza Correa on 23/02/2018.
//  Copyright © 2018 adboco. All rights reserved.
//

import Foundation

extension String {
    
    func matches(in text: String) -> [String] {
        do {
            let regex = try NSRegularExpression(pattern: self)
            let results = regex.matches(in: text, range: NSRange(text.startIndex..., in: text))
            return results.flatMap {
                String(text[Range($0.range, in: text)!])
            }
        } catch let error {
            print("Invalid regex: \(error.localizedDescription)")
            return []
        }
    }
    
}
