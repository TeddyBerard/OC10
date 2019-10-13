//
//  RecipleaseTests.swift
//  RecipleaseTests
//
//  Created by Teddy Bérard on 25/09/2019.
//  Copyright © 2019 Teddy Bérard. All rights reserved.
//

import XCTest
@testable import Reciplease

class RecipleaseTests: XCTestCase {

    var search: Search!

    override func setUp() {
        search = Search()
    }

    override func tearDown() {
    }

    // MARK: - Search

    func testSearchRecipe() {
        let expectation = self.expectation(description: "CorrectRecipe")
        var hitsTest: [Hits] = []

        search.searchRecipes(ingredients: "Tomatos", from: 0) { (hits, _, _) in
            hitsTest = hits
            expectation.fulfill()
        }

        waitForExpectations(timeout: 5, handler: nil)

        XCTAssertEqual(hitsTest.count, 25)
    }

    func testSearchRecipeWrongJson() {
        let expectation = self.expectation(description: "FailedJsonRecipe")
        var err: Error?

        search.baseUrl = "https://jsonplaceholder.typicode.com/todos/1"
        search.searchRecipes(ingredients: "Tomatos", from: 0) { (_, _, error) in
            err = error
            expectation.fulfill()
        }

        waitForExpectations(timeout: 5, handler: nil)

        XCTAssertEqual(err as? Search.SearchError, Search.SearchError.wrongJSON)
    }

    func testSearchRecipeDataFailed() {
        let expectation = self.expectation(description: "FailedDataRecipe")
        var err: Error?

        search.baseUrl = "https://jsonplaceholder.typicode.com/todos/1"
        search.searchRecipes(ingredients: "Tomatos", from: 0, fakeData: true) { (_, _, error) in
            err = error
            expectation.fulfill()
        }

        waitForExpectations(timeout: 5, handler: nil)

        XCTAssertEqual(err as? Search.SearchError, Search.SearchError.occuredErrorRequest)
    }

    func testSearchRecipeWrongURL() {
        let expectation = self.expectation(description: "FailedRecipeWrongURL")
        var err: Error?

        search.baseUrl = "%"
        search.searchRecipes(ingredients: "Tomatos", from: 0) { (_, _, error) in
            err = error
            expectation.fulfill()
        }

        waitForExpectations(timeout: 5, handler: nil)

        XCTAssertEqual(err as? Search.SearchError, Search.SearchError.wrongURL)
    }

    func testSearchRecipeNoData() {
        let expectation = self.expectation(description: "FailedRecipeNoData")
        var err: Error?

        search.baseUrl = "https://"
        search.searchRecipes(ingredients: "Tomatos", from: 0) { (_, _, error) in
            err = error
            expectation.fulfill()
        }

        waitForExpectations(timeout: 5, handler: nil)

        XCTAssertEqual(err as? Search.SearchError, Search.SearchError.occuredErrorRequest)
    }

    func testDownloadImage() {
        let expectation = self.expectation(description: "DowloadImage")
        var img: UIImage?

        search.downloadImage(with: "https://jardinage.lemonde.fr/images/dossiers/2017-07/carlin-1-140155.jpg",
                             completion: { image, _ in
                                img = image
                                expectation.fulfill()
            })

        waitForExpectations(timeout: 5, handler: nil)
        XCTAssertNotNil(img)
    }

    func testDownloadImageWrongURL() {
        let expectation = self.expectation(description: "DowloadImage")
        var err: Error?

        search.downloadImage(with: "%",
                             completion: { _, error in
                                err = error
                                expectation.fulfill()
        })

        waitForExpectations(timeout: 5, handler: nil)
        XCTAssertEqual(err as? Search.SearchError, Search.SearchError.wrongURL)
    }

    // MARK: - Recipe

    func testRecipe() {
        let recipe = Recipe(label: "Test", image: "Test",
                            ingredients: ["Test"], time: 20,
                            health: ["Test"], url: "Test", uri: "Test")

        XCTAssertEqual(recipe.label, "Test")
    }

    // MARK: - Recipe Favorites

    func testSaveFavorites() {
        RecipeFavorite.addRecipe(recipe: Recipe(label: "Test", image: "Test",
                                                ingredients: ["Test"], time: 20,
                                                health: ["Test"], url: "Test", uri: "Test"))
        RecipeFavorite.save()
        RecipeFavorite.addRecipe(recipe: Recipe(label: "Test2", image: "Test2",
                                                ingredients: ["Test"], time: 20,
                                                health: ["Test"], url: "Test", uri: "Test2"))
        RecipeFavorite.save()
        XCTAssertTrue(RecipeFavorite.getRecipes().contains(where: { $0.uri == "Test" }))
        XCTAssertTrue(RecipeFavorite.isAlreadyFavorite(with: "Test2"))
        XCTAssertEqual(RecipeFavorite.isAlreadyFavorite(with: "FailedIsAlready"), false)

        XCTAssertEqual(RecipeFavorite.deleteFavorite(with: "FailedDelete"), false)
        XCTAssertTrue(RecipeFavorite.deleteFavorite(with: "Test2"))
        XCTAssertTrue(RecipeFavorite.deleteFavorite(with: "Test"))
        RecipeFavorite.save()

        XCTAssertEqual(RecipeFavorite.getRecipes().count, 0)
    }

}
