//
//  Parser.swift
//  NetworkingWithCombine
//
//  Created by Ankit on 24/04/22.
//

import Foundation

public struct GenericResponseParser<T: Decodable>: ResponseParserType {

    public typealias Response = T
    public init() {}
    public func parse(data: Data) throws -> T  {
        try JSONDecoder().decode(Response.self, from: data)
    }
    
}

public struct DefaultErrorParser: ErrorParserType {
    
    public init() {}
    public func parse(data: JSONDictionary) -> Error? {
        print("Error: \(data)")

        guard let message = data["message"] as? String else {
            return nil
        }

         return APIError.some(nil, message)
        
    }
}
