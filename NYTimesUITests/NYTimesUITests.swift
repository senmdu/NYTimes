//
//  NYTimesUITests.swift
//  NYTimesUITests
//
//  Created by Senthil on 13/05/23.
//

import XCTest


final class NYTimesUITests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.

        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }


    // MARK: - Launching Performance Test
    
    func testLaunchPerformance() throws {
        let app = XCUIApplication()
                if #available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 7.0, *) {
            // This measures how long it takes to launch your application.
            measure(metrics: [XCTApplicationLaunchMetric()]) {
                app.launch()
            }
        }
    }
    
    // MARK: - Testing App UI
    
    func testAppUI() throws {
         let app = XCUIApplication()
         app.launch()
         XCTAssertTrue(app.cells["cell_0"].waitForExistence(timeout: 5.0))
         let articleTitle = app.staticTexts.element(matching:.any, identifier: "cell_0_title").label
         app.cells["cell_0"].tap()
         let articleTitleDetailPage = app.staticTexts.element(matching:.any, identifier: "article_title").label
        
         XCTAssertEqual(articleTitle, articleTitleDetailPage)
   
         XCTAssertTrue(app.buttons["read_article_button"].exists)
         app.buttons["read_article_button"].tap()

    }
}
