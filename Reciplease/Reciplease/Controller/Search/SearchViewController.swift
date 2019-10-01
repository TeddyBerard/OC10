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
    @IBOutlet weak var activityIndication: UIActivityIndicatorView!

    var search: Search = Search()
    var recipes: [Recipe] = []

    fileprivate var isDisplayed: Bool = false

    // MARK: - Cycle Life

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUIButtons()
        setupUITextField()
        setupTableView()
        activityIndication.isHidden = true
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

    func setupAnimator(animated: Bool) {
        if animated {
            activityIndication.startAnimating()
            activityIndication.isHidden = false
        } else {
            activityIndication.stopAnimating()
            activityIndication.isHidden = true
        }
    }

    func addIngredient() {
        guard let ingredient = ingredientTextField.text?
            .components(separatedBy: .whitespacesAndNewlines)
            .joined() else { return }

        ingredientListView.addIngredientToList(ingredient)
        ingredientTextField.text = ""
    }

    func backList() {
        ingredientListView.from = 0
        isDisplayed = false
        resultTableView.backgroundColor = .clear
        resultTableView.isHidden = true
        recipes = []
        resultTableView.reloadData()
        addButton.setTitle("Add", for: .normal)
        ingredientTextField.isEnabled = true
        recipeButton.isEnabled = true
        setupAnimateSearch(to: 1)
        if ingredientListView.recipeImageView.isHidden == false {
           ingredientListView.clear()
        }
        ingredientListView.clearButton.isHidden = false
    }

    func setupAnimateSearch(to scale: CGFloat) {
        DispatchQueue.main.async {
            UIView.animate(withDuration: 0.7, animations: {
                self.ingredientTextField.transform = CGAffineTransform(scaleX: scale, y: scale)
                self.recipeButton.transform = CGAffineTransform(scaleX: scale, y: scale)
            })
        }
    }

    // MARK: - Search Recipes

    func searchRecipe() {
        search.searchRecipes(ingredients: ingredientListView.ingredients.joined(separator: ","), from: ingredientListView.from,
                             completion: { [weak self] hits, from, err in
                                guard let wSelf = self else {
                                    return
                                }
                                
                                wSelf.isDisplayed = true
                                wSelf.addButton.setTitle("Back", for: .normal)
                                wSelf.setupAnimator(animated: false)
                                
                                if let error = err {
                                    wSelf.ingredientListView.displayError(error: error)
                                } else if hits.count == 0 {
                                    wSelf.addButton.setTitle("Close", for: .normal)
                                    wSelf.ingredientListView.displayError()
                                } else {
                                    wSelf.ingredientListView.from = from
                                    wSelf.recipes = hits.compactMap({ $0.recipe }).compactMap({ $0 })
                                    wSelf.resultTableView.reloadData()
                                    wSelf.resultTableView.isHidden = false
                                    wSelf.resultTableView.backgroundColor = .white
                                }
        })
    }

    // MARK: - @IBAction

    @IBAction func addIngredientAction(_ sender: Any) {
        if !isDisplayed {
            addIngredient()
        } else {
            backList()
        }
    }

    @IBAction func searchAction(_ sender: Any) {
        guard ingredientListView.ingredients.joined(separator: ",") != "" else { return }

        setupAnimator(animated: true)
        recipeButton.isEnabled = false
        ingredientTextField.isEnabled = false
        setupAnimateSearch(to: 0.0001)
        searchRecipe()
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

        let recipe = recipes[indexPath.row]

        cell.setup(name: recipe.label, ingredients: recipe.ingredients.joined(separator: ", "), time: recipe.time)
        cell.selectionStyle = .none

        search.downloadImage(with: recipe.image, completion: { image in
            cell.setupImage(with: image)
        })

        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        DispatchQueue.main.async {
            let main = UIStoryboard(name: "Main", bundle: nil)
            guard let detailRecipeViewController = main.instantiateViewController(withIdentifier: "DetailRecipeViewController") as? DetailRecipeViewController else { return }

            let cell = tableView.cellForRow(at: indexPath) as? SearchTableViewCell

            detailRecipeViewController.image = cell?.recipeImageView.image
            detailRecipeViewController.recipe = self.recipes[indexPath.row]
            self.present(detailRecipeViewController, animated: true, completion: nil)
        }
    }

    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row + 1 == recipes.count {
            searchRecipe()
        }
    }
}
