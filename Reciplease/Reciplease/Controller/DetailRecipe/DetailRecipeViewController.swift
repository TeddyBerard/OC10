//
//  DetailRecipeViewController.swift
//  Reciplease
//
//  Created by Teddy Bérard on 28/09/2019.
//  Copyright © 2019 Teddy Bérard. All rights reserved.
//

import UIKit

class DetailRecipeViewController: UIViewController {

    // MARK: - Properties

    @IBOutlet weak var recipeImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var ingredientListLabel: UILabel!
    @IBOutlet weak var getDirectionButton: UIButton!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var scrollContentView: UIView!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var favoriteButton: UIButton!

    var recipe: Recipe!
    var image: UIImage?

    // MARK: - Cycle life

    override func viewDidLoad() {
        super.viewDidLoad()
        setupRecipe()
        setupUI()
    }

    // MARK: - Setup

    func setupRecipe() {
        nameLabel.text = recipe.label
        timeLabel.text = "\(recipe.time)m"
        if recipe.time == 0 {
            timeLabel.isHidden = true
        }
        setupIngredients()
        if let image = image {
            recipeImageView.image = image
        }
    }

    func setupIngredients() {
        ingredientListLabel.text = ""
        for (index, ingredient) in recipe.ingredients.enumerated() {
            if index == 0 {
                ingredientListLabel.text?.append(contentsOf: "- \(ingredient)")
            } else {
                ingredientListLabel.text?.append(contentsOf: "\n- \(ingredient)")
            }
        }
    }

    // MARK: - Setup UI

    func setupUI() {
        setupViewUI()
        setupButtonUI()
        setupLabelTimeUI()
        setupFavoriteUI()
    }

    func setupLabelTimeUI() {
        timeLabel.backgroundColor = nil
        timeLabel.layer.shadowColor = UIColor.black.cgColor
        timeLabel.layer.backgroundColor = UIColor.white.cgColor
        timeLabel.layer.shadowOffset = CGSize(width: 0, height: 0)
        timeLabel.layer.shadowOpacity = 0.5
        timeLabel.layer.shadowRadius = 4
        // Rounded
        timeLabel.layer.cornerRadius = 12
        timeLabel.layer.masksToBounds = false
    }

    func setupViewUI() {
        // Shadow
        contentView.layer.shadowColor = UIColor.black.cgColor
        contentView.layer.backgroundColor = UIColor.white.cgColor
        contentView.layer.shadowOffset = CGSize(width: 0, height: 0)
        contentView.layer.shadowOpacity = 0.5
        contentView.layer.shadowRadius = 4
        // Rounded
        contentView.layer.cornerRadius = 12
        contentView.layer.masksToBounds = false
    }

    func setupButtonUI() {
        getDirectionButton.backgroundColor = nil
        getDirectionButton.layer.shadowColor = UIColor.black.cgColor
        getDirectionButton.layer.backgroundColor = UIColor.white.cgColor
        getDirectionButton.layer.shadowOffset = CGSize(width: 0, height: 0)
        getDirectionButton.layer.shadowOpacity = 0.5
        getDirectionButton.layer.shadowRadius = 4
        // Rounded
        getDirectionButton.layer.cornerRadius = 12
        getDirectionButton.layer.masksToBounds = false
    }

    func setupFavoriteUI() {
        if RecipeFavorite.isAlreadyFavorite(with: recipe.uri) {
            favoriteButton.setImage(#imageLiteral(resourceName: "star"), for: .normal)
        } else {
            favoriteButton.setImage(#imageLiteral(resourceName: "starEmpty"), for: .normal)
        }
    }

    // MARK: - IBAction

    @IBAction func closeAction(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }

    @IBAction func getDirectionsAction(_ sender: Any) {
        guard let url = URL(string: recipe.url) else {
            return
        }

        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }

    @IBAction func addToFavoritesAction(_ sender: Any) {
        if RecipeFavorite.isAlreadyFavorite(with: recipe.uri) {
            favoriteButton.setImage(#imageLiteral(resourceName: "starEmpty"), for: .normal)
            RecipeFavorite.deleteFavorite(with: recipe.uri)
            RecipeFavorite.save()
        } else {
            RecipeFavorite.addRecipe(recipe: recipe)
            RecipeFavorite.save()
            favoriteButton.setImage(#imageLiteral(resourceName: "star.png"), for: .normal)
        }
    }

}
