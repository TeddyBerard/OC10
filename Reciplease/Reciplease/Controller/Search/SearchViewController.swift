//
//  ViewController.swift
//  Reciplease
//
//  Created by Teddy Bérard on 25/09/2019.
//  Copyright © 2019 Teddy Bérard. All rights reserved.
//

import UIKit
import Photos
import Vision

class SearchViewController: UIViewController {

    // MARK: - Properties

    @IBOutlet weak var ingredientListView: IngredientsListView!
    @IBOutlet weak var ingredientTextField: UITextField!
    @IBOutlet weak var recipeButton: UIButton!
    @IBOutlet weak var addButton: UIButton!
    @IBOutlet weak var resultTableView: UITableView!
    @IBOutlet weak var activityIndication: UIActivityIndicatorView!
    @IBOutlet weak var pictureButton: UIButton!

    var search: Search = Search()
    var recipes: [Recipe] = []
    var selectedPicture: UIImage?

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
        setupPictureButton()
    }

    func setupPictureButton() {
        if #available(iOS 12, *) {
            pictureButton.isHidden = false
        }
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

    /// Add ingredients to list
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
                self.pictureButton.transform = CGAffineTransform(scaleX: scale, y: scale)
            })
        }
    }

    // MARK: - Utils

    /// Ask the permission to use library or camera
    fileprivate func askPermissionPicture() {
        let photos = PHPhotoLibrary.authorizationStatus()
        if photos == .notDetermined {
            PHPhotoLibrary.requestAuthorization({status in
                if status == .authorized {
                    self.dispayPictureChoice()
                } else {}
            })
        } else if photos == .authorized {
            self.dispayPictureChoice()
        }
    }

    /// Display an alert for the user to select an image
    fileprivate func dispayPictureChoice() {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self

        let alertController = UIAlertController(title: "Photo source",
                                   message: "Select a picture to search ingredients in the picture",
                                   preferredStyle: .actionSheet)

        alertController.addAction(UIAlertAction(title: "Camera", style: .default, handler: { (_: UIAlertAction) in
            imagePicker.sourceType = .camera
            self.present(imagePicker, animated: true, completion: nil)
        }))

        alertController.addAction(UIAlertAction(title: "Photo", style: .default, handler: { (_: UIAlertAction) in
            imagePicker.sourceType = .photoLibrary
            self.present(imagePicker, animated: true, completion: nil)
        }))

        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (_) in }))
        DispatchQueue.main.async {
            self.present(alertController, animated: true, completion: nil)
        }
    }

    /// Perform vision request to detect ingredient
    ///
    /// - Parameters:
    ///   - image: image select on library or camera
    ///   - orientation: image orientation
    fileprivate func performVisionRequest(with image: CGImage, orientation: CGImagePropertyOrientation) {
        guard let modelURL = Bundle.main.url(forResource: "ObjectDetector", withExtension: "mlmodelc") else {
            displayNoFoundIngredient()
            return
        }

        do {
            let visionModel = try VNCoreMLModel(for: MLModel(contentsOf: modelURL))
            let objectRecognition = VNCoreMLRequest(model: visionModel, completionHandler: { (request, _) in
                DispatchQueue.main.async(execute: {
                    if let results = request.results,
                        results.count > 0 {
                        self.addDetectedIngredientsToList(results: results)
                    } else {
                        self.displayNoFoundIngredient()
                    }
                    self.selectedPicture = nil
                })
            })
            let imageRequestHandler = VNImageRequestHandler(cgImage: image,
                                                            orientation: orientation,
                                                            options: [:])
            DispatchQueue.global(qos: .userInitiated).async {
                do {
                    try imageRequestHandler.perform([objectRecognition])
                } catch let error as NSError {
                    print("Failed to perform image request: \(error)")
                    self.displayNoFoundIngredient()
                    return
                }
            }
        } catch {
            displayNoFoundIngredient()
        }
    }

    /// Add the detected objects name on list
    ///
    /// - Parameter results: objects detected
    fileprivate func addDetectedIngredientsToList(results: [Any]) {
        let identifierText = results.compactMap({ $0 as? VNRecognizedObjectObservation })
                                    .compactMap({ $0.labels[0].identifier })
                                    .joined(separator: ", ")

        self.ingredientTextField.text = identifierText
        addIngredient()
    }

    /// Display an alert when the vision request not found ingredients
    fileprivate func displayNoFoundIngredient() {
        let message = "Please retake photo or select another, if the problem persist contact us."
        let alertController = UIAlertController(title: "Ingredient not found.",
                                                message: message,
                                                preferredStyle: .alert)
        let close = UIAlertAction(title: "Close", style: .cancel)
        alertController.addAction(close)
        self.present(alertController, animated: true, completion: nil)
    }

    // MARK: - Search Recipes

    /// Search recipe
    func searchRecipe() {
        addButton.setTitle("Back", for: .normal)
        search.searchRecipes(ingredients: ingredientListView.ingredients.joined(separator: ","),
                             from: ingredientListView.from, fakeData: false,
                             completion: { [weak self] hits, from, err in
                                guard let wSelf = self else {
                                    return
                                }

                                wSelf.isDisplayed = true
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

    @IBAction func pictureAction(_ sender: Any) {
        askPermissionPicture()
    }

}

// MARK: - UITableViewDelegate & UITableViewDataSource & Setup TableView

extension SearchViewController: UITableViewDelegate, UITableViewDataSource {

    func setupTableView() {
        resultTableView.register(UINib(nibName: "SearchTableViewCell", bundle: nil),
                                  forCellReuseIdentifier: "recipeCell")
        resultTableView.separatorStyle = .none
        resultTableView.isHidden = true
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

        search.downloadImage(with: recipe.image, completion: { image, _  in
            if let image = image {
                cell.setupImage(with: image)
            }
        })

        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        DispatchQueue.main.async {
            let main = UIStoryboard(name: "Main", bundle: nil)
            guard let detailRecipeViewController =
                main.instantiateViewController(withIdentifier: "DetailRecipeViewController") as?
                DetailRecipeViewController else { return }

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

extension SearchViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        if let pickedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            selectedPicture = pickedImage
        }
        picker.dismiss(animated: true, completion: {
            if let image = self.selectedPicture?.cgImage,
                let orientation = self.selectedPicture?.imageOrientation,
                let cgOrientation = CGImagePropertyOrientation(rawValue: UInt32(orientation.rawValue)) {
                    self.performVisionRequest(with: image, orientation: cgOrientation)
            }
        })
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }

}
