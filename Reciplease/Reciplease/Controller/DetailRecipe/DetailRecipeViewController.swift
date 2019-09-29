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

    }

}
