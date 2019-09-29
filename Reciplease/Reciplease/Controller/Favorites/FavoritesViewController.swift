//
//  FavoritesViewController.swift
//  Reciplease
//
//  Created by Teddy Bérard on 29/09/2019.
//  Copyright © 2019 Teddy Bérard. All rights reserved.
//

import UIKit

class FavoritesViewController: UIViewController {

    // MARK: - Properties

    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var favoritesTableView: UITableView!
    @IBOutlet weak var noFavoritesLabel: UILabel!

    var recipes: [Recipe] = []
    var search: Search = Search()

    // MARK: - Cycle Life

    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
        setupTableView()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        displayFavorites()
    }

    func displayFavorites() {
        recipes = RecipeFavorite.getRecipes()
        favoritesTableView.reloadData()
        setupTableViewUI()
    }

    // MARK: - Setup UI

    func setupUI() {
        setupViewUI()
        setupTableViewUI()
        noFavoritesLabel.sizeToFit()
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

    func setupTableViewUI() {
        if recipes.count != 0 {
            favoritesTableView.backgroundColor = .white
        } else {
            favoritesTableView.backgroundColor = .clear
        }

        // Rounded
        favoritesTableView.layer.cornerRadius = 12
    }
}

extension FavoritesViewController: UITableViewDelegate, UITableViewDataSource {

    func setupTableView() {
        favoritesTableView.register(UINib(nibName: "SearchTableViewCell", bundle: nil),
                                 forCellReuseIdentifier: "recipeCell")
        favoritesTableView.separatorStyle = .none
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return recipes.count
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 140
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = favoritesTableView.dequeueReusableCell(withIdentifier: "recipeCell", for: indexPath)
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
}
