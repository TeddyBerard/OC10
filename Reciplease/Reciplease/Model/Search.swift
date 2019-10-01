//
//  Search.swift
//  Reciplease
//
//  Created by Teddy Bérard on 27/09/2019.
//  Copyright © 2019 Teddy Bérard. All rights reserved.
//

import Foundation
import Alamofire

class Search {

    fileprivate var appId: String = "af2fe4f4"
    fileprivate let key: String = "2554d02f82d94abe748667b93f5174b8"
    fileprivate var baseUrl: String = "https://api.edamam.com/search"
    fileprivate let searchNumber = 25

    init() { }

    enum SearchError: Error {
        case occuredErrorRequest
        case noResult
    }

    func searchRecipes(ingredients: String, from: Int, completion: @escaping ([Hits], Int, Error?) -> Void) {
        guard let url = URL(string: "\(baseUrl)?q=\(ingredients)&app_id=\(appId)&app_key=\(key)&from=0&to=\(from + searchNumber)") else { return }

        AF.request(url).validate().response { response in

            switch response.result {
            case .success(let data):
                guard let data = data else {
                    completion([], from, SearchError.occuredErrorRequest)
                    return
                }

                do {
                    let recipes = try JSONDecoder().decode(Recipes.self, from: data)
                    completion(recipes.hits, from + self.searchNumber, nil)
                } catch let error {
                    completion([], from, error)
                }
            case .failure:
                completion([], from, SearchError.occuredErrorRequest)
            }
        }
    }

    func downloadImage(with url: String, completion: @escaping (UIImage) -> Void) {
        guard let url = URL(string: url) else { return }

        AF.request(url).responseData { response in
            guard let data = response.data else { return }

            if let image = UIImage(data: data) {
                completion(image)
            }
        }
    }
}
