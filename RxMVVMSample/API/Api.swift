//
//  Api.swift
//  RxMVVMSample
//
//  Created by Hiromi Fujita on 2020/12/24.
//

import Foundation
import APIKit

final class Api {}

extension Api {

    struct RepositoryRequest: SampleRequest {

        // MARK: - Initialize
        let language: String
        let page: Int

        init(language: String = "Swift", page: Int) {
            self.language = language
            self.page = page
        }

        // MARK: - Request Type
        let method: HTTPMethod = .get
        let path: String = "/search/repositories"

        var parameters: Any? {
            var params = [String: Any]()
            params["q"] = language
            params["sort"] = "stars"
            params["page"] = "\(page)"
            return params
        }

        func response(from object: Any, urlResponse: HTTPURLResponse) throws -> [Repository] {
            guard let data = object as? Data else {
                throw ResponseError.unexpectedObject(object)
            }
            let res = try JSONDecoder().decode(RepositoriesResponse.self, from: data)
            return res.items
        }
    }

}

