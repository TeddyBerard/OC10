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
    var baseUrl: String = "https://api.edamam.com/search"
    fileprivate let searchNumber = 25

    init() { }

    enum SearchError: Error {
        case occuredErrorRequest
        case noResult
        case wrongJSON
        case wrongURL
    }

    func searchRecipes(ingredients: String, from: Int, fakeData: Bool = false,
                       completion: @escaping ([Hits], Int, Error?) -> Void) {
        guard let url =
            URL(string: "\(baseUrl)?q=\(ingredients)&app_id=\(appId)&app_key=\(key)&from=0&to=\(from + searchNumber)")
            else {
                completion([], from, SearchError.wrongURL)
                return
        }

        AF.request(url).validate().response { response in

            switch response.result {
            case .success(let data):
                guard let data = data,
                    !fakeData else {
                    completion([], from, SearchError.occuredErrorRequest)
                    return
                }

                do {
                    let recipes = try JSONDecoder().decode(Recipes.self, from: data)
                    completion(recipes.hits, from + self.searchNumber, nil)
                } catch {
                    completion([], from, SearchError.wrongJSON)
                }
            case .failure:
                completion([], from, SearchError.occuredErrorRequest)
            }
        }
    }

    func downloadImage(with url: String, completion: @escaping (UIImage?, Error?) -> Void) {
        guard let url = URL(string: url) else {
            completion(nil, SearchError.wrongURL)
            return
        }

        AF.request(url).responseData { response in
            if let data = response.data,
                let image = UIImage(data: data) {
                completion(image, nil)
            }
        }
    }
}
