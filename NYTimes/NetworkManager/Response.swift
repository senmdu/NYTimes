//
//  Response.swift
//  NYTimes
//
//  Created by Senthil on 13/05/23.
//

import Foundation


struct Response<T: Decodable>: Decodable {
    
    let status: String
    let totalResults: Int
    let results: [T]
    
    enum CodingKeys: String, CodingKey {
        case status
        case totalResults = "num_results"
        case results
    }
    
}

