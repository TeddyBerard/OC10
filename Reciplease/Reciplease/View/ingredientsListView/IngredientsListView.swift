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

    var ingredients: [String] = []

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

    fileprivate func scaleImage(scale: CGFloat, completion: (() -> Void)?) {
        DispatchQueue.main.async {
            UIView.animate(withDuration: 0.7, animations: {
                self.refrigeratorImageView.transform = CGAffineTransform(scaleX: scale, y: scale)
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
                scaleImage(scale: 0.001, completion: {
                    self.displayList()
                })
            } else {
                displayList()
            }
        }
    }

    func displayList() {
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
        listTextView.text = ""
        ingredients = []
        scaleImage(scale: 1, completion: nil)
    }

    // MARK: - @IBAction

    @IBAction func clearAction(_ sender: Any) {
        clear()
    }
}
