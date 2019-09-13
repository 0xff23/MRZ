//
//  MRZUITests.swift
//  MRZUITests
//
//  Created by Kirill G on 9/12/19.
//  Copyright © 2019 k-ios. All rights reserved.
//

import XCTest

class MRZUITests: XCTestCase {
  var app: XCUIApplication!
  
  let barcodeWithMidName = "P<USAROGGER<<MICHAEL<JOHN<<<<<<<<<<<<<<<YA11164461USA8502201M2001023<<<<<<<<<<<<<<00"
  let regularBarCode = "P<USACOOK<<TIM<<<<<<<<<<<<<<<YA11164461USA8502201M2001023<<<<<<<<<<<<<<00"
  let incorrectCountryCode = "P<RUSROGGER<<MICHAEL<<<<<<<<<<<<<<<<YA11164461USA8502201M2001023<<<<<<<<<<<<<<00"
  let noPassportCode = "B<USAROGGER<<MICHAEL<<<<<<<<<<<<<<<YA11164461USA8502201M2001023<<<<<<<<<<<<<<00"
  
  override func setUp() {
    super.setUp()
    
    // Since UI tests are more expensive to run, it's usually a good idea to exit if a failure was encountered
    continueAfterFailure = false
    
    app = XCUIApplication()
    
    // We send a command line argument to our app, to enable it to reset its state
    app.launchArguments.append("--uitesting")
  }
  
  override func tearDown() {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
  }
  
  func testSearchView() {
    app.launch()
    
    XCTAssertTrue(app.isSearchViewDisplayed)
    XCTAssertTrue(app.isUIElementsDisplayed)
  }
  
  func testSearchTableView() {
    app.launch()
    
    app.testWith(barCode: regularBarCode, in: app)
  }
  
  func testPassportCodeErrorAlertView() {
    app.launch()
    
    app.testWith(barCode: noPassportCode, in: app)
    
    let errorAlert = XCUIApplication().alerts["Error"]
    
    XCTAssertTrue(errorAlert.staticTexts["Barcode invalid. Please try again."].exists)
    
    errorAlert.staticTexts["Barcode invalid. Please try again."].tap()
    errorAlert.buttons["OK"].tap()
  }
  
  func testLabelUpdateWithMidName() {
    app.launch()
    
    app.testWith(barCode: barcodeWithMidName, in: app)
    
    let errorAlert = XCUIApplication().alerts["Error"]
    XCTAssertTrue(errorAlert.staticTexts["Request failed. URL is incorrect."].exists)
    
    errorAlert.staticTexts["Request failed. URL is incorrect."].tap()
    errorAlert.buttons["OK"].tap()
    
    XCTAssertTrue(app.staticTexts["id_label"].exists)
    XCTAssertTrue(app.staticTexts["id_label"].label == "MICHAEL JOHN ROGGER")
  }
  
  func testLabelUpdateWhenParsing() {
    app.launch()
    
    app.testWith(barCode: regularBarCode, in: app)
    
    XCTAssertTrue(app.staticTexts["id_label"].exists)
    XCTAssertTrue(app.staticTexts["id_label"].label == "TIM COOK")
    
    XCTAssertTrue(app.tables.count > 0, "Tableview error.")
    XCTAssertTrue(app.cells.count > 0, "Empty search results.")
    
    XCTAssertTrue(app.cells.staticTexts["cell_title"].exists)
  }
  
  func testCountryCodeAlertView() {
    app.launch()
    
    app.testWith(barCode: incorrectCountryCode, in: app)
    
    let errorAlert = XCUIApplication().alerts["Error"]
    XCTAssertTrue(errorAlert.staticTexts["Barcode invalid. Please try again."].exists)
    errorAlert.staticTexts["Barcode invalid. Please try again."].tap()
    errorAlert.buttons["OK"].tap()
  }
  
}

extension XCUIApplication {
  var isSearchViewDisplayed: Bool {
    return otherElements["searchView"].exists
  }
  
  var isUIElementsDisplayed: Bool {
    return textFields.count == 1 && buttons.count == 1
  }
  
  func testWith(barCode: String, in app: XCUIApplication) {
    app.textFields["barCodeField"].tap()
    app.textFields["barCodeField"].typeText(barCode)
    app.buttons["parseButton"].tap()
    
  }
  
}

