//
//  YouDaoService.swift
//  MDictionary
//
//  Created by liwenqiu on 10/07/2017.
//  Copyright © 2017 liwenqiu. All rights reserved.
//

import Foundation

typealias QueryError = (message: String, cause: String?)
typealias QueryResult = (TranslationResult?, QueryError?) -> ()


class YouDaoService {
    
    let defaultSession = URLSession(configuration: .default)
    var dataTask: URLSessionTask?
    
    func getQueryResult(q: String, completion: @escaping QueryResult) {
        
        guard var urlComponents = URLComponents(string: "https://openapi.youdao.com/api") else { return }
        
        dataTask?.cancel()
        
        let from = "en"
        let to = "zh_CHS"
        let appKey = "558dbff32a346334"
        let salt = "2"
        let sign = (appKey + q + salt + "BuXCCS1wbmD518cS7atAL1bl3jCwlzwH").MD5
        urlComponents.query = "q=\(q)&from=\(from)&to=\(to)&appKey=\(appKey)&salt=\(salt)&sign=\(sign)"
        
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
                do {
                    completion(try TranslationResult.init(data), nil)
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



struct TranslationResult {
    
    let query: String
    let translation: [String]
    let explains: [String]?
    let phonetic: String?
    let ukPhonetic: String?
    let usPhonetic: String?
    
    init(_ data: Data) throws {
        
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
        guard let translation = json["translation"] as? [String] else {
            throw YouDaoJSONError.invalidFormat("translation missing")
        }
        
        self.query = query
        self.translation = translation
        
        if let basic = json["basic"] as? [String: AnyObject] {
            
            // explains
            if let explains = basic["explains"] as? [String] {
                self.explains = explains
            } else {
                self.explains = nil
            }
            
            // phonetic
            if let phonetic = basic["phonetic"] as? String {
                self.phonetic = phonetic
            } else {
                self.phonetic = nil
            }
            
            // us-phonetic
            if let usPhonetic = basic["us-phonetic"] as? String {
                self.usPhonetic = usPhonetic
            } else {
                self.usPhonetic = nil
            }
            
            // uk-phonetic
            if let ukPhonetic = basic["uk-phonetic"] as? String {
                self.ukPhonetic = ukPhonetic
            } else {
                self.ukPhonetic = nil
            }
            
        } else {
            self.explains = nil
            self.phonetic = nil
            self.ukPhonetic = nil
            self.usPhonetic = nil
        }
    }
}


enum YouDaoJSONError: Error {
    case invalidFormat(String)
    case error(String)
}


