//
//  MovieQuizUITests.swift
//  MovieQuizUITests
//
//  Created by user on 31.05.2023.
//

import XCTest
final class MovieQuizUITests: XCTestCase {
    
    var app: XCUIApplication!
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        
        app = XCUIApplication()
        app.launch()
        
        continueAfterFailure = false
    }
    
    func testYesButton() {
        sleep(3)
        
        let firstPoster = app.images["Poster"]
        let firstPosterData = firstPoster.screenshot().pngRepresentation
        
        let textLabel = app.staticTexts["Index"]

        app.buttons["Yes"].tap()
        sleep(3)
        
        let secondPoster = app.images["Poster"]
        let secondPosterData = secondPoster.screenshot().pngRepresentation
        
        
        
        XCTAssertNotEqual(firstPosterData, secondPosterData)
        XCTAssertEqual(textLabel.label, "2/10")
    }
    
    func testNoButton() {
        sleep(3)
        
        let firstPoster = app.images["Poster"]
        let firstPosterData = firstPoster.screenshot().pngRepresentation
        
        let textLabel = app.staticTexts["Index"]

        app.buttons["No"].tap()
        sleep(3)
        
        let secondPoster = app.images["Poster"]
        let secondPosterData = secondPoster.screenshot().pngRepresentation
        
        
        
        XCTAssertNotEqual(firstPosterData, secondPosterData)
        XCTAssertEqual(textLabel.label, "2/10")
    }
    
    func testAlertPresents() {
        sleep(2)
            for _ in 1...10 {
                app.buttons["No"].tap()
                sleep(2)
            }
    
        let alert = app.alerts["Game result"]
        sleep(2)
        XCTAssertTrue(alert.exists)
        XCTAssertTrue(alert.label == "Этот раунд окончен!")
        XCTAssertTrue(alert.buttons.firstMatch.label == "Сыграть ещё раз")
        
    }
    
    func testAlertDismiss() {
        sleep(2)
        for _ in 1...10 {
            app.buttons["No"].tap()
            sleep(2)
        }
        
        let alert = app.alerts["Game results"]
        sleep(2)
        alert.buttons.firstMatch.tap()
        sleep(5)
        let indexLabel = app.staticTexts["Index"]
        
        XCTAssertFalse(alert.exists)
        XCTAssertTrue(indexLabel.label == "1/10")
    }
}
