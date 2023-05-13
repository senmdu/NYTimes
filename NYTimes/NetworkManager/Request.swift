//
//  Request.swift
//  NYTimes
//
//  Created by Senthil on 13/05/23.
//

import Foundation

enum Method: String {
    case get = "GET"
}

struct Request<Value> {
    
    var method: Method
    var path: String
    
    init(method: Method = .get, path: String) {
        self.method = method
        self.path = path
    }
    
}
