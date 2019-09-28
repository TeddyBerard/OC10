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
    fileprivate var key: String = "2554d02f82d94abe748667b93f5174b8"
    
    
    init() { }

    func searchRecipes(ingredients: String, completion: @escaping ([Hits]) -> Void) {
        guard let url = URL(string: "https://api.edamam.com/search?q=\(ingredients)&app_id=\(appId)&app_key=\(key)") else { return }

        AF.request(url).response { response in
            guard let data = response.data else { return }

            do {
                let recipes = try JSONDecoder().decode(Recipes.self, from: data)
                completion(recipes.hits)
            } catch let error {
                print(error)
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
