//
//  DictionaryItem.swift
//  MDictionary
//
//  Created by liwenqiu on 12/07/2017.
//  Copyright © 2017 liwenqiu. All rights reserved.
//

import Foundation

enum LanguageCode {
    case en
    case zh
}

enum PronunciationDialectCode {
    case cm
    case uk
    case us
}

struct DictionaryItem {
    let version:        String
    let query:          String
    let from:           LanguageCode
    let to:             LanguageCode
    
    let explanations:   [String]
    let pronunciations: [PronunciationDialectCode: String]?
    
    
    func joinedPronunciations() -> String? {
        guard let pronunciations = self.pronunciations else { return nil }
        
        var results = [String]()
        
        if let us = pronunciations[PronunciationDialectCode.us] {
            results.append("美 [\(us)]")
        }
        if let uk = pronunciations[.uk] {
            results.append("英 [\(uk)]")
        }
        if let cm = pronunciations[.cm], results.count == 0 {
            results.append("[\(cm)]")
        }
        
        if results.count > 0 {
            return results.joined(separator: " ")
        }
        
        return nil
    }
    
    
    func joinedExplanations() -> String {
        return self.explanations.joined(separator: "\n")
    }
}

typealias QueryError = (message: String, cause: String?)


protocol QueryService {
    func query(_ word: String, completion: @escaping (DictionaryItem?, QueryError?) -> Void)
}
