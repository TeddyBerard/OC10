//
//  SearchTableViewCell.swift
//  Reciplease
//
//  Created by Teddy Bérard on 27/09/2019.
//  Copyright © 2019 Teddy Bérard. All rights reserved.
//

import UIKit
import Alamofire

class SearchTableViewCell: UITableViewCell {

    // MARK: - Properties

    @IBOutlet weak var recipeImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var ingredientsLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var shadowView: UIView!

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func prepareForReuse() {
        super.prepareForReuse()

        recipeImageView.image = #imageLiteral(resourceName: "thumbnail")
        nameLabel.text = ""
        ingredientsLabel.text = ""
        timeLabel.text = ""
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

    // MARK: - Setup cell

    func setup(name: String, ingredients: String, time: Float?) {
        nameLabel.text = name
        ingredientsLabel.text = ingredients
        setupImageUI()
        setupView()

        if let time = time, time != 0 {
            timeLabel.text = "\(time)m"
        } else {
            timeLabel.text = ""
        }
    }

    func setupImage(with imageRecipe: UIImage) {
        recipeImageView.image = imageRecipe
    }

    func setupImageUI() {
        recipeImageView.layer.cornerRadius = 12
        recipeImageView.clipsToBounds = true
    }

    func setupView() {
        // Shadow
//        shadowView.backgroundColor = nil
        shadowView.layer.shadowColor = UIColor.black.cgColor
        shadowView.layer.backgroundColor = UIColor.white.cgColor
        shadowView.layer.shadowOffset = CGSize(width: 0, height: 0)
        shadowView.layer.shadowOpacity = 1
        shadowView.layer.shadowRadius = 1
        // Rounded
        contentView.layer.cornerRadius = 12
        contentView.layer.masksToBounds = true

        shadowView.layer.cornerRadius = 12

    }

}
