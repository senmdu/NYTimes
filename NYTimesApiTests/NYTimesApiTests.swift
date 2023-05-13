//
//  NYTimesApiTests.swift
//  NYTimesApiTests
//
//  Created by Senthil on 13/05/23.
//

import XCTest
import Foundation

final class NYTimesApiTests: XCTestCase {
    
    
    override class func tearDown() {
        super.tearDown()
    }
    
    // MARK: - Most Popular Articles Api Test
    
    func test_MostPopularList_Api_url_builder() {
        let request: Request<Response<MostPopular>> = MostPopular.request(for: 1)
        let url = URL(APIManager.host, APIManager.apiKey, request)
        XCTAssertEqual(url.absoluteString, "https://api.nytimes.com/svc/mostpopular/v2/viewed/1.json?api-key=\(APIManager.apiKey)")
    }
    
    
    func test_MostPopularList_Api_Result() {
        let expectation = self.expectation(description: "MostPopularList_Api_Result")
        let request: Request<Response<MostPopular>> = MostPopular.request(for: 7)
        let url = URL(APIManager.host, APIManager.apiKey, request)
        APIManager.shared.execute(request) { result in
            guard case .success(let movie) = result else {
                XCTFail("\(url.absoluteString) failed")
                return
            }
            XCTAssertGreaterThan(movie.results.count, 0, "Articles result is empty")
            expectation.fulfill()
        }
        waitForExpectations(timeout: 5, handler: nil)
    }
    
    // MARK: - Test Media Cache Mechanism
    
    func test_MediaCache() {
        let imageStr = "https://www.kasandbox.org/programming-images/avatars/leaf-green.png"
        let imageUrl  = URL(string: imageStr)
        guard let imgURL = imageUrl else {
            XCTFail("\(imageStr) failed")
            return
        }
        let expectation = self.expectation(description: "MediaCache")
        MediaCache.getImage(imageURL: imgURL) { image in
            XCTAssertNotNil(image)
            XCTAssertNotNil(MediaCache.getCachedImage(key: imageStr))
            expectation.fulfill()

        }
        waitForExpectations(timeout: 5, handler: nil)
    }
}
