//
//  Request.swift
//  NetworkingWithCombine
//
//  Created by Ankit on 23/05/21.
//

import Foundation

import Combine

public protocol Request {
    associatedtype Response: Decodable
    associatedtype ResponseParser: ResponseParserType where ResponseParser.Response == Response
    
    var baseUrl: String { get }
    var path: String { get }
    var method: String { get }
    
    var header: [String: String]? { get }
    var parser: ResponseParser? { get }
    var errorParser: ErrorParserType? { get }
    
    func parameter() -> [String: Any]?
}

public extension Request {
    
//    var baseUrl : String {
//        return BASE_URL
//    }
     
    var reponseValidRange: ClosedRange<Int> {
        (200...399)
    }
}

public protocol ResponseParserType {
    associatedtype Response
    
    func parse(data: Data) throws -> Response
}

public typealias JSONDictionary = [String : Any]

public protocol ErrorParserType {
    
    func parse(data: JSONDictionary) -> Error?
}

public protocol KeyBasedRequest {
    var key: String { get set }
    var value: String { get set }
}

public extension KeyBasedRequest {
    var key: String {
        get {
            "appid"
        }
        set {}
        
    }
    
    var value: String {
        get {
            API_KEY
        }
        set{}
    }
}

public protocol RequestConvertable: Request {
    func asURLRequest() throws -> URLRequest
}

public extension RequestConvertable {
    
    func asURLRequest() throws -> URLRequest {
        
        guard let baseUrl = URL(string: baseUrl) else { throw RequestCrationError.invalidURL()}
        let completeUrl = baseUrl.appendingPathComponent(path)
        var urlRequest =  URLRequest(url: completeUrl)
        
        urlRequest.httpMethod = method
        
        if let x = header {
            for (key,value) in x {
                urlRequest.setValue(value, forHTTPHeaderField: key)
            }
        }
        
        var param = parameter()
        
        if let keyRequest = self as? KeyBasedRequest {
            param?[keyRequest.key] = keyRequest.value
        }
        
        switch method {
        case "POST":
            urlRequest = try JSONEncoding.default.encode(urlRequest, with: param)
            
        case "GET":
            urlRequest = try URLEncoding.default.encode(urlRequest, with: param)
            
        default:
            break
            
        }
        
        return urlRequest
    }
}


public protocol RequestExecutor {
    func executeRequest<R>(request: R)  -> AnyPublisher<R.Response, Error> where R: RequestConvertable
}
