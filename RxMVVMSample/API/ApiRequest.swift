//
//  ApiRequest.swift
//  RxMVVMSample
//
//  Created by Hiromi Fujita on 2020/12/24.
//

import Foundation
import APIKit

protocol SampleRequest: Request {}

extension SampleRequest {
    var baseURL: URL {
        return URL(string: "https://api.github.com")!
    }
}

extension SampleRequest {
    func intercept(object: Any, urlResponse: HTTPURLResponse) throws -> Any {
        switch urlResponse.statusCode {
        case 200..<300:
            return object
        default:
            throw NSError(domain: "Bad Status Response", code: urlResponse.statusCode, userInfo: nil)
        }
    }
}

struct DecodableDataParser: DataParser {
    let contentType: String? = "application/json"

    func parse(data: Data) throws -> Any {
        return data
    }
}

extension SampleRequest where Response: Decodable {
    var dataParser: DataParser {
        return DecodableDataParser()
    }

    func response(from object: Any, urlResponse: HTTPURLResponse) throws -> Response {
        guard let data = object as? Data else {
            throw ResponseError.unexpectedObject(object)
        }
        return try JSONDecoder().decode(Response.self, from: data)
    }
}

