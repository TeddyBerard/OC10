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
    @IBOutlet weak var resultTableView: UITableView!
    
    var search: Search = Search()
    
    var recipes: [Recipe] = []
    
    fileprivate var isDisplayed: Bool = false

    // MARK: - Cycle Life

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUIButtons()
        setupUITextField()
        setupTableView()
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
    
    func addIngredient() {
        guard let ingredient = ingredientTextField.text?
            .components(separatedBy: .whitespacesAndNewlines)
            .joined() else { return }
        
        ingredientListView.addIngredientToList(ingredient)
        ingredientTextField.text = ""
    }
    
    func resetList() {
        isDisplayed = false
        resultTableView.backgroundColor = .clear
        recipes = []
        resultTableView.reloadData()
        ingredientListView.clear()
        addButton.setTitle("Add", for: .normal)
        ingredientTextField.isEnabled = true
        recipeButton.isEnabled = true
    }

    // MARK: - @IBAction

    @IBAction func addIngredientAction(_ sender: Any) {
        if !isDisplayed {
            addIngredient()
        } else {
            resetList()
        }
    }

    @IBAction func searchAction(_ sender: Any) {
        guard ingredientListView.ingredients.joined(separator: ",") != "" else { return }
        
        search.searchRecipes(ingredients: ingredientListView.ingredients.joined(separator: ","),
                             completion: { [weak self] hits in
                                guard let wSelf = self else { return }

                                wSelf.recipes = hits.compactMap({ $0.recipe }).compactMap({ $0 })
                                wSelf.resultTableView.reloadData()
                                wSelf.resultTableView.backgroundColor = .white
                                wSelf.isDisplayed = true
                                wSelf.addButton.setTitle("Close", for: .normal)
                                wSelf.ingredientTextField.isEnabled = false
                                wSelf.recipeButton.isEnabled = false

        })
    }
}

// MARK: - UITableViewDelegate & UITableViewDataSource & Setup TableView

extension SearchViewController: UITableViewDelegate, UITableViewDataSource {

    func setupTableView() {
        resultTableView.register(UINib(nibName: "SearchTableViewCell", bundle: nil),
                                  forCellReuseIdentifier: "recipeCell")
        resultTableView.separatorStyle = .none
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return recipes.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 140
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = resultTableView.dequeueReusableCell(withIdentifier: "recipeCell", for: indexPath)
            as? SearchTableViewCell else {
                fatalError("The dequeued cell is not an instance of WeatherTableViewCell.")
        }
        
//        cell.setup(name: "Test", ingredients: "TEST ingreidient", time: 10)
//
//        cell.selectionStyle = .none
//        return cell
        
        let recipe = recipes[indexPath.row]
        
        cell.setup(name: recipe.label, ingredients: recipe.ingredients.joined(separator: ", "), time: recipe.time)
        cell.selectionStyle = .none
        
        search.downloadImage(with: recipe.image, completion: { image in
            cell.setupImage(with: image)
        })
        
        return cell
    }
}
