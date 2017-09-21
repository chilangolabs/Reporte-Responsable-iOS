//
//  IngRouter.swift
//  Reporte Responsable
//
//  Created by Rodrigo on 21/09/17.
//  Copyright © 2017 Chilango Labs. All rights reserved.
//

import Alamofire
import Foundation

public enum IngRouter: URLRequestConvertible {
    static let baseURLPath = "https://criptexfc.com/tlalolin/admin/app"
    
    case report
    
    var method: HTTPMethod {
        switch self {
        case .report:
            return .post
        }
    }
    
    var path: String {
        switch self {
        case .report:
            return "/addMensaje"
        }
    }
    
    public func asURLRequest() throws -> URLRequest {
        let parameters: [String: Any] = {
            switch self {
            default:
                return [:]
            }
        }()
        let url = try IngRouter.baseURLPath.asURL()
        
        var request = URLRequest(url: url.appendingPathComponent(path))
        request.httpMethod = method.rawValue
        request.timeoutInterval = TimeInterval(30 * 1000)
        
        return try URLEncoding.default.encode(request, with: parameters)
    }
}



