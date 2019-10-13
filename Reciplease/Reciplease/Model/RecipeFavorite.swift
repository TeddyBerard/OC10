//
//  RecipeFavorite.swift
//  Reciplease
//
//  Created by Teddy Bérard on 29/09/2019.
//  Copyright © 2019 Teddy Bérard. All rights reserved.
//

import Foundation
import CoreData

class RecipeFavorite: NSManagedObject {

    // MARK: - Property

    static var all: [RecipeFavorite] {
        let request = NSFetchRequest<RecipeFavorite>(entityName: "RecipeFavorite")
        request.sortDescriptors = [NSSortDescriptor(key: "label", ascending: true)]
        guard let items = try? AppDelegate.viewContext.fetch(request) else { return [] }
        return items
    }

    // MARK: - Gestion

    static func save() {
        try? AppDelegate.viewContext.save()
    }

    static func deleteFavorite(with uri: String) -> Bool {
        let context = AppDelegate.viewContext
        if let favorite = all.first(where: { $0.uri == uri }) {
            context.delete(favorite)
            return true
        }
        return false
    }

    static func isAlreadyFavorite(with uri: String) -> Bool {
        if all.first(where: { $0.uri == uri }) != nil {
            return true
        }
        return false
    }

    static func addRecipe(recipe: Recipe) {
        let recipeObject = RecipeFavorite(context: AppDelegate.viewContext)

        recipeObject.label = recipe.label
        recipeObject.uri = recipe.uri
        recipeObject.image = recipe.image
        recipeObject.time = recipe.time
        recipeObject.ingredients = recipe.ingredients as NSObject
        recipeObject.health = recipe.health as NSObject
        recipeObject.url = recipe.url
    }

    static func getRecipes() -> [Recipe] {
        return all.compactMap({ RecipeFavorite.getRecipe(with: $0) })
    }

    fileprivate static func getRecipe(with favorite: RecipeFavorite) -> Recipe? {
        guard let label = favorite.label, let image = favorite.image,
            let ingredients = favorite.ingredients as? [String],
            let health = favorite.health as? [String], let url = favorite.url,
            let uri = favorite.uri else { return nil }

        return Recipe(label: label,
                            image: image, ingredients: ingredients,
                            time: Float(favorite.time), health: health,
                            url: url, uri: uri)
    }

}
