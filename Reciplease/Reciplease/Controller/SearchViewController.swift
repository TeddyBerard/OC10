//
//  ViewController.swift
//  Reciplease
//
//  Created by Teddy Bérard on 25/09/2019.
//  Copyright © 2019 Teddy Bérard. All rights reserved.
//

import UIKit

class SearchViewController: UIViewController {

    // MARK: - Properties

    @IBOutlet weak var ingredientListView: IngredientsListView!
    @IBOutlet weak var ingredientTextField: UITextField!
    @IBOutlet weak var recipeButton: UIButton!
    @IBOutlet weak var addButton: UIButton!

    // MARK: - Cycle Life

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUIButtons()
        setupUITextField()
    }

    // MARK: - Setup UI

    func setupUIButtons() {
        setupButton(button: addButton)
        setupButton(button: recipeButton)
    }

    func setupUITextField() {
        ingredientTextField.backgroundColor = nil
        ingredientTextField.layer.shadowColor = UIColor.black.cgColor
        ingredientTextField.layer.backgroundColor = UIColor.white.cgColor
        ingredientTextField.layer.shadowOffset = CGSize(width: 0, height: 0)
        ingredientTextField.layer.shadowOpacity = 0.5
        ingredientTextField.layer.shadowRadius = 4
        // Rounded
        ingredientTextField.layer.cornerRadius = 12
        ingredientTextField.layer.masksToBounds = false
    }

    func setupButton(button: UIButton) {
        // Shadow
        button.backgroundColor = nil
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.backgroundColor = UIColor.white.cgColor
        button.layer.shadowOffset = CGSize(width: 0, height: 0)
        button.layer.shadowOpacity = 0.5
        button.layer.shadowRadius = 4
        // Rounded
        button.layer.cornerRadius = 12
        button.layer.masksToBounds = false
    }

    // MARK: - @IBAction

    @IBAction func addIngredientAction(_ sender: Any) {
        guard let ingredient = ingredientTextField.text?
            .components(separatedBy: .whitespacesAndNewlines)
            .joined() else { return }

        ingredientListView.addIngredientToList(ingredient)
        ingredientTextField.text = ""
    }

    @IBAction func searchAction(_ sender: Any) {

    }
}
