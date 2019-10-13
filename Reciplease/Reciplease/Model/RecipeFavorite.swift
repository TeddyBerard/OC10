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

    /// Save the currect change on the coredata
    static func save() {
        try? AppDelegate.viewContext.save()
    }

    /// Delete favorite from uri
    ///
    /// - Parameter uri: favorite uri
    /// - Returns: return `true` if the favorite is deleted otherwise `false`
    static func deleteFavorite(with uri: String) -> Bool {
        let context = AppDelegate.viewContext
        if let favorite = all.first(where: { $0.uri == uri }) {
            context.delete(favorite)
            return true
        }
        return false
    }

    /// Check if the recipe is already is the favorite
    ///
    /// - Parameter uri: recipe uri
    /// - Returns: return `true` if the favorite is already on favorites otherwise `false`
    static func isAlreadyFavorite(with uri: String) -> Bool {
        if all.first(where: { $0.uri == uri }) != nil {
            return true
        }
        return false
    }

    /// Add recipe on CoreData
    ///
    /// - Parameter recipe: recipe requested
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

    /// Get the recipes from CoreData
    ///
    /// - Returns: return all recipe save on CoreData
    static func getRecipes() -> [Recipe] {
        return all.compactMap({ RecipeFavorite.getRecipe(with: $0) })
    }

    /// Get the recipe from recipe favorite
    ///
    /// - Parameter favorite: favorite recipe
    /// - Returns: recipe from CoreData
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
