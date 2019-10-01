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
    var time: Float
    var health: [String]
    var url: String
    var uri: String

    init(label: String, image: String, ingredients: [String], time: Float, health: [String], url: String, uri: String) {
        self.label = label
        self.image = image
        self.ingredients = ingredients
        self.time = time
        self.health = health
        self.url = url
        self.uri = uri
    }

    private enum CodingKeys: String, CodingKey {
        case label
        case image
        case ingredients = "ingredientLines"
        case time = "totalTime"
        case health = "healthLabels"
        case url
        case uri
    }
}
