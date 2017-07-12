//
//  YouDaoService.swift
//  MDictionary
//
//  Created by liwenqiu on 10/07/2017.
//  Copyright © 2017 liwenqiu. All rights reserved.
//

import Foundation


class YouDaoService: QueryService {
    
    let defaultSession = URLSession(configuration: .default)
    var dataTask: URLSessionTask?
    
    
    
    func query(_ word: String, completion:  @escaping (DictionaryItem?, QueryError?) -> Void) {
        
        guard var urlComponents = URLComponents(string: "https://openapi.youdao.com/api") else { return }
        
        dataTask?.cancel()
        
        let from = "en"
        let to = "zh_CHS"
        let appKey = "558dbff32a346334"
        let salt = "2"
        let sign = (appKey + word + salt + "BuXCCS1wbmD518cS7atAL1bl3jCwlzwH").MD5
        urlComponents.query = "q=\(word)&from=\(from)&to=\(to)&appKey=\(appKey)&salt=\(salt)&sign=\(sign)"
        
        guard let url = urlComponents.url else { return }
        
        dataTask = defaultSession.dataTask(with: url) { data, response, error in
            defer { self.dataTask = nil }

            if let error = error {
                completion(nil, (message: error.localizedDescription, cause: nil))
                return
            }

            guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
                completion(nil, (message: "Server not reponse 200", cause: nil))
                return
            }
            
            
            if let data = data {
                //print(String.init(data: data, encoding: .utf8)!)
                do {
                    
                    completion(try DictionaryItem.init(youdao: data), nil)
                } catch YouDaoJSONError.error(let errorCode) {
                    completion(nil, (message: "ErrorCode: \(errorCode)", cause: nil))
                } catch YouDaoJSONError.invalidFormat(let cause) {
                    completion(nil, (message: "JSON Format Error", cause: cause))
                } catch {
                    return
                }
            }
            
        }
        
        dataTask?.resume()
    }
    
}




enum YouDaoJSONError: Error {
    case invalidFormat(String)
    case error(String)
}


fileprivate extension DictionaryItem {
    
    init?(youdao data: Data) throws {
        let root = try JSONSerialization.jsonObject(with: data, options: [])
        guard let json = root as? [String: AnyObject] else {
            throw YouDaoJSONError.invalidFormat("JSON root must be Object")
        }
        guard let errorCode = json["errorCode"] as? String else {
            throw YouDaoJSONError.invalidFormat("errorCode missing")
        }
        guard errorCode == "0" else {
            throw YouDaoJSONError.error(errorCode)
        }
        guard let query = json["query"] as? String else {
            throw YouDaoJSONError.invalidFormat("query missing")
        }
        //guard let translation = json["translation"] as? [String] else {
        //    throw YouDaoJSONError.invalidFormat("translation missing")
        //}
        guard let basic = json["basic"] as? [String: AnyObject],
              let explains = basic["explains"] as? [String] else {
                return nil
        }
        
        self.version = "1.0"
        self.query = query
        self.from = .en
        self.to = .zh
        
        self.explanations = explains
            
        var pronunciations = [PronunciationDialectCode: String]()
        if let phonetic = basic["phonetic"] as? String {
            pronunciations[.cm] = phonetic
        }
        if let usPhonetic = basic["us-phonetic"] as? String {
            pronunciations[.us] = usPhonetic
        }
        if let ukPhonetic = basic["uk-phonetic"] as? String {
            pronunciations[.uk] = ukPhonetic
        }
        if pronunciations.count > 0 {
            self.pronunciations = pronunciations
        } else {
            self.pronunciations = nil
        }
    }

}
