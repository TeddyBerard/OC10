//
//  Recipe.swift
//  Reciplease
//
//  Created by Teddy Bérard on 27/09/2019.
//  Copyright © 2019 Teddy Bérard. All rights reserved.
//

import Foundation

class Recipes: Codable {
    var hits: [Hits]

    private enum CodingKeys: String, CodingKey {
        case hits
    }

}

class Hits: Codable {
    var recipe: Recipe

    private enum CodingKeys: String, CodingKey {
        case recipe
    }
}

class Recipe: Codable {
    var label: String
    var image: String
    var ingredients: [String]
    var time: Int
    var heath: [String]
    var url: String
    var uri: String

    private enum CodingKeys: String, CodingKey {
        case label
        case image
        case ingredients = "ingredientLines"
        case time = "totalTime"
        case heath = "healthLabels"
        case url
        case uri
    }
}
