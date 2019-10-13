//
//  ingredientsListView.swift
//  Reciplease
//
//  Created by Teddy Bérard on 26/09/2019.
//  Copyright © 2019 Teddy Bérard. All rights reserved.
//

import UIKit

class IngredientsListView: UIView {

    // MARK: - Properties

    @IBOutlet var contentView: UIView!
    @IBOutlet weak var listTextView: UITextView!
    @IBOutlet weak var refrigeratorImageView: UIImageView!
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var recipeImageView: UIImageView!
    @IBOutlet weak var clearButton: UIButton!

    var ingredients: [String] = []
    var from = 0

    // MARK: - Init

    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }

    func commonInit() {
        Bundle.main.loadNibNamed("IngredientsListView", owner: self, options: nil)
        addSubview(contentView)
        contentView.frame = bounds
        contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        setupUI()
    }

    // MARK: - Setup UI

    fileprivate func setupUI() {
        // Shadow
        layer.shadowColor = UIColor.black.cgColor
        layer.backgroundColor = UIColor.clear.cgColor
        layer.shadowOffset = CGSize(width: 0, height: 0)
        layer.shadowOpacity = 0.5
        layer.shadowRadius = 4
        // Rounded
        contentView.layer.cornerRadius = 12
        contentView.layer.masksToBounds = true
    }

    fileprivate func scaleImage(image: UIImageView, scale: CGFloat, completion: (() -> Void)?) {
        DispatchQueue.main.async {
            UIView.animate(withDuration: 0.7, animations: {
                image.transform = CGAffineTransform(scaleX: scale, y: scale)
            }, completion: { _ in
                completion?()
            })
        }
    }

    // MARK: - List action

    func addIngredientToList(_ ingredient: String) {
        guard !ingredients.contains(ingredient), ingredient != "" else { return }

        if ingredient.contains(",") {
            addMultipleIngredientSeparator(ingredient)
        } else {
            ingredients.append(ingredient)
            if ingredients.count == 1 {
                scaleImage(image: refrigeratorImageView, scale: 0.001, completion: {
                    self.displayList()
                })
            } else {
                displayList()
            }
        }
    }

    func displayList() {
        listTextView.isHidden = false
        listTextView.text = ""
        for (index, ingredient) in ingredients.enumerated() {
            if index == 0 {
                listTextView.text.append("- \(ingredient)")
            } else {
                listTextView.text.append("\n\n- \(ingredient)")
            }
        }
    }

    func addMultipleIngredientSeparator(_ ingredients: String) {
        let ingredientsArray = ingredients.components(separatedBy: ",")

        for ingredient in ingredientsArray {
            addIngredientToList(ingredient)
        }
    }

    func clear() {
        from = 0
        listTextView.text = ""
        ingredients = []
        refrigeratorImageView.isHidden = false
        scaleImage(image: refrigeratorImageView, scale: 1, completion: nil)
        errorLabel.isHidden = true
        recipeImageView.isHidden = true
    }

    func displayError(error: Error = Search.SearchError.noResult) {
        recipeImageView.transform = CGAffineTransform(scaleX: 0.001, y: 0.001)
        recipeImageView.isHidden = false
        listTextView.isHidden = true
        errorLabel.isHidden = false
        clearButton.isHidden = true
        refrigeratorImageView.isHidden = true
        switch error {
        case Search.SearchError.occuredErrorRequest:
            errorLabel.text = "An error is occured please try again."
        default:
            errorLabel.text = "No result found, please try with another aliments"
        }
        scaleImage(image: recipeImageView, scale: 1, completion: nil)
    }

    // MARK: - @IBAction

    @IBAction func clearAction(_ sender: Any) {
        clear()
    }
}
